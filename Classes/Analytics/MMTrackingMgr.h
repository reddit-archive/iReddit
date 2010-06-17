//
//  MMTrackingMgr.h
//  Medialets Mobile Tracking Platform
//
//  Created by David Lambert on 6/14/08.
//  Copyright 2008 Medialets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class MMTrackedEventDatabase;

@interface MMTrackingMgr : NSObject <CLLocationManagerDelegate> {
	NSTimer					*locationTimer;
	NSTimer					*broadcastTimer;
	NSTimer					*connStatusTimer;
	MMTrackedEventDatabase	*trackedEventDB;

	CLLocation				*currentLocation;
    CLLocationManager		*locationManager;

	NSTimeInterval			broadcastInterval;
    NSTimeInterval			connStatusRefreshInterval;
    NSTimeInterval			locRefreshInterval;

	NSMutableDictionary		*eventKeyUserDict;
}

@property NSTimeInterval	broadcastInterval;
@property NSTimeInterval	connStatusRefreshInterval;
@property NSTimeInterval	locRefreshInterval;

@property (nonatomic, retain) CLLocation	*currentLocation;

+ sharedInstance;

- init;

// Returns one of "NotConnected", "CDNConnected", "WiFiConnected" or "InvalidNetworkStatus"
// Note: "CDN" stands for Carrier Data Network - EDGE or 3G
- (NSString *)internetConnectionStatus;

- (void)trackEvent:(NSString *)eventKey;
- (void)trackEvent:(NSString *)eventKey withUserDict:(NSDictionary *)dict;

- (void)startDefaultTracking;
- (void)startDefaultTrackingWithoutLocation;

- (void)stopLocationTracking;
- (void)startLocationTracking;

- (void)observeNotifications:(NSArray *)names fromObject:(id)obj;
- (void)observeNotification:(NSString *)notificationName fromObject:(id)obj;

- (void)stopObservingNotifications:(NSArray *)names fromObject:(id)obj;
- (void)stopObservingNotification:(NSString *)notificationName fromObject:(id)obj;

@end
