//
//  MessageDataSource.h
//  Reddit2
//
//  Created by Ross Boucher on 6/16/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@interface MessageDataSource : TTListDataSource <TTURLRequestDelegate>
{	
    NSDate *lastLoadedTime;
    BOOL isLoading;
    BOOL isLoadingMore;
	BOOL canLoadMore;

	unsigned int unreadMessageCount;
	
	TTURLRequest *activeRequest;
}

- (NSString *)fullURL;
- (unsigned int)unreadMessageCount;
// marking as read doesn't actually work from the API, so let's not pretend it does
//- (void)markRead:(id)sender;
- (BOOL)canLoadMore;

@end
