//
//  AddRedditViewController.m
//  iReddit
//
//  Created by Ross Boucher on 7/2/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "AddRedditViewController.h"
#import "iRedditAppDelegate.h"
#import "Constants.h"
#import "Three20Extensions.h"
#import "NSDictionary+JSON.h"

@implementation AddRedditViewController

@synthesize navigationBar;

- (IBAction)cancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	TTTableControlCell *cell = (TTTableControlCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	UITextField *textField = cell.control;
	if (textField)
	{
		[self loadReddit:textField.text];
	}	
}

- (id)initForViewing
{
	if (self = [super init])
	{
		shouldViewOnly = YES;
	}
	
	return self;
}

- (void)loadView
{
	self.navigationBarTintColor = [iRedditAppDelegate redditNavigationBarTintColor];

    [super loadView];

	self.navigationBar = [[[UINavigationBar alloc] init] autorelease];
	
	[self.navigationBar sizeToFit];
	
	UINavigationItem *item = nil;
	if (shouldViewOnly)
	{
		item = [[[UINavigationItem alloc] initWithTitle:@"view reddit"] autorelease];
		item.prompt = @"View any reddit by entering a URL";
	}
	else
	{
		item = [[[UINavigationItem alloc] initWithTitle:@"add reddit"] autorelease];
		item.prompt = @"Subscribe to a new reddit by entering a URL";
	}
	
	item.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
	item.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)] autorelease];

	self.navigationBar.tintColor = [iRedditAppDelegate redditNavigationBarTintColor];
	
	[self.navigationBar pushNavigationItem:item animated:NO];
	
	self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0.0, 75.0, self.view.bounds.size.width, self.view.bounds.size.height - 75.0) style:UITableViewStyleGrouped] autorelease];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.tableView.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:238.0/255.0 blue:1 alpha:1];
	
	self.tableView.allowsSelectionDuringEditing = NO;
	self.tableView.editing = NO;
	
	[self.view addSubview:self.navigationBar];
	[self.view addSubview:self.tableView];

	[self performSelector:@selector(focus) withObject:nil afterDelay:0.5];
}

-(void)createModel 
{
	TTTableControlItem *item = [SettingsControlItem textFieldControlWithTitle:@"reddit.com/r/" text:@"" placeholder:@"pics" key:@"" secure:NO];	
	UITextField *textField = (UITextField *)item.control;
	
	textField.keyboardType = UIKeyboardTypeURL;
	textField.returnKeyType = UIReturnKeyGo;
	textField.delegate = (id <UITextFieldDelegate>)self;
		 
	if (activeRequest)
	{
		TTTableActivityItem *informationField = [TTTableActivityItem itemWithText:@"Loading reddit..."];
		self.dataSource = [TTSectionedDataSource dataSourceWithArrays:@"Enter a reddit URL (e.g. /r/pics)", [NSArray arrayWithObject:item], @"", [NSArray arrayWithObject:informationField], nil];
	}
	else
		self.dataSource = [TTSectionedDataSource dataSourceWithArrays:@"Enter a reddit URL (e.g. /r/pics)", [NSArray arrayWithObject:item], nil];	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

/*
	UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] firstViewOfClass:[UILabel class]];
	label.font = [UIFont boldSystemFontOfSize:14.0];
*/
}

- (void)focus
{
	/*
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	
	UITextField *textField = (UITextField *)[cell firstViewOfClass:[UITextField class]];

	if (textField)
	{
		//fixme this doesn't belong here.
		textField.enablesReturnKeyAutomatically = YES;
		[textField becomeFirstResponder];
		return;
	}
    */
}

- (BOOL)textFieldShouldReturn:(UITextField *)aField
{	
	[self loadReddit:aField.text];
	return YES;
}

- (void)loadReddit:(NSString *)redditURL
{
	if (activeRequest)
		return;

	NSString *url = [NSString stringWithFormat:@"%@/r/%@/.json", RedditBaseURLString, redditURL];

	activeRequest = [TTURLRequest requestWithURL:url delegate:(id <TTURLRequestDelegate>)self];
	
	activeRequest.response = [[[TTURLDataResponse alloc] init] autorelease];
	activeRequest.cacheExpirationAge = 0;
	activeRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
	
	[activeRequest send];
	
	[self updateView];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
	activeRequest = nil;
	
    TTURLDataResponse *response = request.response;
    NSString *responseBody = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
	
	NSError *error = nil;
    // parse the JSON data that we retrieved from the server
    NSDictionary *json = [NSDictionary dictionaryWithJSONString:responseBody error:&error];
    [responseBody release];
    
	if (error != nil || ![json isKindOfClass:[NSDictionary class]] || ![json objectForKey:@"data"])
	{
		[self requestFailed];
		[self updateView];
		return;
	}
	
	NSDictionary *data = [json objectForKey:@"data"];
	NSArray *children = [data objectForKey:@"children"];
	
	if (![children count])
	{
		[self requestFailed];
		[self updateView];
		return;
	}
	
	NSDictionary *firstStory = [[children objectAtIndex:0] objectForKey:@"data"];
	NSMutableDictionary *completeRedditInfo = [NSMutableDictionary dictionaryWithDictionary:firstStory];
	
	NSString *url = [request.URL substringFromIndex:NSMaxRange([request.URL rangeOfString:RedditBaseURLString])];
	url = [url stringByReplacingOccurrencesOfString:@".json" withString:@""];
	
	[completeRedditInfo setObject:url forKey:@"subreddit_url"]; 
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RedditWasAddedNotification object:self userInfo:completeRedditInfo];
	
	[self updateView];
	
	[self performSelector:@selector(cancel:) withObject:self afterDelay:1.0];
}

- (BOOL)shouldViewOnly
{
	return shouldViewOnly;
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
	activeRequest = nil;
	[self requestFailed];
	[self updateView];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request
{
	activeRequest = nil;
	[self updateView];
}

- (void)requestFailed
{
	[[[[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"This is not the reddit you were looking for. We couldn't find anything at that URL. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
}

- (void)viewDidUnload 
{
	self.navigationBar = nil;
	[super viewDidUnload];
}

- (void)dealloc 
{
	[activeRequest cancel];
	activeRequest = nil;
	
	self.navigationBar = nil;
    [super dealloc];
}

@end
