//
//  RedditWebView.m
//  Reddit
//
//  Created by Ross Boucher on 3/11/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "RedditWebView.h"
#import "Constants.h"
#import "LoginController.h"
#import "LoginViewController.h"

@implementation RedditWebView

id _realDelegate;

+ (NSString *)storyIDForURL:(NSURL *)aURL
{
	return [[self class] storyIDForURL:aURL commentID:nil];
}

+ (NSString *)storyIDForURL:(NSURL *)aURL commentID:(NSString **)stringPtr
{
	NSString *path = [aURL path];
	NSString *host = [aURL host];
	
	NSRange redditComRange = [host rangeOfString:@"reddit.com"];
	NSRange commentsRange = [path rangeOfString:@"/comments/"];
		
	if (redditComRange.location > 0 && commentsRange.location >= 0 && NSMaxRange(commentsRange) < [path length])
	{
		NSString *storyID = nil;
		NSString *remainder = [path substringFromIndex:NSMaxRange(commentsRange)];		
		NSScanner *scanner = [NSScanner scannerWithString:remainder];

		[scanner  scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/?&"] intoString:&storyID];

		NSArray  *components = [remainder componentsSeparatedByString:@"/"];
		NSString *lastComponent = [components lastObject];
				
		if (stringPtr)
			*stringPtr = lastComponent;		
				
		if (storyID) 
			return [[storyID retain] autorelease];
	}
	
	return nil;
}

- (void)awakeFromNib
{
	[super setDelegate:(id<UIWebViewDelegate>)self];
}

- (id)initWithFrame:(CGRect)aFrame
{
	if (self = [super initWithFrame:aFrame])
	{
		[super setDelegate:(id<UIWebViewDelegate>)self];
	}
	
	return self;
}


- (void)setDelegate:(id)delegate
{
	_realDelegate = delegate;
}

- (id)delegate
{
	return _realDelegate;
}

- (void)loginViewController:(LoginViewController *)aController didFinishWithContext:(id)aContext
{	
	if ([[LoginController sharedLoginController] isLoggedIn] && [aContext isEqual:@"RedditWebView"])
	{
		[self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.MODHASH = '%@'", [[LoginController sharedLoginController] modhash]]];
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	if (_realDelegate && [_realDelegate respondsToSelector:@selector(webViewDidStartLoad:)])
		[_realDelegate webViewDidStartLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if ([[LoginController sharedLoginController] isLoggedIn])
		[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.MODHASH = '%@'", [[LoginController sharedLoginController] modhash]]];

	if (_realDelegate && [_realDelegate respondsToSelector:@selector(webViewDidFinishLoad:)])
		[_realDelegate webViewDidFinishLoad:webView];
	
	[self canGoBack];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	if (_realDelegate && [_realDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
		[_realDelegate webView:webView didFailLoadWithError:error];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	BOOL response = YES;
	if (_realDelegate && [_realDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
		response = [_realDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];

	if (!response)
		return NO;

	if ([@"http://login/" isEqualToString:[[request URL] absoluteString]])
	{
		[LoginViewController presentWithDelegate:(id <LoginViewControllerDelegate>)self context:@"RedditWebView"];
		return NO;
	}
	
	NSString *commentID = nil;
	NSString *storyID = [[self class] storyIDForURL:[request URL] commentID:&commentID];

	if (storyID)
	{
		Story *theStory = [Story storyWithID:storyID];
		
		if (theStory)
			[self loadWithStory:theStory commentID:commentID];
		else
			[self loadWithStoryID:storyID commentID:commentID];		
	}
	
	return YES;
}

- (void)loadWithStoryID:(NSString *)theID commentID:(NSString *)commentID
{
	NSString *path = [NSString stringWithFormat:@"%@?id=%@&title=%@&author=%@&created=%@&domain=%@&base=%@&jump=%@",
					  [[NSBundle mainBundle] pathForResource:@"comments" ofType:@"html"],
					  [theID stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					  [@"Loading Story Title" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					  [@"reddit" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					  [[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					  [@"reddit.com" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					  [RedditBaseURLString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					  [(commentID ? commentID : @"no_such_id") stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]
					  ];
		
	NSURL *url = [[NSURL alloc] initWithScheme:@"file" host:@"localhost" path:path];
		
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	[url release];
	
	[self loadRequest:request];		
}

- (void)loadWithStory:(Story *)story commentID:(NSString *)commentID
{
	NSString *path = [NSString stringWithFormat:@"%@?id=%@&title=%@&author=%@&created=%@&domain=%@&base=%@",
					  [[NSBundle mainBundle] pathForResource:@"comments" ofType:@"html"],
					  [story.identifier stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					  [story.title stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					  [story.author stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					  [story.created stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					  [story.domain stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					  [RedditBaseURLString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
					  [(commentID ? commentID : @"no_such_id") stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]
					  ];
	NSURL *url = [[NSURL alloc] initWithScheme:@"file" host:@"localhost" path:path];
		
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	[url release];
	
	[self loadRequest:request];	
}

- (void)dealloc 
{
	NSLog(@"DEALLOCING WEBVIEW %@", self);
	super.delegate = nil;
    [super dealloc];
}

@end
