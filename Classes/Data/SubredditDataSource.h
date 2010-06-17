//
//  SubredditDataSource.h
//  Reddit2
//
//  Created by Ross Boucher on 6/8/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@class Story;

@interface SubredditDataSource : TTListDataSource <TTURLRequestDelegate>
{
	NSString *url;
	NSString *title;
	
    NSDate *lastLoadedTime;
    BOOL isLoading;
    BOOL isLoadingMore;
	BOOL canLoadMore;

	TTTableViewController *viewController;
	
	int totalStories;
	int newsModeIndex;
	
	TTURLRequest *activeRequest;
}

@property (nonatomic, assign) TTTableViewController *viewController;
@property (nonatomic, assign) int newsModeIndex;
@property (nonatomic, readonly) BOOL canLoadMore;

- (id)initWithURL:(NSString *)aURL title:(NSString *)aTitle;

- (Story *)storyWithIndex:(int)anIndex;
- (int)totalStories;

- (NSString *)url;
- (NSString *)title;

- (NSString *)newsModeString;
- (int)totalStories;

@end
