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
	
	[defaults registerDefaults:
	 [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
										  [NSNumber numberWithBool:YES],
										  [NSNumber numberWithBool:YES],
										  [NSNumber numberWithBool:YES],	
										  [NSNumber numberWithBool:NO],
										  [NSNumber numberWithBool:YES],
										  [NSArray array],
										  [NSArray array],
										  redditSoundLightsaber,
										  [NSNumber numberWithBool:YES],
										  @"/",
										  @"Front Page",
										  nil
										  ] 
								 forKeys:[NSArray arrayWithObjects:
										  showStoryThumbnailKey,
										  shakeForStoryKey,
										  playSoundOnShakeKey,
										  useCustomRedditListKey,
										  showLoadingAlienKey,
										  visitedStoriesKey,
										  redditSortOrderKey,
										  shakingSoundKey,
										  allowLandscapeOrientationKey,
										  initialRedditURLKey,
										  initialRedditTitleKey,
										  nil
										  ]
	  ]];		
	
    self.navController = [[[UINavigationController alloc] initWithRootViewController:[[[RootViewController alloc] init] autorelease]] autorelease];
	self.navController.delegate = (id <UINavigationControllerDelegate>)self;
	navController.toolbarHidden = NO;
	[window addSubview:navController.view];
	
	NSString *initialRedditURL = [[NSUserDefaults standardUserDefaults] stringForKey:initialRedditURLKey];
	NSString *initialRedditTitle = [[NSUserDefaults standardUserDefaults] stringForKey:initialRedditTitleKey];
	
	SubredditViewController *controller = [[[SubredditViewController alloc] initWithField:[TTTableTextItem itemWithText:initialRedditTitle URL:initialRedditURL]] autorelease];
	[navController pushViewController:controller animated:NO];

	
	//login
	[[LoginController sharedLoginController] loginWithUsername:[defaults stringForKey:redditUsernameKey] password:[defaults stringForKey:redditPasswordKey]];
	
	shakingSound = 0;
	[self reloadSound];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(deviceDidShake:)
                                          name:DeviceDidShakeNotification
                                          object:nil]; 
	
	[self performSelector:@selector(loadDataWithDelay) withObject:nil afterDelay:1.0];
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

- (void)loadDataWithDelay
{
	randomDataSource = [[SubredditDataSource alloc] initWithSubreddit:@"/randomrising/"];
	[randomDataSource load:TTURLRequestCachePolicyNoCache more:NO];
	
	messageDataSource = [[MessageDataSource alloc] init];
	[messageDataSource load:TTURLRequestCachePolicyNoCache more:NO];	
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
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL URLWithString:path], &shakingSound);
}

- (void)dealloc 
{
	self.navController = nil;
	self.messageDataSource = nil;
	
	AudioServicesDisposeSystemSoundID(shakingSound);
    
	[window release];
    [super dealloc];
}

- (void)showRandomStory
{
	if (!randomDataSource || ![randomDataSource isLoaded])
		return;

	if (!randomController)
	{
		randomController= [[StoryViewController alloc] init];
		//[[Beacon shared] startSubBeaconWithName:@"serendipityTime" timeSession:YES];
	}
	
	SubredditDataSource *activeDataSource = [SubredditDataSource lastLoadedSubreddit];
    NSInteger count = [((SubredditDataModel *)activeDataSource.model) totalStories];
	NSInteger randomIndex = count > 0 ? arc4random() % count : 0;
	
	Story *story = nil;
	
	int i=0;
	while (!story && i++ < count)
	{
		story = [activeDataSource storyWithIndex:(randomIndex++)%count];

		if ([story visited] && i < count - 1)
			story = nil;
	}
	
	if (!story)
	{
		[randomDataSource load:TTURLRequestCachePolicyDefault more:YES];
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
		NSLog(@"RELEASING RANDOM CONTROLLER");
		[randomController release];
		randomController = nil;
	}
}

@end

