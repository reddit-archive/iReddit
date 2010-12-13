//
//  iRedditAppDelegate.h
//  iReddit
//
//  Created by Ross Boucher on 6/18/09.
//  Copyright 280 North 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SubredditDataSource.h"
#import "StoryViewController.h"
#import "MessageDataSource.h"

@interface iRedditAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
	UINavigationController *navController;
	
	SubredditDataSource *randomDataSource;
	StoryViewController *randomController;
	
	MessageDataSource *messageDataSource;
    NSTimer *messageTimer;
    
	SystemSoundID shakingSound;
}

+ (UIColor *)redditNavigationBarTintColor;
+ (iRedditAppDelegate *)sharedAppDelegate;

- (void)reloadSound;
- (void)showRandomStory;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) MessageDataSource *messageDataSource;

@end
