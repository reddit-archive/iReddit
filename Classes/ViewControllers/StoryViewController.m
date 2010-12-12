//
//  StoryViewController.m
//  Reddit2
//
//  Created by Ross Boucher on 6/12/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "StoryViewController.h"
#import "Constants.h"
#import "LoginController.h"
#import "LoginViewController.h"
#import "SubredditDataSource.h"
#import "SubredditViewController.h"
#import "RedditWebView.h"
#import "iRedditAppDelegate.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@implementation StoryViewController

@synthesize story, scoreItem, commentCountItem, segmentedControl, loadingView, toggleButtonItem, webview;

- (id)initForComments
{
	if (self = [super init])
	{
		isForComments = YES;
	}
	
	return self;
}

- (void)loadView 
{
	self.navigationBarTintColor = [iRedditAppDelegate redditNavigationBarTintColor];
	self.hidesBottomBarWhenPushed = NO;

	[super loadView];
	
	NSMutableArray *items = [NSMutableArray array];
	
	UIImage *voteUpImage = [UIImage imageNamed:@"voteUp.png"];
	UIImage *voteDownImage = [UIImage imageNamed:@"voteDown.png"];
	
	[items addObject:[[[UIBarButtonItem alloc] initWithImage:voteUpImage style:UIBarButtonItemStylePlain target:self action:@selector(voteUp:)] autorelease]];
	
	scoreItem = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	scoreItem.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
	scoreItem.showsTouchWhenHighlighted = NO;
	scoreItem.adjustsImageWhenHighlighted = NO;
	[scoreItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[scoreItem setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
	
	scoreItem.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	
	[items addObject:[[[UIBarButtonItem alloc] initWithCustomView:scoreItem] autorelease]];
	[items addObject:[[[UIBarButtonItem alloc] initWithImage:voteDownImage style:UIBarButtonItemStylePlain target:self action:@selector(voteDown:)] autorelease]];
	
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];

	if (!isForComments)
	{
		self.commentCountItem = [UIButton buttonWithType:UIButtonTypeCustom];
		commentCountItem.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
		commentCountItem.showsTouchWhenHighlighted = NO;
		commentCountItem.adjustsImageWhenHighlighted = NO;
		[commentCountItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[commentCountItem setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];

		commentCountItem.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		
		[items addObject:[[[UIBarButtonItem alloc] initWithCustomView:commentCountItem] autorelease]];
		
		[items addObject:[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"commentBubble.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showComments:)] autorelease]];
	}
	else
	{
		[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showStory:)] autorelease]];
	}
	
	self.toggleButtonItem = [items lastObject];

	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)] autorelease]];

	[self setToolbarItems:items animated:NO];
	
	NSArray *viewControllers = [[self navigationController] viewControllers];

	if ([viewControllers count] > 2 && [[viewControllers objectAtIndex:[viewControllers count] - 2] isKindOfClass:[StoryViewController class]])
	{
		commentCountItem.enabled = NO;
		toggleButtonItem.enabled = NO;
	}

	NSArray *segmentItems = [NSArray arrayWithObjects:
							 [UIImage imageNamed:@"back.png"],
							 [UIImage imageNamed:@"refresh.png"],
							 [UIImage imageNamed:@"forward.png"],
							 nil
							 ];
	
	segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentItems];
	
	[segmentedControl setMomentary:YES];
	[segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];

	[segmentedControl setWidth:30.0 forSegmentAtIndex:0];
	[segmentedControl setWidth:30.0 forSegmentAtIndex:1];
	[segmentedControl setWidth:30.0 forSegmentAtIndex:2];
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	
	segmentedControl.tintColor = self.navigationController.navigationBar.tintColor;
		
	UIBarButtonItem *segmentBarItem = [[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease];
	self.navigationItem.rightBarButtonItem = segmentBarItem;

	CGRect navBarFrame = self.navigationController.navigationBar.frame;
	
	UILabel *titleView = [[[UILabel alloc] initWithFrame:CGRectMake(0, 2, navBarFrame.size.height > 40 ? 120 : 280, CGRectGetHeight(navBarFrame) - 4.0)] autorelease];
	self.navigationItem.titleView = titleView;
	
	[titleView setBackgroundColor:[UIColor clearColor]];
	[titleView setOpaque:NO];
	
	[titleView setFont:[UIFont boldSystemFontOfSize:14.0]];
	[titleView setMinimumFontSize:12.0];

	[titleView setTextColor:[UIColor whiteColor]];
	[titleView setShadowColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
	[titleView setShadowOffset:CGSizeMake(0, -1)];
	
	[titleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[titleView setNumberOfLines:2];
	[titleView setLineBreakMode:UILineBreakModeMiddleTruncation];
	[titleView setTextAlignment:UITextAlignmentCenter];
	[titleView setAdjustsFontSizeToFitWidth:YES];
	
	self.view = [[[UIView alloc] initWithFrame:TTApplicationFrame()] autorelease];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	
	webview = [[RedditWebView alloc] initWithFrame:self.view.bounds];
	webview.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	webview.scalesPageToFit = YES;
	
	[self.view addSubview:webview];
	
	webview.delegate = (id <UIWebViewDelegate>)self;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:showLoadingAlienKey])
	{
		loadingView = [[AlienProgressView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 111.0, CGRectGetHeight(self.view.frame) - 150.0, 101.0, 140.0)];
		loadingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
		[loadingView setHidden:YES];
		
		[loadingView setBackgroundColor:[UIColor clearColor]];
		[loadingView setOpaque:NO];
		
		[self.view addSubview:loadingView];
	}
}

- (void)setStory:(Story *)aStory
{
	if (aStory == story)
		return;

	[story release];
	story = [aStory retain];
	
	if (!story)
		return;
	
	story.visited = YES;
	
	[webview stopLoading];
	
	if (commentCountItem)
		[self loadStory];
	else
		[self loadStoryComments];

	[loadingView setHidden:NO];
	[loadingView startAnimating];

	if (commentCountItem)
		self.title = @"Story";
	else		
		self.title = @"Comments";

	[self setNumberOfComments:story.totalComments];
	[self setScore:story.score];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)setStoryID:(NSString *)storyID commentID:(NSString *)commentID URL:(NSString *)aURL
{
	Story *aStory = [Story storyWithID:storyID];

	if (aStory)
	{
		aStory.commentID = commentID;
		[self loadStoryComments];
	}
	else
	{
		self.toggleButtonItem.enabled = NO;	
		
		aStory = [[[Story alloc] init] autorelease];
		aStory.identifier = storyID;
		aStory.commentID = commentID;
		aStory.URL = aURL;
	
		self.story = aStory;

		[self loadStoryComments];
	}
}

- (void)loadStory
{
	[webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:story.URL]]];	
}

- (void)loadStoryComments
{
	[webview loadRequest:
	 [NSURLRequest requestWithURL:
	  [NSURL URLWithString:
	   [NSString stringWithFormat:@"%@/comments/%@/%@", RedditBaseURLString, story.identifier, story.commentID]
	   ]
	  ]
	 ];
}

- (void)setScore:(int)score
{
	[scoreItem setTitle:[NSString stringWithFormat:@"%i", score] forState:UIControlStateNormal];
	[scoreItem sizeToFit];
	
	if (story.likes)
		[scoreItem setTitleColor:[UIColor colorWithRed:255.0/255.0 green:139.0/255.0 blue:96.0/255.0 alpha:1.0] forState:UIControlStateNormal];
	else if (story.dislikes)
		[scoreItem setTitleColor:[UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
	else
		[scoreItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)setNumberOfComments:(unsigned)commentCount
{
	[commentCountItem setTitle:[NSString stringWithFormat:@"%u", commentCount] forState:UIControlStateNormal];
	[commentCountItem sizeToFit];
}

- (void)voteUp:(id)sender
{
	if (![[LoginController sharedLoginController] isLoggedIn] && sender != self)
	{
		[LoginViewController presentWithDelegate:(id <LoginViewControllerDelegate>)self context:@"voteUp"];
		return;
	}

	NSString *url = [NSString stringWithFormat:@"%@%@", RedditBaseURLString, RedditVoteAPIString];
	TTURLRequest *request = [TTURLRequest requestWithURL:url delegate:nil];
	
	request.cacheExpirationAge = 0;
	request.cachePolicy = TTURLRequestCachePolicyNoCache;
	request.contentType = @"application/x-www-form-urlencoded";
	request.httpMethod = @"POST";
	request.httpBody = [[NSString stringWithFormat:@"dir=%d&uh=%@&id=%@&_=", story.likes ? 0 : 1, 
						   [[LoginController sharedLoginController] modhash], story.name] 
						  dataUsingEncoding:NSASCIIStringEncoding];
	
	[request send];

	
	story.likes = !story.likes;
	story.dislikes = NO;
	
	[self setScore:story.score];
	
	//[[Beacon shared] startSubBeaconWithName:@"votedUp" timeSession:NO];
}

- (void)voteDown:(id)sender
{
	if (![[LoginController sharedLoginController] isLoggedIn] && sender != self)
	{
		[LoginViewController presentWithDelegate:(id <LoginViewControllerDelegate>)self context:@"voteDown"];
		return;
	}

	NSString *url = [NSString stringWithFormat:@"%@%@", RedditBaseURLString, RedditVoteAPIString];
	TTURLRequest *request = [TTURLRequest requestWithURL:url delegate:nil];
	
	request.cacheExpirationAge = 0;
	request.cachePolicy = TTURLRequestCachePolicyNoCache;
	request.contentType = @"application/x-www-form-urlencoded";
	request.httpMethod = @"POST";
	request.httpBody = [[NSString stringWithFormat:@"dir=%d&uh=%@&id=%@&_=", story.dislikes ? 0 : -1, 
						 [[LoginController sharedLoginController] modhash], story.name] 
						dataUsingEncoding:NSASCIIStringEncoding];
	
	[request send];


	story.likes = NO;
	story.dislikes = !story.dislikes;
	
	[self setScore:story.score];
	
	//[[Beacon shared] startSubBeaconWithName:@"votedDown" timeSession:NO];
}

- (IBAction)showComments:(id)sender
{
	NSArray *viewControllers = [[self navigationController] viewControllers];
	
	if (story.isSelfReddit || ([viewControllers count] > 2 && [[viewControllers objectAtIndex:[viewControllers count] - 2] isKindOfClass:[StoryViewController class]]))
		return;

	StoryViewController *commentsController = [[StoryViewController alloc] initForComments];	
	[[self navigationController] pushViewController:commentsController animated:YES];

	[commentsController setStory:story];
	[commentsController release];
}

- (IBAction)showStory:(id)sender
{
	NSArray *viewControllers = [[self navigationController] viewControllers];

	if (story.isSelfReddit || ([viewControllers count] > 2 && [[viewControllers objectAtIndex:[viewControllers count] - 2] isKindOfClass:[StoryViewController class]]))
		return;
	
	StoryViewController *storyController = [[StoryViewController alloc] init];	
	[[self navigationController] pushViewController:storyController animated:YES];
	
	[storyController setStory:story];
	[storyController release];
}


- (IBAction)share:(id)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:@""
								  delegate:(id <UIActionSheetDelegate>)self
								  cancelButtonTitle:@"Cancel"
								  destructiveButtonTitle:nil
								  otherButtonTitles:@"E-mail Link", @"Open Link in Safari", @"Hide on reddit", @"Save on reddit", @"Save on Instapaper", nil];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)actionSheetCancel:(id)sender
{	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	NSString *url = story.URL;
	if (isForComments && story.commentsURL)
		url = story.commentsURL;
	
	if (buttonIndex == 0)
	{
		//email link
		if ([MFMailComposeViewController canSendMail])
		{
			MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
			controller.mailComposeDelegate = (id <MFMailComposeViewControllerDelegate>)self;
			
			NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:redditUsernameKey];

			if (user)
				[controller setSubject:[NSString stringWithFormat:@"[ireddit] %@ thinks you're going to like this link", user]];
			else
				[controller setSubject:[NSString stringWithFormat:@"[ireddit] check out this link from %@", 
										story.subreddit ? [NSString stringWithFormat:@"the %@ reddit", story.subreddit] : @"reddit"]];

			[controller setMessageBody:[NSString stringWithFormat:@"%@ shared a link with you from iReddit (http://reddit.com/iphone):\n\n%@\n\n\"%@\"\n\n%@\n\n%@",
										user ? user : @"someone", 
										story.URL, 
										story.title ? story.title : @"sorry, we couldn't find the title. you'll have to click to find out", 
										story.totalComments ? @"there's also a discussion going on here:" : @"", 
										story.totalComments ? story.commentsURL : @""]
								isHTML:NO];

			[self presentModalViewController:controller animated:YES];
			[controller release];

			//[[Beacon shared] startSubBeaconWithName:@"emailedStory" timeSession:NO];
		}
		else
		{
			[[[[UIAlertView alloc] initWithTitle:@"E-mail Error" 
										 message:@"Your device is not configured to send mail. Update your mail information in the Settings application and try again." 
										delegate:nil 
							   cancelButtonTitle:@"OK" 
							   otherButtonTitles:nil] autorelease] show];
		}
	}
	
	else if(buttonIndex == 1 )
	{
		//open link in safari
		//[[Beacon shared] startSubBeaconWithName:@"openedInSafari" timeSession:NO];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
	else if (buttonIndex == 2)
	{
		if (![[LoginController sharedLoginController] isLoggedIn])
			[LoginViewController presentWithDelegate:(id <LoginViewControllerDelegate>)self context:@"hide"];
		else
		{
			[self hideCurrentStory:nil];
		//	[[Beacon shared] startSubBeaconWithName:@"savedOnReddit" timeSession:NO];
		}
	}
	else if (buttonIndex == 3)
	{
		if (![[LoginController sharedLoginController] isLoggedIn])
			[LoginViewController presentWithDelegate:(id <LoginViewControllerDelegate>)self context:@"save"];
		else
		{
			[self saveCurrentStory:nil];
			//	[[Beacon shared] startSubBeaconWithName:@"savedOnReddit" timeSession:NO];
		}
	}
	else if(buttonIndex == 4)
	{
		[self saveOnInstapaper:nil];
		//[[Beacon shared] startSubBeaconWithName:@"instapaper" timeSession:NO];
	}
	else if(buttonIndex == 4)
		[self actionSheetCancel:actionSheet];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[controller dismissModalViewControllerAnimated:YES];
}

- (void)saveOnInstapaper:(id)sender
{
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:instapaperUsernameKey];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:instapaperPasswordKey];

	if (!password || [password isEqual:@""])
		password = @"password";

	if (!username || [username isEqual:@""])
	{
		[[[[UIAlertView alloc] initWithTitle:@"Instapaper Error" 
									 message:@"You must provide an Instapaper username to save stories with Instapaper. You can add a username in the iReddit settings." 
									delegate:nil 
						   cancelButtonTitle:@"OK" 
						   otherButtonTitles:nil] autorelease] show];
		return;
	}

	NSString *url = story.URL;
	if (isForComments && story.commentsURL)
		url = story.commentsURL;

	TTURLRequest *request = [TTURLRequest requestWithURL:InstapaperAPIString delegate:nil];
	
	request.cacheExpirationAge = 0;
	request.cachePolicy = TTURLRequestCachePolicyNoCache;

	request.httpMethod = @"POST";

	[request.parameters setObject:username forKey:@"username"];
	[request.parameters setObject:password forKey:@"password"];
	[request.parameters setObject:url forKey:@"url"];
	[request.parameters setObject:story.title ? story.title : @"no title" forKey:@"title"];
	
	[request send];
}

- (void)saveCurrentStory:(id)sender
{
	NSString *url = [NSString stringWithFormat:@"%@%@", RedditBaseURLString, RedditSaveStoryAPIString];
	TTURLRequest *request = [TTURLRequest requestWithURL:url delegate:nil];
	
	request.cacheExpirationAge = 0;
	request.cachePolicy = TTURLRequestCachePolicyNoCache;
	request.contentType = @"application/x-www-form-urlencoded";
	request.httpMethod = @"POST";
	request.httpBody = [[NSString stringWithFormat:@"uh=%@&id=%@&_=", 
						[[LoginController sharedLoginController] modhash], story.name] 
						dataUsingEncoding:NSASCIIStringEncoding];
	
	[request send];
}

- (void)hideCurrentStory:(id)sender
{
	NSString *url = [NSString stringWithFormat:@"%@%@", RedditBaseURLString, RedditHideStoryAPIString];
	TTURLRequest *request = [TTURLRequest requestWithURL:url delegate:nil];
	
	request.cacheExpirationAge = 0;
	request.cachePolicy = TTURLRequestCachePolicyNoCache;
	request.contentType = @"application/x-www-form-urlencoded";
	request.httpMethod = @"POST";
	request.httpBody = [[NSString stringWithFormat:@"uh=%@&id=%@&executed=hidden", 
						 [[LoginController sharedLoginController] modhash], story.name] 
						dataUsingEncoding:NSASCIIStringEncoding];
	
	[request send];
	
	NSArray *viewControllers = self.navigationController.viewControllers;
	
	if ([viewControllers count] > 2 && [[viewControllers objectAtIndex:[viewControllers count] - 2] isKindOfClass:[SubredditViewController class]])
	{
		SubredditViewController *controller = (SubredditViewController *)[viewControllers objectAtIndex:[viewControllers count] - 2];
		SubredditDataSource *ds = (SubredditDataSource *)controller.dataSource;
		[ds.items removeObject:self.story];
	}
}

- (void)loginViewController:(LoginViewController *)aController didFinishWithContext:(id)aContext
{
	if ([[LoginController sharedLoginController] isLoggedIn])
	{
		if ([aContext isEqual:@"save"])
			[self saveCurrentStory:self];
		else if ([aContext isEqual:@"voteUp"])
			[self voteUp:self];
		else if ([aContext isEqual:@"voteDown"])
			[self voteDown:self];
		else if ([aContext isEqual:@"hide"])
			[self hideCurrentStory:self];
	}
}

- (IBAction)segmentAction:(id)sender
{
	switch ([sender selectedSegmentIndex])
	{
		case 0:
			[webview goBack];
			break;
		case 1:
			if ([webview isLoading])
			{
				[webview stopLoading];
				[self webViewDidFinishLoad:webview];
			}
			else
			{
				[webview reload];
			}
			
			break;
		case 2:
			[webview goForward];
			break;
	}
	//[[Beacon shared] startSubBeaconWithName:@"usedSegmentNav" timeSession:NO];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[(UILabel *)(self.navigationItem.titleView) setText:@"Loading..."];
	[segmentedControl setEnabled:[webView canGoBack] forSegmentAtIndex:0];
	[segmentedControl setEnabled:[webView canGoForward] forSegmentAtIndex:2];
	[segmentedControl setImage:[UIImage imageNamed:@"stop.png"] forSegmentAtIndex:1];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if ([loadingView isAnimating])
	{
		[loadingView setHidden:YES];
		[loadingView stopAnimating];
	}

	[segmentedControl setEnabled:[webView canGoBack] forSegmentAtIndex:0];
	[segmentedControl setEnabled:[webView canGoForward] forSegmentAtIndex:2];
	[segmentedControl setImage:[UIImage imageNamed:@"refresh.png"] forSegmentAtIndex:1];
	
	[(UILabel *)(self.navigationItem.titleView) setText:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	if (![self.navigationController.topViewController isKindOfClass:[StoryViewController class]])
	{
		CGRect frame = self.webview.frame;
		frame.size.height += self.navigationController.toolbar.frame.size.height;
		self.webview.frame = frame;

		[self.navigationController setToolbarHidden:YES animated:YES];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setScore:story.score];
	
	self.navigationController.toolbar.tintColor = [UIColor blackColor];
	
	if (self.navigationController.toolbarHidden)
		[self.navigationController setToolbarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:allowLandscapeOrientationKey] ? YES : UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)viewDidUnload
{
	[webview setDelegate:nil];
	[webview stopLoading];
	[webview removeFromSuperview];
	self.webview = nil;
	self.scoreItem = nil;
	self.commentCountItem = nil;
	self.toggleButtonItem = nil;
	self.segmentedControl = nil;
	self.loadingView = nil;
	
	NSLog(@"unloading story view controller %@", self);
	[super viewDidUnload];
}

- (void)dealloc 
{
	self.story = nil;
	
    [super dealloc];
}


@end
