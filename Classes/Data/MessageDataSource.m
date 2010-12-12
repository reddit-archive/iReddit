//
//  MessageDataSource.m
//  Reddit2
//
//  Created by Ross Boucher on 6/16/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "MessageDataSource.h"
#import "NSDictionary+JSON.h"
#import "Constants.h"
#import "RedditMessage.h"
#import "MessageCell.h"
#import "LoginController.h"

@implementation MessageDataSource

- (id)init
{
	if (self = [super init])
	{
		canLoadMore = YES;
	}

	return self;
}

- (void)dealloc
{	
	[self cancel];	
    [lastLoadedTime release];
	[super dealloc];
}

- (BOOL)canLoadMore
{
	return canLoadMore;
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

#pragma mark TTDataSource
//////////////////////////////////////////////////////////////////////////////////////////////////
// TTDataSource

- (void)didStartLoad
{
    isLoading = YES;
}

- (void)didFinishLoad
{
    isLoading = NO;
    isLoadingMore = NO;
    [lastLoadedTime release];
    lastLoadedTime = [[NSDate date] retain];
}

- (void)didFailLoadWithError:(NSError*)error
{
    isLoading = NO;
    isLoadingMore = NO;
}

- (void)didCancelLoad
{
    isLoading = NO;
    isLoadingMore = NO;
}

- (unsigned int)unreadMessageCount
{
	return unreadMessageCount;
}

- (unsigned int)messageCount
{
	return [self.items count];
}


#pragma mark table view data source 

/////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (NSString *)fullURL
{
    return [NSString stringWithFormat:@"%@%@", RedditBaseURLString, RedditMessagesAPIString];	
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{	
	NSString *loadURL = [self fullURL];

	if (more)
	{
		id object = [self.items lastObject];
		
		if ([object isKindOfClass:[TTTableMoreButton class]])
			object = [self.items objectAtIndex:[self.items count] - 2];
		
		RedditMessage *lastMessage = (RedditMessage *)object;
		loadURL = [NSString stringWithFormat:@"%@&after=%@", loadURL, lastMessage.name];
	}
	else
	{
		// remove any previous items
		[self.items removeAllObjects];
		unreadMessageCount = 0;		
	}
	
    activeRequest = [TTURLRequest requestWithURL:loadURL delegate:self];
    activeRequest.shouldHandleCookies = [[LoginController sharedLoginController] isLoggedIn] ? YES : NO;
    activeRequest.cacheExpirationAge = 0;
    activeRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
    activeRequest.response = [[[TTURLDataResponse alloc] init] autorelease];
    activeRequest.httpMethod = @"GET";

    [activeRequest send];
}

#pragma mark url request delegate
/////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request
{
    [self didStartLoad];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
	activeRequest = nil;
	canLoadMore = NO;

	int totalCount = [self.items count];

    TTURLDataResponse *response = request.response;
    NSString *responseBody = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
	
    NSDictionary *json = [NSDictionary dictionaryWithJSONString:responseBody error:nil];

    [responseBody release];
    
	if (![json isKindOfClass:[NSDictionary class]])
	{
	    [self didFinishLoad];
		return;
	}

    NSArray *results = [[json objectForKey:@"data"] objectForKey:@"children"];	
	
	if ([self.items count] && [[self.items lastObject] isKindOfClass:[TTTableMoreButton class]])
		[self.items removeLastObject];

	unreadMessageCount = 0;
    for (NSDictionary *result in results) 
	{     
		RedditMessage *newMessage = [RedditMessage messageWithDictionary:[result objectForKey:@"data"]];
		if (newMessage) 
		{
			[self.items	addObject:newMessage];
			
			if (newMessage.isNew)
				unreadMessageCount++;
		}
	}
    
	canLoadMore = [self.items count] > totalCount;
	    
    [self didFinishLoad];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:MessageCountDidChangeNotification object:nil];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
	activeRequest = nil;
    [self didFailLoadWithError:error];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request
{
	activeRequest = nil;
    [self didCancelLoad];
}

#pragma mark table view delegate stuff

- (void)tableView:(UITableView *)tableView cell:(UITableViewCell *)cell willAppearAtIndexPath:(NSIndexPath *)indexPath 
{ 
	id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
	
	if ([cell isKindOfClass:[MessageCell class]])
	{
		MessageCell *messageCell = (MessageCell *)cell;
		messageCell.message = (RedditMessage *)object;
		
		messageCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	else
        [super tableView:tableView cell:cell willAppearAtIndexPath:indexPath]; 
} 

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object 
{
	if ([object isKindOfClass:[RedditMessage class]])
		return [MessageCell class];
	else
		return [super tableView:tableView cellClassForObject:object]; 
} 

@end
