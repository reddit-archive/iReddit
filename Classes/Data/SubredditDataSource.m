//
//  SubredditDataSource.m
//  Reddit2
//
//  Created by Ross Boucher on 6/8/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "Story.h"
#import "StoryCell.h"
#import "CommentAccessoryView.h"
#import "AdField.h"
#import "AdMobView.h"
#import "AdCell.h"
#import "Constants.h"

#import "SubredditDataSource.h"
#import "NSDictionary_JSONExtensions.h"
#import "NSDictionary+JSON.h"
#import "SubredditViewController.h"

#define STORIES_BETWEEN_ADS 20
#define AD_OFFSET 17

@implementation SubredditDataSource

@synthesize viewController, newsModeIndex, canLoadMore;

- (id)initWithURL:(NSString *)aURL title:(NSString *)aTitle;
{
	if (self = [super init])
	{
		url = [aURL retain];
		title = [aTitle retain];
		newsModeIndex = 0;
		canLoadMore = YES;
	}
	
	return self;
}

- (void)dealloc
{
	self.viewController = nil;

	[activeRequest cancel];
	[self cancel];

    [lastLoadedTime release];
	[title release];
	[url release];

	[super dealloc];
}

- (NSDate *)loadedTime
{
    return lastLoadedTime;
}

- (BOOL)isLoading
{
    return isLoading;
}

- (BOOL)isLoadingMore
{
    return isLoadingMore;
}

- (BOOL)isLoaded
{
    return lastLoadedTime != nil;
}

- (void)invalidate:(BOOL)erase 
{
	[self.items removeAllObjects];
}

- (void)cancel
{
	[activeRequest cancel];
	activeRequest = nil;
}

- (int)totalStories
{
	return totalStories;
}

- (NSString *)title
{
	return title;
}

- (NSString *)url
{
	return url;
}

- (NSString *)fullURL
{
	return [NSString stringWithFormat:@"%@%@%@%@", RedditBaseURLString, url, [self newsModeString], RedditAPIExtensionString];
}

- (NSString *)newsModeString
{
	switch (newsModeIndex)
	{
		case 0:
			return SubRedditNewsModeHot;
		case 1:
			return SubRedditNewsModeNew;
		case 2:
			return SubRedditNewsModeTop;
		case 3:
			return SubRedditNewsModeControversial;
	}
	
	return @"";
}

- (Story *)storyWithIndex:(int)anIndex
{	
	if (anIndex < 0 || anIndex > [self totalStories])
		return nil;

#ifdef PREMIUM
	return [self.items objectAtIndex:anIndex];
#else
	int actualIndex = anIndex;
	int extra = ( anIndex + AD_OFFSET ) / STORIES_BETWEEN_ADS;
	
	if (extra > 0)
		actualIndex += extra;
	
	return [self.items objectAtIndex:actualIndex];
#endif
}

#pragma mark TTDataSource
//////////////////////////////////////////////////////////////////////////////////////////////////
// TTDataSource

- (void)dataSourceDidStartLoad
{
    isLoading = YES;
    [super dataSourceDidStartLoad];
}

- (void)dataSourceDidFinishLoad
{
    isLoading = NO;
    isLoadingMore = NO;
    [lastLoadedTime release];
    lastLoadedTime = [[NSDate date] retain];
    [super dataSourceDidFinishLoad];
}

- (void)dataSourceDidFailLoadWithError:(NSError*)error
{
    TTLOG(@"TableAsyncDataSource dataSourceDidFailLoadWithError:%@", [error description]);
    isLoading = NO;
    isLoadingMore = NO;
    [super dataSourceDidFailLoadWithError:error];
}

- (void)dataSourceDidCancelLoad
{
    TTLOG(@"TableAsyncDataSource dataSourceDidCancelLoad");
    isLoading = NO;
    isLoadingMore = NO;
    [super dataSourceDidCancelLoad];
}

#pragma mark table view data source 
/////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (void)load:(TTURLRequestCachePolicy)cachePolicy nextPage:(BOOL)nextPage
{	
	if (isLoading)
		return;

	NSString *loadURL = [self fullURL];
	
	if (nextPage)
	{
		id object = [self.items lastObject];
		
		if ([object isKindOfClass:[TTTableMoreButton class]])
			object = [self.items objectAtIndex:[self.items count] - 2];

		Story *story = (Story *)object;
		NSString *lastItemID = story.name;

		loadURL = [NSString stringWithFormat:@"%@%@%@", [self fullURL], MoreItemsFormattedString, lastItemID];
	}
	else
	{
		[self.items removeAllObjects];
		totalStories = 0;
	}
	
	BOOL savedReddit = [[self url] isEqual:@"/saved/"];
	
    activeRequest = [TTURLRequest requestWithURL:loadURL delegate:self];
	activeRequest.cacheExpirationAge = savedReddit ? 0 : 60 * 5;
    activeRequest.cachePolicy = savedReddit ? TTURLRequestCachePolicyNone : TTURLRequestCachePolicyDisk;

    activeRequest.response = [[[TTURLDataResponse alloc] init] autorelease];
    activeRequest.httpMethod = @"GET";
    [activeRequest send];
}

#pragma mark url request delegate
/////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request
{
    [self dataSourceDidStartLoad];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
	activeRequest = nil;
	canLoadMore = NO;
	
	int totalCount = [self.items count];
	
    TTURLDataResponse *response = request.response;
    NSString *responseBody = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];

    // parse the JSON data that we retrieved from the server
    NSDictionary *json = [NSDictionary dictionaryWithJSONString:responseBody error:nil];
    [responseBody release];
    
    // drill down into the JSON object to get the part 
    // that we're actually interested in.
	
	if (![json isKindOfClass:[NSDictionary class]])
	{
	    [self dataSourceDidFinishLoad];
		return;
	}

    NSDictionary *resultSet = [json objectForKey:@"data"];
    NSArray *results = [resultSet objectForKey:@"children"];
    
    // remove any previous items
    //[self.items removeAllObjects];
    
    // now wrap the results from the server into an object
    // that Three20's tableview system can natively display
    // (in this case, it is a TTIconTableField).
	if ([self.items count] && [[self.items lastObject] isKindOfClass:[TTTableMoreButton class]])
		[self.items removeLastObject];
	
    for (NSDictionary *result in results) 
	{     
		NSDictionary *data = [result objectForKey:@"data"];
		
		Story *theStory = [Story storyWithDictionary:data inReddit:self];
		theStory.index = totalStories++;
		
        [self.items addObject:theStory];
#ifndef PREMIUM		
		if (( totalStories + AD_OFFSET ) % STORIES_BETWEEN_ADS == 0)
			[self.items addObject:[AdField new]];
#endif
	}
    
	canLoadMore = [self.items count] > totalCount;

    [self dataSourceDidFinishLoad];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
	activeRequest = nil;
    [self dataSourceDidFailLoadWithError:error];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request
{
	activeRequest = nil;
    [self dataSourceDidCancelLoad];
}

#pragma mark table view delegate stuff

- (void)tableView:(UITableView *)tableView prepareCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
	
	if ([object isKindOfClass:[AdField class]])
	{
		AdField *ad = object;
		
		if (!ad.adView)
		{
			UIView *adView = [AdMobView requestAdWithDelegate:object];
			ad.adView = adView;
		}
		
		CGRect currentFrame = cell.frame;
		CGRect adFrame = ad.adView.frame;
		
		if (currentFrame.size.width > 320)
			adFrame.origin.x = currentFrame.size.width / 2.0 - 160.0;
		else
			adFrame.origin.x = 0;
		
		ad.adView.frame = adFrame;
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		[cell.contentView setBackgroundColor:[ad adBackgroundColor]];
		[cell.contentView removeSubviews];
		[cell.contentView addSubview:ad.adView];
	}
    
	if ([cell isKindOfClass:[StoryCell class]])
	{ 
        StoryCell *storyCell = (StoryCell *)cell;
		storyCell.story = object;
		
		CommentAccessoryView *accessory = nil;

		if (!storyCell.accessoryView)
		{
			accessory = [[[CommentAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 44.0)] autorelease];
			storyCell.accessoryView = accessory;
		}
		else
		{
			accessory = (CommentAccessoryView *)storyCell.accessoryView;
		}
		
		[accessory setCommentCount:storyCell.story.totalComments];

		[accessory setTarget:self action:@selector(accessoryViewTapped:)];
		accessory.story = object;
		
        //storyCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; 
    }
	else
        [super tableView:tableView prepareCell:cell forRowAtIndexPath:indexPath]; 
} 

- (void)accessoryViewTapped:(id)sender
{
	CommentAccessoryView *accessory = (CommentAccessoryView *)[sender superview];
	[(SubredditViewController *)(self.viewController) didSelectAccessoryForObject:accessory.story atIndexPath:[self tableView:self.viewController.tableView indexPathForObject:accessory.story]];
}

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object 
{ 
	if ([object isKindOfClass:[AdField class]])
		return [AdCell class];
    else if ([object isKindOfClass:[Story class]]) 
        return [StoryCell class]; 
    else 
        return [super tableView:tableView cellClassForObject:object]; 
} 

@end
