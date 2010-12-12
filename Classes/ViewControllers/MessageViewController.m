//
//  MessageViewController.m
//  Reddit2
//
//  Created by Ross Boucher on 6/16/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "MessageViewController.h"
#import "iRedditAppDelegate.h"
#import "RedditMessage.h"
#import "Constants.h"
#import "LoginController.h"
#import "NSDictionary+JSON.h"
#import "RedditWebView.h"

@implementation MessageViewController

- (void)loadView
{
	[super loadView];
	
	self.title = @"Inbox";

	self.navigationBarTintColor = [iRedditAppDelegate redditNavigationBarTintColor];
	
	self.variableHeightRows = YES;

	self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain] autorelease];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[self.view addSubview:self.tableView];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(compose:)] autorelease];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCountChanged:) name:MessageCountDidChangeNotification object:nil];
}

- (void)messageCountChanged:(NSNotification *)notif
{
    [self createModel];
    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
    // marking as read doesn't actually work, so let's not pretend it does
	//[[iRedditAppDelegate sharedAppDelegate].messageDataSource markRead:self];
}

-(void)createModel 
{
	self.dataSource = [iRedditAppDelegate sharedAppDelegate].messageDataSource;
}

- (void)compose:(id)sender
{
	TTMessageController* controller = [[[TTMessageController alloc] initWithRecipients:[NSArray array]] autorelease];
	
	TTMessageTextField *toField = [[[TTMessageTextField alloc] initWithTitle:
									TTLocalizedString(@"To:", @"") required:YES] autorelease];

	controller.fields = [[NSArray alloc] initWithObjects:
						 toField,
						 [[[TTMessageSubjectField alloc] initWithTitle:
						   TTLocalizedString(@"Subject:", @"") required:NO] autorelease],
						 nil];
	
	controller.delegate = (id <TTMessageControllerDelegate>)self;	
	controller.navigationBarTintColor = self.navigationBarTintColor;
	controller.navigationController.navigationBar.tintColor = self.navigationBarTintColor;

	UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
    [navController pushViewController:controller animated:NO];
	
	[self presentModalViewController:navController animated:YES];
}

- (void)didSelectObject:(TTTableItem*)object atIndexPath:(NSIndexPath*)indexPath
{
	if ([object isKindOfClass:[TTTableMoreButton class]])
		[super didSelectObject:object atIndexPath:indexPath];
	else
	{	
		RedditMessage *message = (RedditMessage *)object;
		
		if (message.isCommentReply)
		{
			NSString *commentID = nil;
			NSString *storyID = [RedditWebView storyIDForURL:[NSURL URLWithString:message.context] commentID:&commentID];

			StoryViewController *controller = [[[StoryViewController alloc] initForComments] autorelease];

			[[self navigationController] pushViewController:controller animated:YES];
			[controller setStoryID:storyID commentID:commentID URL:message.context];
		}
		else
		{
			TTMessageController* controller = [[[TTMessageController alloc] initWithRecipients:[NSArray array]] autorelease];

			TTMessageTextField *toField = [[[TTMessageTextField alloc] initWithTitle:
											TTLocalizedString(@"To:", @"") required:YES] autorelease];
			
			TTMessageSubjectField *subjectField = [[[TTMessageSubjectField alloc] initWithTitle:
													TTLocalizedString(@"Subject:", @"") required:NO] autorelease];
			
			controller.fields = [[NSArray alloc] initWithObjects:toField, subjectField, nil];

			controller.delegate = (id <TTMessageControllerDelegate>)self;	
			controller.navigationBarTintColor = self.navigationBarTintColor;
			controller.navigationController.navigationBar.tintColor = self.navigationBarTintColor;

			[controller setText:message.author forFieldAtIndex:0];
			[controller setSubject:[NSString stringWithFormat:@"RE: %@", message.subject]];
			
			UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
			[navController pushViewController:controller animated:NO];

			[self presentModalViewController:navController animated:YES];
		}
	}

	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTMessageControllerDelegate

- (void)composeController:(TTMessageController*)controller didSendFields:(NSArray*)fields 
{
	TTMessageTextField *toField = [fields objectAtIndex:0];
	TTMessageSubjectField *subjectField = [fields objectAtIndex:1];
	TTMessageTextField *messageBody = [fields objectAtIndex:2];

	NSString *url = [NSString stringWithFormat:@"%@%@", RedditBaseURLString, RedditComposeMessageAPIString];
	
	activeRequest = [TTURLRequest requestWithURL:url delegate:self];
	activeRequest.cacheExpirationAge = 0;
    activeRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
    activeRequest.shouldHandleCookies = [[LoginController sharedLoginController] isLoggedIn] ? YES : NO;
	activeRequest.httpMethod = @"POST";
	activeRequest.contentType = @"application/x-www-form-urlencoded";
	activeRequest.httpBody = 	 [[NSString stringWithFormat:@"id=%@&uh=%@&to=%@&subject=%@&text=%@",
								   @"%23compose-message",
								   [[LoginController sharedLoginController] modhash],
								   [[toField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
								   [[subjectField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
								   [[messageBody.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]
								   ] dataUsingEncoding:NSASCIIStringEncoding];
	activeRequest.response = [[[TTURLDataResponse alloc] init] autorelease];

	[activeRequest send];

	[controller dismissModalViewControllerAnimated:YES];
}

// for the message composer!
- (void)requestDidFinishLoad:(TTURLRequest*)request
{
    NSString *responseBody = [[NSString alloc] initWithData:((TTURLDataResponse *)request.response).data encoding:NSUTF8StringEncoding];

    if([responseBody rangeOfString:@"error"].location != NSNotFound)
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Sending Message" 
                           message:@"Could not send your message at this time. Please try again later." 
                           delegate:nil 
						   cancelButtonTitle:@"OK" 
						   otherButtonTitles:nil] autorelease] show];
    }
    
    [responseBody release];
    
    activeRequest = nil;
}

// for the message composer!
- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    activeRequest = nil;
    
    [[[[UIAlertView alloc] initWithTitle:@"Error Sending Message" 
                           message:@"Could not send your message at this time. Please try again later." 
                           delegate:nil 
						   cancelButtonTitle:@"OK" 
						   otherButtonTitles:nil] autorelease] show];
}

// for the message composer!
- (void)requestDidCancelLoad:(TTURLRequest*)request
{
	activeRequest = nil;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


@end
