//
//  SubredditTableViewDelegate.h
//  iReddit
//
//  Created so we can respond to scroll view events as necessary.
//
//  Created by Ryan Bruels on 12/12/10.
//  Copyright 2010 DevToaster, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@interface SubredditTableViewDelegate : TTTableViewVarHeightDelegate 
{
    TTActivityLabel *_refreshingView;
}

@end
