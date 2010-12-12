//
//  SubredditDataSource.h
//  Reddit2
//
//  Created by Ross Boucher on 6/8/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "SubredditDataModel.h"

@class Story;

@interface SubredditDataSource : TTListDataSource <TTURLRequestDelegate>
{
    SubredditDataModel *_subredditModel;
    
	NSString *url;
	NSString *title;
	
    NSDate *lastLoadedTime;

	TTTableViewController *viewController;
}

@property (nonatomic, assign) TTTableViewController *viewController;

+ (SubredditDataSource *)lastLoadedSubreddit;
- (id)initWithSubreddit:(NSString *)subreddit;
- (Story *)storyWithIndex:(int)anIndex;

@end
