//
//  AdField.m
//  Reddit2
//
//  Created by Ross Boucher on 6/11/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "AdField.h"
#import "AdMobView.h"

@implementation AdField

@synthesize adView;

#pragma mark ARRollerDelegate required delegate method implementation

- (NSString*)adWhirlApplicationKey
{
	return @"";  //Return your AdWhirl application key here
}

#pragma mark AdMobDelegate methods

- (NSString *)publisherId {
	return @""; // this should be prefilled; if not, get it from www.admob.com
}

- (UIColor *)adBackgroundColor {
	return [UIColor colorWithRed:229.0/255.0 green:238.0/255.0 blue:1 alpha:1]; // this should be prefilled; if not, provide a UIColor
}


- (UIColor *)primaryTextColor {
	return [UIColor blackColor]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)secondaryTextColor {
	return [UIColor blueColor]; // this should be prefilled; if not, provide a UIColor
}

- (BOOL)mayAskForLocation {
	return NO; // this should be prefilled; if not, see AdMobProtocolDelegate.h for instructions
}

// To receive test ads rather than real ads...

- (BOOL)useTestAd {
	return NO;
}

- (NSString *)testAdAction {
	return @"url"; // see AdMobDelegateProtocol.h for a listing of valid values here
}

- (void)didReceiveAd:(id)adView {
	NSLog(@"AdMob: Did receive ad");
}

- (void)didFailToReceiveAd:(id)adView {
	NSLog(@"AdMob: Did fail to receive ad");
}

- (void)dealloc {
	[self.adView removeFromSuperview];
	self.adView = nil;
    [super dealloc];
}


@end
