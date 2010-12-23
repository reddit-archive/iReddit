//
//  iRedditAppDelegate.m
//  iReddit
//
//  Created by Ross Boucher on 6/18/09.
//  Copyright 280 North 2009. All rights reserved.
//

#import "iRedditAppDelegate.h"
#import "RootViewController.h"
#import "SubredditViewController.h"
#import "Story.h"
#import "Constants.h"
#import "LoginController.h"

#define SEEN_DEPRECATED_NOTICE @"ireddit-free-seen-deprecated"

extern NSMutableArray *visitedArray;

iRedditAppDelegate *sharedAppDelegate;

@implementation iRedditAppDelegate

+ (UIColor *)redditNavigationBarTintColor
{
	return [UIColor colorWithRed:60.0/255.0 green:120.0/255.0 blue:225.0/255.0 alpha:1.0];
}

+ (iRedditAppDelegate *)sharedAppDelegate
{
	return sharedAppDelegate;
}

@synthesize window, navController, messageDataSource;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    	    
	sharedAppDelegate = self;
	
	//register defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
#ifdef DEPRECATED_FREE
    if(![defaults boolForKey:SEEN_DEPRECATED_NOTICE])
    {
        UIAlertView *deprecatedAlert = [[UIAlertView alloc] initWithTitle:@"Goodbye, iReddit Free!" 
        message:@"iReddit Free will no longer be supported or updated. Please download the new iReddit for FREE from App Store to keep up with future updates!"
        delegate:self 
        cancelButtonTitle:nil 
        otherButtonTitles:@"OK", nil];
        [deprecatedAlert show];
        [deprecatedAlert release];
    }
#endif

	[defaults registerDefaults:
         [NSDictionary dictionaryWithObjectsAndKeys:
              [NSNumber numberWithBool:YES], showStoryThumbnailKey,
              [NSNumber numberWithBool:YES], shakeForStoryKey,
              [NSNumber numberWithBool:YES], playSoundOnShakeKey,
              [NSNumber numberWithBool:YES], useCustomRedditListKey,
              [NSNumber numberWithBool:YES], showLoadingAlienKey,
              [NSArray array], visitedStoriesKey,
              [NSArray array], redditSortOrderKey,
              redditSoundLightsaber, shakingSoundKey,
              [NSNumber numberWithBool:YES], allowLandscapeOrientationKey,
              @"/", initialRedditURLKey,
              @"Front Page", initialRedditTitleKey,
              nil
            ]
	  ];		
	
    self.navController = [[[UINavigationController alloc] initWithRootViewController:[[[RootViewController alloc] init] autorelease]] autorelease];
	self.navController.delegate = (id <UINavigationControllerDelegate>)self;
	navController.toolbarHidden = NO;
	[window addSubview:navController.view];
	
	NSString *initialRedditURL = [[NSUserDefaults standardUserDefaults] stringForKey:initialRedditURLKey];
	NSString *initialRedditTitle = [[NSUserDefaults standardUserDefaults] stringForKey:initialRedditTitleKey];
	
	SubredditViewController *controller = [[[SubredditViewController alloc] initWithField:[TTTableTextItem itemWithText:initialRedditTitle URL:initialRedditURL]] autorelease];
	[navController pushViewController:controller animated:NO];

	
	//login
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndLogin:) name:RedditDidFinishLoggingInNotification object:nil];
	[[LoginController sharedLoginController] loginWithUsername:[defaults stringForKey:redditUsernameKey] password:[defaults stringForKey:redditPasswordKey]];
	
	shakingSound = 0;
	[self reloadSound];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(deviceDidShake:)
                                          name:DeviceDidShakeNotification
                                          object:nil]; 
	
    randomDataSource = [[SubredditDataSource alloc] initWithSubreddit:@"/randomrising/"];
    [self loadRandomData];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SEEN_DEPRECATED_NOTICE];
}

- (void)deviceDidShake:(NSNotification *)notif
{
    if(shouldDetectDeviceShake)
    {   
        if ([[NSUserDefaults standardUserDefaults] boolForKey:playSoundOnShakeKey]) 
		{
			AudioServicesPlaySystemSound(shakingSound);
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		}
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:shakeForStoryKey])
			[self showRandomStory];
    }
}

- (void)didEndLogin:(NSNotification *)notif
{    
    if([[LoginController sharedLoginController] isLoggedIn] && !messageDataSource && !messageTimer)
    {
        messageDataSource = [[MessageDataSource alloc] init];
        [messageDataSource.model load:TTURLRequestCachePolicyNoCache more:NO];

        messageTimer = [[NSTimer scheduledTimerWithTimeInterval:60.0
                                 target:self
                                 selector:@selector(reloadMessages)
                                 userInfo:nil
                                 repeats:YES] retain];
    }
    else
    {
        [messageDataSource cancel];
        [messageDataSource release];
        messageDataSource = nil;
        
        [messageTimer invalidate];
        [messageTimer release];
        messageTimer = nil;
    }
}

- (void)reloadMessages
{
    [messageDataSource.model load:TTURLRequestCachePolicyNoCache more:NO];
}

- (void)loadRandomData
{
	[randomDataSource.model load:TTURLRequestCachePolicyNoCache more:NO];
    [self performSelector:@selector(loadRandomData) withObject:nil afterDelay:60.0];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{	
	// Save data if appropriate
	[[NSUserDefaults standardUserDefaults] setObject:[visitedArray subarrayWithRange:NSMakeRange(0, MIN(500, [visitedArray count]))]
											  forKey:visitedStoriesKey];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	//[[Beacon shared] endBeacon];
}

- (void)reloadSound
{
	if (shakingSound != 0)
		AudioServicesDisposeSystemSoundID(shakingSound);
	
	NSString *path = [[NSBundle mainBundle] pathForResource:[[NSUserDefaults standardUserDefaults] stringForKey:shakingSoundKey] ofType:@"pcm"];
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &shakingSound);
}

- (void)dealloc 
{
	self.navController = nil;
	self.messageDataSource = nil;
	
    [messageTimer invalidate];
    [messageTimer release];
    
	AudioServicesDisposeSystemSoundID(shakingSound);
    
	[window release];
    [super dealloc];
}

- (void)showRandomStory
{
	if (!randomDataSource || ![randomDataSource.model isLoaded])
		return;

	if (!randomController)
	{
		randomController= [[StoryViewController alloc] init];
		//[[Beacon shared] startSubBeaconWithName:@"serendipityTime" timeSession:YES];
	}
	
    NSInteger count = [(SubredditDataModel *)randomDataSource.model totalStories];
	NSInteger randomIndex = count > 0 ? arc4random() % count : 0;
	
	Story *story = nil;
	
	int i=0;
	while (!story && i++ < count)
	{
		story = [randomDataSource storyWithIndex:(randomIndex++)%count];

		if ([story visited] && i < count - 1)
			story = nil;
	}
	
	if (!story)
	{
		[randomDataSource.model load:TTURLRequestCachePolicyDefault more:YES];
		return;
	}

	if (navController.topViewController != randomController)
	{
		if (![navController.viewControllers containsObject:randomController])
			[navController pushViewController:randomController animated:YES];
		else if ([navController.topViewController isKindOfClass:[StoryViewController class]])
			[(StoryViewController *)(navController.topViewController) setStory:story];
	}
	
	[randomController setStory:story];

	//[[Beacon shared] startSubBeaconWithName:@"shakeForStory" timeSession:NO];
}

- (void)dismissRandomViewController
{
	//[[Beacon shared] endSubBeaconWithName:@"serendipityTime"];
	
	[messageDataSource release];
	messageDataSource = nil;
	
	[randomController release];	
	randomController = nil;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if (![navigationController.viewControllers containsObject:randomController])
	{
		[randomController release];
		randomController = nil;
	}
}

@end

