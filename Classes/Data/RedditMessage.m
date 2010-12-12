//
//  Message.m
//  Reddit
//
//  Created by Ross Boucher on 3/10/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "RedditMessage.h"
#import "NSString+HTMLEncoding.h"
#import "Constants.h"
#define PORTRAIT_INDEX 0
#define LANDSCAPE_INDEX 1


@implementation RedditMessage

@synthesize body, name, created, subject, identifier, destination, author, context, isCommentReply, isNew;

+ (RedditMessage *)messageWithDictionary:(NSDictionary *)dict
{			
    RedditMessage *aMessage = [[[RedditMessage alloc] init] autorelease];
	NSString *messageBody = [(NSString *)[dict objectForKey:@"body_html"] stringByDecodingHTMLEncodedCharacters];
    
    // unfortunately need to conform to Three20 for markup in messages...
    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"<em>" withString:@"<i>"];
    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"</em>" withString:@"</i>"];
    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"<strong>" withString:@"<b>"];
    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"</strong>" withString:@"</b>"];

	aMessage.body = [TTStyledText textFromXHTML:messageBody lineBreaks:NO URLs:NO];
    aMessage.body.font = [UIFont systemFontOfSize:14.0];
	aMessage.author = (NSString *)[dict objectForKey:@"author"];
	aMessage.subject = (NSString *)[dict objectForKey:@"subject"];
	aMessage.destination = (NSString *)[dict objectForKey:@"destination"];
	aMessage.identifier = (NSString *)[dict objectForKey:@"id"];
	aMessage.name = (NSString *)[dict objectForKey:@"name"];
	aMessage.context = [NSString stringWithFormat:@"%@%@", RedditBaseURLString, (NSString *)[dict objectForKey:@"context"]];
	aMessage.created = (NSString *)[(NSNumber *)[dict objectForKey:@"created"] stringValue];
	aMessage.isNew = [(NSNumber *)[dict objectForKey:@"new"] boolValue];
	aMessage.isCommentReply = [(NSNumber *)[dict objectForKey:@"was_comment"] boolValue];

	// precompute the height of the resulting cell
	
	
	UIFont *subjectFont = [UIFont boldSystemFontOfSize:14.0];
	CGFloat height;
	
    // sets up the TTStyledText's width, which allows "height" to do the proper calculation (for body only)
    CGSize constrainedSize = CGSizeMake(280, 1000);
    aMessage.body.width = constrainedSize.width;
	height = aMessage.body.height;
	height += (CGFloat)([aMessage.subject sizeWithFont:subjectFont constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeTailTruncation]).height;
	height += 18.0 + 12.0 + 12.0;
	
	[aMessage setHeight:height forIndex:PORTRAIT_INDEX];

    constrainedSize = CGSizeMake(440, 1000);
    aMessage.body.width = constrainedSize.width;
	height = (CGFloat)[aMessage.body height];
	height += (CGFloat)([aMessage.subject sizeWithFont:subjectFont constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeTailTruncation]).height;
	height += 18.0 + 12.0 + 12.0;

	[aMessage setHeight:height forIndex:LANDSCAPE_INDEX];	
	
	
	return aMessage;
}

- (void)setHeight:(CGFloat)aHeight forIndex:(int)anIndex
{
	heights[anIndex] = aHeight;
}

- (CGFloat)heightForDeviceMode:(UIDeviceOrientation)orientation
{	
	if (UIDeviceOrientationIsPortrait(orientation) || !UIDeviceOrientationIsValidInterfaceOrientation(orientation))
		return heights[PORTRAIT_INDEX];
	else
		return heights[LANDSCAPE_INDEX];
}

- (void)dealloc
{	
	self.body = nil;
	self.name = nil; 
	self.created = nil; 
	self.subject = nil;
	self.identifier = nil; 
	self.destination = nil;
	self.author = nil;
	self.context = nil; 

	[super dealloc];
}

@end
