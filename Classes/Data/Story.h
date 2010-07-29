//
//  Story.h
//  Reddit
//
//  Created by Ross Boucher on 12/6/08.
//  Copyright 2008 280 North. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SubredditDataSource;

@interface Story : NSObject 
{
	float	 heights[4];
	
	NSString *title;
	NSString *author;
	NSString *domain;
	NSString *identifier;
	NSString *name;
	NSString *URL;
	NSString *kind;
	NSString *created;
	NSString *thumbnailURL;
	NSString *commentID;

	unsigned int totalComments;
	unsigned int downs;
	unsigned int ups;
	unsigned int index;

	BOOL likes;
	BOOL dislikes;
	BOOL visited;
	BOOL isSelfReddit;

	NSString *subreddit;
	SubredditDataSource *subredditDataSource;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *URL;
@property (nonatomic, retain) NSString *kind;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, assign) SubredditDataSource *subredditDataSource;
@property (nonatomic, retain) NSString *subreddit;
@property (nonatomic, assign) unsigned int totalComments;
@property (nonatomic, assign) unsigned int downs;
@property (nonatomic, assign) unsigned int ups;
@property (nonatomic, assign) unsigned int index;
@property (nonatomic, assign) BOOL likes;
@property (nonatomic, assign) BOOL dislikes;
@property (nonatomic, assign) BOOL isSelfReddit;
@property (nonatomic, retain) NSString *thumbnailURL;
@property (nonatomic, retain) NSString *commentID;

//dynamic properties
@property (nonatomic, assign) int score;
@property (nonatomic, assign) BOOL visited;
@property (nonatomic, assign) NSString *commentsURL;

//public
+ (Story *)storyWithDictionary:(NSDictionary *)dict inReddit:(id)reddit;
+ (Story *)storyWithID:(NSString *)anID;

- (CGFloat)heightForDeviceMode:(UIDeviceOrientation)orientation withThumbnail:(BOOL)showsThumbnail;
- (BOOL)hasThumbnail;

//private
- (void)setHeight:(CGFloat)aHeight forIndex:(int)anIndex;

@end


