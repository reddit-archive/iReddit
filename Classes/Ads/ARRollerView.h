/**
 *  ARRollerView.h
 *  
 *  Copyright 2009 AdWhirl Inc. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>

@class ARRollerController, ARRollerViewInternal;
@protocol ARRollerDelegate;

@interface ARRollerView : UIView

/** 
 * Call this method to get a view object that you can add to your own view. You must also provide a delegate.  
 * The delegate provides AdWhirl's application key and can listen for important messages.  
 * You can configure the roller's settings and specific ad network information on AdWhirl.com.  
 */
+ (ARRollerView*)requestRollerViewWithDelegate:(id<ARRollerDelegate>)delegate;

/**
 * Call this method to get another ad to display. 
 * You can also specify under "app settings" on AdWhirl.com to automatically get new ads periodically 
 * (30 seconds, 45 seconds, 1 min, etc.), as well as these options:
 *   - change the animation between ad transitions.
 *   - change the text color.
 *   - change the background color.
 *   - change location request access on or off.
 */
- (void)getNextAd;
/**
 * The delegate is informed asynchronously whether an ad succeeds or fails to load.  
 * If you prefer to poll for this information, you can do so.
 *
 */
- (BOOL)adExists;

/**
 * Call this method to get the name of the most recent ad network that an ad request was made to.
 */
- (NSString*)mostRecentNetworkName;


/**
 * This is mainly offered so that when your delegate is dealloced you can set the roller's delegate to nil 
 * so that messages from the roller aren't sent to a dangling pointer.
 */
- (void)setDelegateToNil;
@end
