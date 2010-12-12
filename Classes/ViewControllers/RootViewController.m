//
//  RootViewController.m
//  Reddit2
//
//  Created by Ross Boucher on 6/13/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "RootViewController.h"
#import "iRedditAppDelegate.h"
#import "SubredditViewController.h"
#import "SettingsViewController.h"
#import "NSDictionary+JSON.h"
#import "NSString+HTMLEncoding.h"
#import "LoginController.h"
#import "Constants.h"
#import "MessageViewController.h"
#import "Three20Extensions.h"
#import "AddRedditViewController.h"
#import "Three20/Three20.h"

@interface SubredditTableItem : TTTableTextItem
{
	id tag;
}

@property (nonatomic, retain) id tag;

@end

@implementation SubredditTableItem

@synthesize tag;

+ (id)itemWithText:(NSString *)aString URL:(NSString *)aURL tag:(id)aTag
{
	SubredditTableItem *item = [self itemWithText:aString URL:aURL];
	item.tag = aTag;

	return item;
}

- (void)dealloc
{
	self.tag = nil;
	[super dealloc];
}

@end


@interface SubredditDelegate : TTTableViewDelegate
{
}

@end

@implementation SubredditDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if (sourceIndexPath.section != proposedDestinationIndexPath.section) 
	{
		NSInteger row = 0;
		if (sourceIndexPath.section < proposedDestinationIndexPath.section) 
			row = [self.controller.dataSource tableView:tableView numberOfRowsInSection:sourceIndexPath.section] - 1;

		return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];     
	}
	
	return proposedDestinationIndexPath;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath 
{
	if ([indexPath section] == 1 && [[LoginController sharedLoginController] isLoggedIn] && [[NSUserDefaults standardUserDefaults] boolForKey:useCustomRedditListKey])
		return UITableViewCellEditingStyleDelete;
	else
		return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [indexPath section] == 1 && [self tableView:tableView editingStyleForRowAtIndexPath:indexPath] != UITableViewCellEditingStyleNone;
}

@end

@interface SubredditSectionedDataSource : TTSectionedDataSource
{
}

@end

@implementation SubredditSectionedDataSource

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [indexPath section] == 1;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	NSMutableArray *items = [self itemsInSection:1];
	id item = [[items objectAtIndex:fromIndexPath.row] retain];
	
	[items removeObjectAtIndex:fromIndexPath.row];
	[items insertObject:item atIndex:toIndexPath.row];

	[item release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSMutableArray *items = [self itemsInSection:1];

		SubredditTableItem *item = [[items objectAtIndex:indexPath.row] retain];

		[items removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

		if (item.tag)
		{
			TTURLRequest *request = [TTURLRequest requestWithURL:[NSString stringWithFormat:@"%@%@", RedditBaseURLString, RedditSubscribeAPIString] delegate:nil];
			request.cachePolicy = TTURLRequestCachePolicyNoCache;
			request.cacheExpirationAge = 0;
			
			request.contentType = @"application/x-www-form-urlencoded";
			request.httpMethod = @"POST";
			request.httpBody = [[NSString stringWithFormat:@"uh=%@&sr=%@&action=unsub",
								 [[LoginController sharedLoginController] modhash], item.tag]
								dataUsingEncoding:NSASCIIStringEncoding];

			[request send];
		}

		[item release];
	}
}

@end

@implementation RootViewController

- (id)init
{
	if (self = [super init])
	{
		self.title = @"Home";
		self.navigationBarTintColor = [iRedditAppDelegate redditNavigationBarTintColor];
		self.hidesBottomBarWhenPushed = YES;
        self.tableViewStyle = UITableViewStyleGrouped;
		
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(messageCountChanged:) name:MessageCountDidChangeNotification object:nil];
		[center addObserver:self selector:@selector(didEndLogin:) name:RedditDidFinishLoggingInNotification object:nil];
		[center addObserver:self selector:@selector(didAddReddit:) name:RedditWasAddedNotification object:nil];
	}

	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[customSubreddits release];
	[activeRequest cancel];
	
	[super dealloc];
}

- (void)loadView
{
	[super loadView];
	
    UIImage *mainTitleImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mainTitle" ofType:@"png"]];
	self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:mainTitleImage] autorelease];
	[mainTitleImage release];
	
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)] autorelease];

	[self.view addSubview:self.tableView];
}

- (void)viewDidLoad {

}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationBarTintColor = [iRedditAppDelegate redditNavigationBarTintColor];
    self.tableView.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:238.0/255.0 blue:1 alpha:1];
	self.tableView.allowsSelectionDuringEditing = NO;
	self.tableView.editing = NO;

	if ([[LoginController sharedLoginController] isLoggedIn] && [[NSUserDefaults standardUserDefaults] boolForKey:useCustomRedditListKey])
		self.navigationItem.leftBarButtonItem =  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)] autorelease];
	else
		self.navigationItem.leftBarButtonItem = nil;
	
	[super viewWillAppear:animated];
}

- (void)add:(id)sender
{
	[self presentModalViewController:[[[AddRedditViewController alloc] init] autorelease] animated:YES];
}

- (void)edit:(id)sender
{
	shouldDetectDeviceShake = NO;

	self.tableView.editing = YES;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(stopEditing:)] autorelease];
}

- (void)stopEditing:(id)sender
{
	self.tableView.editing = NO;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)] autorelease];

	NSMutableArray *order = [NSMutableArray array];
	
	TTSectionedDataSource *ds = (TTSectionedDataSource *)self.dataSource;
	NSArray *items = [ds itemsInSection:1];
	
	for (SubredditTableItem *item in items)
	{
		[order addObject:item.URL];
	}

	[[NSUserDefaults standardUserDefaults] setObject:order forKey:redditSortOrderKey];
	[[NSUserDefaults standardUserDefaults] synchronize];

	shouldDetectDeviceShake = YES;
}

- (void)messageCountChanged:(NSNotification *)note
{
	unsigned int count = [[iRedditAppDelegate sharedAppDelegate].messageDataSource unreadMessageCount];
    NSLog(@"CHANGED!!!! %d", count);
    
	if (count > 0)
		self.title = [NSString stringWithFormat:@"Home (%u)", count];
	else
		self.title = @"Home";
    
    [self createModel];
	[self.tableView reloadData];
}

- (void)didEndLogin:(NSNotification *)note
{	
    
	[customSubreddits release];
	customSubreddits = nil;
	[activeRequest cancel];
	activeRequest = nil;

	if ([[LoginController sharedLoginController] isLoggedIn]  && [[NSUserDefaults standardUserDefaults] boolForKey:useCustomRedditListKey])
		self.navigationItem.leftBarButtonItem =  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)] autorelease];
	else
		self.navigationItem.leftBarButtonItem = nil;

	if (![[LoginController sharedLoginController] isLoggedIn] || ![[NSUserDefaults standardUserDefaults] boolForKey:useCustomRedditListKey])
		return;

    NSString *url = [NSString stringWithFormat:@"%@%@?limit=500", RedditBaseURLString, CustomRedditsAPIString];

	activeRequest = [TTURLRequest requestWithURL:url delegate:(id <TTURLRequestDelegate>)self];
	activeRequest.response = [[[TTURLDataResponse alloc] init] autorelease];
	activeRequest.cacheExpirationAge = 0;
	activeRequest.cachePolicy = TTURLRequestCachePolicyNoCache;

	[activeRequest send];
	
    [self createModel];
	[self.tableView reloadData];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
	activeRequest = nil;

    TTURLDataResponse *response = request.response;
    NSString *responseBody = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
	
    // parse the JSON data that we retrieved from the server
    NSDictionary *json = [NSDictionary dictionaryWithJSONString:responseBody error:nil];
    [responseBody release];
    
    NSLog(@"REDDITS LOADED");
    
    // drill down into the JSON object to get the part 
    // that we're actually interested in.
	
	if (![json isKindOfClass:[NSDictionary class]] || ![json objectForKey:@"data"])
	{
        [self createModel];
		[self.tableView reloadData];
		return;
	}

	NSDictionary *data = [json objectForKey:@"data"];
	NSMutableArray *loadedReddits = [NSMutableArray array];
	NSArray *children = [data objectForKey:@"children"];
	
	for (int i=0, count=[children count]; i<count; i++)
	{
		NSDictionary *thisReddit = [[children objectAtIndex:i] objectForKey:@"data"];
		[loadedReddits addObject:[SubredditTableItem itemWithText:[[thisReddit objectForKey:@"title"] stringByDecodingHTMLEncodedCharacters]
															  URL:[thisReddit objectForKey:@"url"]
															  tag:[thisReddit objectForKey:@"name"]]];
	}	

	customSubreddits = [loadedReddits copy];
    [self createModel];
	[self.tableView reloadData];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
	activeRequest = nil;
    [self createModel];
	[self.tableView reloadData];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request
{
	activeRequest = nil;
    [self createModel];
	[self.tableView reloadData];
}

- (void)didAddReddit:(NSNotification *)note
{
	if ([(AddRedditViewController *)[note object] shouldViewOnly])
	{
		NSDictionary *redditInfo = (NSDictionary *)[note userInfo];
		SubredditViewController *controller = [[[SubredditViewController alloc] initWithField:
													[TTTableTextItem itemWithText:[redditInfo objectForKey:@"subreddit"] 
																			  URL:[redditInfo objectForKey:@"subreddit_url"]]] 
											   autorelease];

		[[self navigationController] pushViewController:controller animated:YES];
	}
	else
	{
		NSDictionary *redditInfo = (NSDictionary *)[note userInfo];

		if (!customSubreddits)
			return;

		for (int i=0, count = [customSubreddits count]; i<count; i++)
		{
			SubredditTableItem *item = [customSubreddits objectAtIndex:i];
			
			if ([item.URL isEqual:[redditInfo objectForKey:@"subreddit_url"]])
			{
				NSLog(@"HERE");
				NSMutableArray *items = [customSubreddits mutableCopy];
				
				id item = [[items objectAtIndex:i] retain];
				
				[items removeObjectAtIndex:i];
				[items insertObject:item atIndex:0];

				[item release];
				
				[customSubreddits release];
				customSubreddits = items;

				NSArray *sortOrder = [[NSUserDefaults standardUserDefaults] objectForKey:redditSortOrderKey];
				NSMutableArray *newSortOrder = [NSMutableArray arrayWithArray:sortOrder];
				
				int currentIndex = [sortOrder indexOfObject:[redditInfo objectForKey:@"subreddit_url"]];
				
				if (currentIndex != NSNotFound)
					[newSortOrder removeObjectAtIndex:currentIndex];

				[newSortOrder insertObject:[redditInfo objectForKey:@"subreddit_url"] atIndex:0];
				
				[[NSUserDefaults standardUserDefaults] setObject:newSortOrder forKey:redditSortOrderKey];
				[[NSUserDefaults standardUserDefaults] synchronize];

                [self createModel];
				[self.tableView reloadData];
		
				return;
			}
		}

		TTURLRequest *request = [TTURLRequest requestWithURL:[NSString stringWithFormat:@"%@%@", RedditBaseURLString, RedditSubscribeAPIString] delegate:nil];
		request.cachePolicy = TTURLRequestCachePolicyNoCache;
		request.cacheExpirationAge = 0;

		request.contentType = @"application/x-www-form-urlencoded";
		request.httpMethod = @"POST";
		request.httpBody = [[NSString stringWithFormat:@"uh=%@&sr=%@&action=sub", 
							 [[LoginController sharedLoginController] modhash], [redditInfo objectForKey:@"subreddit_id"]]
							dataUsingEncoding:NSASCIIStringEncoding];

		[request send];

		SubredditTableItem *newRedditField = [SubredditTableItem itemWithText:[redditInfo objectForKey:@"subreddit"]
																		  URL:[redditInfo objectForKey:@"subreddit_url"]
																		  tag:[redditInfo objectForKey:@"subreddit_id"]];

		NSMutableArray *newRedditList = [customSubreddits mutableCopy];
		[newRedditList insertObject:newRedditField atIndex:0];

		[customSubreddits release];
		customSubreddits = newRedditList;

		NSArray *sortOrder = [[NSUserDefaults standardUserDefaults] objectForKey:redditSortOrderKey];
		NSMutableArray *newSortOrder = [NSMutableArray arrayWithArray:sortOrder];

		[newSortOrder insertObject:[redditInfo objectForKey:@"subreddit_url"] atIndex:0];

		[[NSUserDefaults standardUserDefaults] setObject:newSortOrder forKey:redditSortOrderKey];
		[[NSUserDefaults standardUserDefaults] synchronize];

        [self createModel];
		[self.tableView reloadData];
	}
}

- (NSArray *)subreddits
{
	BOOL useCustomReddits = [[NSUserDefaults standardUserDefaults] boolForKey:useCustomRedditListKey];
	
	NSMutableArray *result = [NSMutableArray array];
	
	//TTActivityTableField
	if (customSubreddits && useCustomReddits)
	{
		[result addObjectsFromArray:customSubreddits];
	}
	else if (useCustomReddits && ([[LoginController sharedLoginController] isLoggingIn] || activeRequest))
	{
		[result addObject:[TTTableActivityItem itemWithText:@"Loading custom reddits..."]];
	}
	else
	{
		[result addObjectsFromArray:
			[NSArray arrayWithObjects:	
					[TTTableTextItem itemWithText:@"reddit.com" URL:@"/r/reddit.com/"],
					[TTTableTextItem itemWithText:@"programming" URL:@"/r/programming/"],
					[TTTableTextItem itemWithText:@"pics" URL:@"/r/pics/"],
					[TTTableTextItem itemWithText:@"politics" URL:@"/r/politics/"],
					[TTTableTextItem itemWithText:@"technology" URL:@"/r/technology/"],
					[TTTableTextItem itemWithText:@"world news" URL:@"/r/worldnews/"],
					[TTTableTextItem itemWithText:@"best of reddit" URL:@"/r/bestof/"],
				nil]
		 ];
	}
	
	[result sortUsingSelector:@selector(sortForRedditOrder:)];
	
	return result;
}

- (NSArray *)extraItems
{
	return [NSArray arrayWithObjects:
				[TTTableTextItem itemWithText:@"All reddits combined" URL:@"/r/all/"], 
				[TTTableTextItem itemWithText:@"Other reddit..." URL:@"/other"], 
			nil];

}

- (NSArray *)topItems
{
	TTTableItem *homeField = [TTTableTextItem itemWithText:@"reddit Front Page" URL:@"/"];

	if ([[LoginController sharedLoginController] isLoggedIn])
	{
		unsigned int count = [[iRedditAppDelegate sharedAppDelegate].messageDataSource unreadMessageCount];
		NSString *mailboxString = count > 0 ? [NSString stringWithFormat:@"Inbox (%u)", count] : @"Inbox";

		TTTableItem *saved = [TTTableTextItem itemWithText:@"Saved" URL:@"/saved/"];
		TTTableItem *mailboxField = [TTTableTextItem itemWithText:mailboxString URL:@"/messages/"];
	
		return [NSArray arrayWithObjects:homeField, mailboxField, saved, nil];
	}
	else 
		return [NSArray arrayWithObject:homeField];
}

- (id<UITableViewDelegate>)createDelegate 
{
	return [[[SubredditDelegate alloc] initWithController:self] autorelease];
}

-(void)createModel 
{
	NSArray *topItems   = [self topItems];
	NSArray *subreddits = [self subreddits];
	NSArray *extra      = [self extraItems];
	NSArray *settingsItems = [NSArray arrayWithObjects:[TTTableTextItem itemWithText:@"Settings" URL:@"/settings/"], nil];
	
	self.dataSource = [SubredditSectionedDataSource dataSourceWithArrays:@"", topItems, @"reddits", subreddits, @"", extra, @"", settingsItems, nil];
    [self.tableView reloadData];
}

- (void)didSelectObject:(TTTableLinkedItem *)object atIndexPath:(NSIndexPath*)indexPath
{
	[super didSelectObject:object atIndexPath:indexPath];
	
	if ([object.URL isEqual:@"/messages/"])
	{
		MessageViewController *controller = [[[MessageViewController alloc] init] autorelease];
		[[self navigationController] pushViewController:controller animated:YES];
	}
	else if ([object isKindOfClass:[TTTableActivityItem class]])
	{
		//do it
	}
	else if ([object.URL isEqual:@"/settings/"])
	{
		SettingsViewController *controller = [[[SettingsViewController alloc] init] autorelease];
		[[self navigationController] pushViewController:controller animated:YES];
	}
	else if ([object.URL isEqual:@"/other"])
	{
		[self presentModalViewController:[[[AddRedditViewController alloc] initForViewing] autorelease] animated:YES];
	}
	else
	{
		SubredditViewController *controller = [[[SubredditViewController alloc] initWithField:(TTTableTextItem *)object] autorelease];
		[[self navigationController] pushViewController:controller animated:YES];
	}

	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:allowLandscapeOrientationKey] ? YES : UIInterfaceOrientationIsPortrait(interfaceOrientation) ; 
}

@end

@implementation TTTableItem (RedditSorting)

- (int)sortForRedditOrder:(SubredditTableItem *)otherField
{
	return NSOrderedSame;
}

@end

@implementation SubredditTableItem (RedditSorting)

- (int)sortForRedditOrder:(SubredditTableItem *)otherField
{
	NSArray *sortedURLs = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:redditSortOrderKey];
	
	int index = [sortedURLs indexOfObject:self.URL];
	int otherIndex = [sortedURLs indexOfObject:otherField.URL];
	
	if (index > otherIndex)
		return NSOrderedDescending;
	else if (index < otherIndex)
		return NSOrderedAscending;
	else
		return NSOrderedSame;
}

@end

