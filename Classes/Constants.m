//
//  Constants.m
//  Reddit2
//
//  Created by Ross Boucher on 6/13/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "Constants.h"

NSString *const RedditBaseURLString		 = @"http://www.reddit.com";
NSString *const RedditAPIExtensionString = @".json?limit=25";
NSString *const MoreItemsFormattedString = @"&after=";

NSString *const RedditHideStoryAPIString	  = @"/api/hide";
NSString *const RedditSaveStoryAPIString	  = @"/api/save";
NSString *const RedditVoteAPIString			  = @"/api/vote";
NSString *const CustomRedditsAPIString		  = @"/reddits/mine.json";
NSString *const RedditMessagesAPIString		  = @"/message/inbox.json";
NSString *const RedditComposeMessageAPIString = @"/api/compose";
NSString *const RedditSubscribeAPIString	  = @"/api/subscribe";
 
NSString *const SubRedditNewsModeHot			= @"";
NSString *const SubRedditNewsModeNew			= @"new/";
NSString *const SubRedditNewsModeTop			= @"top/";
NSString *const SubRedditNewsModeControversial	= @"controversial/";

NSString *const InstapaperAPIString = @"https://www.instapaper.com/api/add";

NSString *const showStoryThumbnailKey		 = @"showStoryThumbnailKey";
NSString *const redditUsernameKey			 = @"redditUsernameKey";
NSString *const redditPasswordKey			 = @"redditPasswordKey";
NSString *const shakeForStoryKey			 = @"shakeForStoryKey";
NSString *const playSoundOnShakeKey			 = @"playSoundOnShakeKey";
NSString *const visitedStoriesKey			 = @"visitedStoriesKey";
NSString *const useCustomRedditListKey		 = @"useCustomRedditListKey";
NSString *const showLoadingAlienKey			 = @"showLoadingAlienKey";
NSString *const instapaperUsernameKey		 = @"instapaperUsernameKey";
NSString *const instapaperPasswordKey		 = @"instapaperPasswordKey";
NSString *const shakingSoundKey				 = @"shakingSoundKey";
NSString *const redditSortOrderKey			 = @"redditSortOrderKey";
NSString *const allowLandscapeOrientationKey = @"allowLandscapeOrientationKey";

NSString *const initialRedditURLKey			 = @"initialRedditURLKey";
NSString *const initialRedditTitleKey		 = @"initialRedditTitleKey";

NSString *const RedditDidBeginLoggingInNotification  = @"RedditDidBeginLoggingInNotification";
NSString *const RedditDidFinishLoggingInNotification = @"RedditDidFinishLoggingInNotification";
NSString *const RedditWasAddedNotification			 = @"RedditWasAddedNotification";

NSString *const MessageCountDidChangeNotification = @"MessageCountDidChangeNotification";

NSString *const DeviceDidShakeNotification = @"DeviceDidShakeNotification";

BOOL            shouldDetectDeviceShake = YES;

NSString *const redditSoundLightsaber	= @"lightsaber";
NSString *const redditSoundAlienHunter	= @"alien-hunter";
NSString *const redditSoundAlleyBrawler	= @"alley-brawler";
NSString *const redditSoundBeamMeUp		= @"beam-me";
NSString *const redditSoundEnGarde		= @"en-garde";
NSString *const redditSoundPipe			= @"pipe";
NSString *const redditSoundPureEvil		= @"pure-evil";
NSString *const redditSoundRollout		= @"rollout";
NSString *const redditSoundScream		= @"scream";
NSString *const redditSoundTheDoor		= @"thedoor";

