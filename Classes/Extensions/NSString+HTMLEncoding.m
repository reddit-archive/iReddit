//
//  NSString+HTMLEncoding.m
//  Reddit
//
//  Created by Ross Boucher on 1/3/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "NSString+HTMLEncoding.h"
#include <math.h>

@implementation NSString (HTMLEncoding)

- (NSString *)stringByDecodingHTMLEncodedCharacters
{
	NSMutableString *temp = [NSMutableString stringWithString:self];
	
	[temp replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"&gt;" withString:@">" options:0 range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"&lt;" withString:@"<" options:0 range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:0 range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"&apos;" withString:@"'" options:0 range:NSMakeRange(0, [temp length])];

	return [NSString stringWithString:temp];
}

- (NSString *)stringByConvertingUTCTimestampToFriendlyString
{
	long timestamp = [self longLongValue];
	long offset = [[NSTimeZone localTimeZone] secondsFromGMT];
	long currentTime = [[NSDate date] timeIntervalSince1970];
	long interval = ABS((currentTime - offset) - timestamp);
	
	if (interval <= 1.0)
		return @"1 second";
	
	if (interval <= 60.0)
		if (interval >= 30.0)
			return @"half a minute";
		else
			return [NSString stringWithFormat:@"%d seconds", (int)floorf(interval)];
	
	int time = (int)floorf(interval / 60.0);
	
	if (time < 60)
		if (time == 1)
			return @"1 minute";
		else
			return [NSString stringWithFormat:@"%d minutes", time];
	
	time = (int)floorf(interval / (60.0 * 60.0));
	
	if (time < 24)
		if (time == 1)
			return @"1 hour";
		else
			return [NSString stringWithFormat:@"%d hours", time];
	
	time = (int)floorf(interval / (60.0 * 60.0 * 24.0));
	
	if (time < 30)
		if (time == 1)
			return @"1 day";
		else 
			return [NSString stringWithFormat:@"%d days", time];
	
	time = (int)floorf(interval / (60.0 * 60.0 * 24.0 * 30.0));
	
	if (time < 12)
		if (time == 1)
			return @"1 month";
		else 
			return [NSString stringWithFormat:@"%d months", time];

	time = (int)floorf(interval / (60.0 * 60.0 * 24.0 * 30.0 * 12.0));
	
	if (time == 1)
		return @"1 year";

	return [NSString stringWithFormat:@"%d years", time];
}

@end
