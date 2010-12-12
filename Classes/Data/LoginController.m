//
//  LoginController.m
//  Reddit2
//
//  Created by Ross Boucher on 6/15/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "LoginController.h"
#import "Constants.h"
#import "NSDictionary+JSON.h"

LoginController *SharedLoginController = nil;

@implementation LoginController

@synthesize modhash, lastLoginTime;

+ (id)sharedLoginController
{
	if (!SharedLoginController)
	{
		SharedLoginController = [[self alloc] init];
		SharedLoginController.modhash = @"";
	}
	
	return SharedLoginController;
}

- (void)dealloc
{
	self.modhash = nil;
	self.lastLoginTime = nil;

	[super dealloc];
}

- (BOOL)isLoggedIn
{
    return lastLoginTime != nil;
}

- (BOOL)isLoggingIn
{
    return isLoggingIn;
}

- (void)loginWithUsername:(NSString *)aUsername password:(NSString *)aPassword
{
    self.lastLoginTime = nil;
    
    if (!aUsername || !aPassword || ![aUsername length] || ![aPassword length])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RedditDidFinishLoggingInNotification object:nil];
        return;
    }
	
	isLoggingIn = YES;
	
	NSString *loadURL = [NSString stringWithFormat:@"%@%@", RedditBaseURLString, @"/api/login"];
	
	
	TTURLRequest *request = [TTURLRequest requestWithURL:loadURL delegate:self];
	request.cacheExpirationAge = 0;
    request.cachePolicy = TTURLRequestCachePolicyNoCache;

	request.response = [[[TTURLDataResponse alloc] init] autorelease];

	request.contentType = @"application/x-www-form-urlencoded";
	
	request.httpMethod = @"POST";
	request.httpBody = [[NSString stringWithFormat:@"rem=on&passwd=%@&user=%@&api_type=json", 
						 [aPassword stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], 
						 [aUsername stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] 
						dataUsingEncoding:NSASCIIStringEncoding];

	[request send];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request
{
	[[NSNotificationCenter defaultCenter] postNotificationName:RedditDidBeginLoggingInNotification object:nil];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
    TTURLDataResponse *response = request.response;
    NSString *responseBody = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
	
    // parse the JSON data that we retrieved from the server
	NSError *error = nil;

    NSDictionary *json = [NSDictionary dictionaryWithJSONString:responseBody error:&error];
	NSDictionary *responseJSON = [(NSDictionary *)json valueForKey:@"json"];
    
	[responseBody release];

	BOOL loggedIn = !error && [responseJSON objectForKey:@"data"];
	
	if (loggedIn)
	{		
		self.modhash = (NSString *)[(NSDictionary *)[responseJSON objectForKey:@"data"] objectForKey:@"modhash"];
		self.lastLoginTime = [NSDate date];
	}
	else
	{
		self.modhash = @"";
		self.lastLoginTime = nil;
	}
	
	isLoggingIn = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:RedditDidFinishLoggingInNotification object:nil];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    isLoggingIn = NO;
	self.lastLoginTime = nil;	
	[[NSNotificationCenter defaultCenter] postNotificationName:RedditDidFinishLoggingInNotification object:nil];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request
{
	isLoggingIn = NO;
	self.lastLoginTime = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:RedditDidFinishLoggingInNotification object:nil];
}


@end
