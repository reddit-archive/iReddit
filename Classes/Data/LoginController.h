//
//  LoginController.h
//  Reddit2
//
//  Created by Ross Boucher on 6/15/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>


@interface LoginController : NSObject <TTURLRequestDelegate>
{
	NSString *modhash;
	NSDate *lastLoginTime;
    BOOL isLoggingIn;
}

@property (nonatomic, retain) NSString *modhash;
@property (nonatomic, retain) NSDate *lastLoginTime;

+ (id)sharedLoginController;

- (BOOL)isLoggedIn;
- (BOOL)isLoggingIn;

- (void)loginWithUsername:(NSString *)aUsername password:(NSString *)aPassword;

@end
