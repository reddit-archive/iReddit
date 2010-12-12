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

#define kAccelerometerFrequency			25 //Hz
#define kFilteringFactor				0.15
#define kMinEraseInterval				0.8
#define kEraseAccelerationThreshold		3.0

UIAccelerationValue	myAccelerometer[3];
CFAbsoluteTime lastTime = 0.0;

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
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:(id <UIAccelerometerDelegate>)self];
	
	//login
	[[LoginController sharedLoginController] loginWithUsername:[defaults stringForKey:redditUsernameKey] password:[defaults stringForKey:redditPasswordKey]];
	
	shakingSound = 0;
	[self reloadSound];
	
	[self performSelector:@selector(loadDataWithDelay) withObject:nil afterDelay:1.0];
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
	
	SubredditDataSource *activeDataSource = randomDataSource;
	NSArray *viewControllers = navController.viewControllers;
	
	if (rand()%4 != 0 && [viewControllers count] > 2 && 
		[[viewControllers objectAtIndex:[viewControllers count] - 2] isKindOfClass:[SubredditViewController class]] && 
		[(SubredditDataSource *)[[viewControllers objectAtIndex:[viewControllers count] - 2] dataSource] isLoaded])
		activeDataSource = (id <TTTableViewDataSource, TTURLRequestDelegate>)[[viewControllers objectAtIndex:[viewControllers count] - 2] dataSource];
	
	int count = [activeDataSource totalStories];
	int randomIndex = rand()%count;
	
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

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	UIAccelerationValue	length, x, y, z;
	
	//Use a basic high-pass filter to remove the influence of the gravity
	myAccelerometer[0] = acceleration.x * kFilteringFactor + myAccelerometer[0] * (1.0 - kFilteringFactor);
	myAccelerometer[1] = acceleration.y * kFilteringFactor + myAccelerometer[1] * (1.0 - kFilteringFactor);
	myAccelerometer[2] = acceleration.z * kFilteringFactor + myAccelerometer[2] * (1.0 - kFilteringFactor);
	
	// Compute values for the three axes of the acceleromater
	x = acceleration.x - myAccelerometer[0];
	y = acceleration.y - myAccelerometer[0];
	z = acceleration.z - myAccelerometer[0];
	
	//Compute the intensity of the current acceleration 
	length = sqrt(x * x + y * y + z * z);
	
	// If above a given threshold, play the erase sounds and erase the drawing view
	if((length >= kEraseAccelerationThreshold) && (CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval)) 
	{
		if ([[NSUserDefaults standardUserDefaults] boolForKey:playSoundOnShakeKey]) 
		{
			AudioServicesPlaySystemSound(shakingSound);
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		}
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:shakeForStoryKey])
			[self showRandomStory];
		
		lastTime = CFAbsoluteTimeGetCurrent();
	}
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

