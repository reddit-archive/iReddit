//
//  RootViewController.h
//  Reddit2
//
//  Created by Ross Boucher on 6/13/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@interface RootViewController : TTTableViewController
{
	NSArray *customSubreddits;
	TTURLRequest *activeRequest;
}

- (NSArray *)topItems;
- (NSArray *)subreddits;
- (NSArray *)extraItems;

@end
