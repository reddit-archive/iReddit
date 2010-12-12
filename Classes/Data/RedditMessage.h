//
//  Message.h
//  Reddit
//
//  Created by Ross Boucher on 3/10/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@interface RedditMessage : NSObject 
{
	TTStyledText	*body;
    NSString        *name;
    NSString        *identifier;
    NSString        *author;
    NSString        *destination;
    NSString        *subject;
    NSString        *created;
    NSString        *context;
    BOOL            isCommentReply;
    BOOL            isNew;
	
	float           heights[2];
}

+ (RedditMessage *)messageWithDictionary:(NSDictionary *)dict;

- (CGFloat)heightForDeviceMode:(UIDeviceOrientation)orientation;


//private
- (void)setHeight:(CGFloat)aHeight forIndex:(int)anIndex;


@property (nonatomic, retain) TTStyledText	*body;
@property (nonatomic, retain) NSString	*name;
@property (nonatomic, retain) NSString	*identifier;
@property (nonatomic, retain) NSString	*author;
@property (nonatomic, retain) NSString	*destination;
@property (nonatomic, retain) NSString	*subject;
@property (nonatomic, retain) NSString	*context;
@property (nonatomic, retain) NSString	*created;
@property (nonatomic, assign) BOOL		isCommentReply;
@property (nonatomic, assign) BOOL		isNew;

@end
