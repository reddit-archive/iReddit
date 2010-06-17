//
//  NSDictionary+JSON.h
//  Reddit2
//
//  Created by Ross Boucher on 6/11/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (NSDictionary_JSON)

+ (id)dictionaryWithJSONString:(NSString *)aString error:(NSError **)anError;

@end
