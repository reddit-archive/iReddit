/**
 * AdMobDelegateProtocol.h
 * AdMob iPhone SDK publisher code.
 *
 * Defines the AdMobDelegate protocol.
 */
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@class AdMobView;

@protocol AdMobDelegate<NSObject>

@required

// Use this to provide a publisher id for an ad request. Get a publisher id
// from http://www.admob.com
- (NSString *)publisherId;

@optional

// Sent when an ad request loaded an ad; this is a good opportunity to add
// this view to the hierachy, if it has not yet been added.
// Note that this will only ever be sent once per AdMobView, regardless of whether
// new ads are subsequently requested in the same AdMobView.
- (void)didReceiveAd:(AdMobView *)adView;

// Sent when an ad request failed to load an ad.
// Note that this will only ever be sent once per AdMobView, regardless of whether
// new ads are subsequently requested in the same AdMobView.
- (void)didFailToReceiveAd:(AdMobView *)adView;

// Specifies the ad background color, for tile+text ads.
// Defaults to [UIColor colorWithRed:0.443 green:0.514 blue:0.631 alpha:1], which is a chrome-y color.
// Note that the alpha channel in the provided color will be ignored and treated as 1.
// We recommend against using a white or very light color as the background color, but
// if you do, be sure to implement adTextColor and useGraySpinner.
// Grayscale colors won't function correctly here. Use e.g. [UIColor colorWithRed:0 green:0 blue:0 alpha:1]
// instead of [UIColor colorWithWhite:0 alpha:1] or [UIColor blackColor].
- (UIColor *)adBackgroundColor;

// Specifies the primary text color for ads.
// Defaults to [UIColor whiteColor].
- (UIColor *)primaryTextColor;

// Specifies the secondary text color for ads.
// Defaults to [UIColor whiteColor].
- (UIColor *)secondaryTextColor;

// When a spinner is shown over the adBackgroundColor (e.g. on clicks), it is by default
// a white spinner. If this returns YES, a gray spinner will be used instead,
// which looks better when the adBackgroundColor is white or very light in color.
- (BOOL)useGraySpinner;

// Whether AdMob may use location information. Defaults to NO.
// We ask that you respect your users' privacy and only enable location requests
// if your app already uses location information.
// Note that even if this is set to no, you will still need to include the CoreLocation
// framework to compile your app; it will simply not get used. (It is a dynamic
// framework, so including it will not increase the size of your app.)
- (BOOL)mayAskForLocation;

// If you have location information available for the user at the time that you
// make the ad request, you may provide it here (and it is recommended that you do
// so, to improve user experience and preserve battery life). If this method is implemented,
// AdMob will not request location information from the OS, even if the method returns
// nil (which it should if the user's location is not known); if this method is not
// implemented, then AdMob will request location information directly from the OS.
//
// If mayAskForLocation (above) is not implemented, or returns NO, this will not be called
// and may be completely ignored.
- (CLLocation *)location;

// If implemented, lets you specify whether to issue a real ad request or a test
// ad request (to be used for development only, of course). Defaults to NO.
- (BOOL)useTestAd;

// If implemented, lets you specify the action type of the test ad. Defaults to @"url" (web page).
// Does nothing if useTestAd is not implemented or returns NO.
// Acceptable values are @"url", @"app", @"video", @"itunes", @"call", @"canvas".
// Normally, the adservers restricts ads appropriately (e.g. no click to call ads for iPod touches).
// However, for your testing convenience, they will return any type requested for test ads.
- (NSString *)testAdAction;

// The following functions, if implemented, provide extra information
// for the ad request. If you happen to have this information, providing it will
// help select better targeted ads and will improve monetization.
//
// Keywords and search terms should be provided as a space separated string
// like "iPhone monetization San Mateo". We strongly recommend that
// you NOT hard code keywords or search terms.
//
// Keywords are used to select better ads; search terms _restrict_ the available
// set of ads. Note, then, that providing a search string may seriously negatively
// impact your fill rate; we recommend using it only when the user is submitting a
// free-text search request and you want to _only_ display ads relevant to that search.
// In those situations, however, providing a search string can yield a significant
// monetization boost.
//
// For all of these methods, if the information is not available at the time of
// the call, you should return nil.
- (NSString *)postalCode; // user's postal code, e.g. "94401"
- (NSString *)areaCode; // user's area code, e.g. "415"
- (NSDate *)dateOfBirth; // user's date of birth
- (NSString *)gender; // user's gender (e.g. @"m" or @"f")
- (NSString *)keywords; // keywords the user has provided or that are contextually relevant, e.g. @"twitter client iPhone"
- (NSString *)searchString; // a search string the user has provided, e.g. @"Jasmine Tea House San Francisco"

// You can control the appearance of the AdMob mini-browser and the nav bars 
// to fit with the rest of your app. See the documentation for UIToolbar
// and UINavigationBar for details. Defaults to standard iPhone chrome.
- (UIBarStyle)embeddedWebViewBarStyle;
- (UIColor *)embeddedWebViewTintColor;

// Sent just before presenting the user a full screen view, such as a canvas page or an embedded webview,
// in response to clicking on an ad. Use this opportunity to stop animations, time sensitive interactions, etc.
- (void)willPresentFullScreenModal;

// Sent just after dismissing a full screen view. Use this opportunity to
// restart anything you may have stopped as part of -willPresentFullScreenModal:.
- (void)didDismissFullScreenModal;

@end