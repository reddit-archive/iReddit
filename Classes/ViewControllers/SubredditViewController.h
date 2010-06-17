//
//  SubredditViewController.h
//  Reddit2
//
//  Created by Ross Boucher on 6/8/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>

@interface SubredditViewController : TTTableViewController 
{
	BOOL			showTabBar;
	TTTableTextItem	*subredditItem;
	TTTabStrip		*tabBar;
	
	NSIndexPath		*savedLocation;
}

- (id)initWithField:(TTTableTextItem*)anItem;

- (void)didSelectAccessoryForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

@end
