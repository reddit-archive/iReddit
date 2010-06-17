//
//  NSDictionary+JSON.m
//  Reddit2
//
//  Created by Ross Boucher on 6/11/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "CJSONDeserializer.h"
#import "NSDictionary_JSONExtensions.h"
#import "NSDictionary+JSON.h"

@implementation NSDictionary (NSDictionary_JSON)

+ (id)dictionaryWithJSONString:(NSString *)aString error:(NSError **)anError
{
	return [[CJSONDeserializer deserializer] deserialize:[aString dataUsingEncoding:NSUTF32BigEndianStringEncoding] error:anError];
}

@end
