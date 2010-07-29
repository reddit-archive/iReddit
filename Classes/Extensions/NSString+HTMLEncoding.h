//
//  NSString+HTMLEncoding.h
//  Reddit
//
//  Created by Ross Boucher on 1/3/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (HTMLEncoding)

- (NSString *)stringByDecodingHTMLEncodedCharacters;
- (NSString *)stringByConvertingUTCTimestampToFriendlyString;

@end
