//
//  Story.m
//  Reddit
//
//  Created by Ross Boucher on 12/6/08.
//  Copyright 2008 280 North. All rights reserved.
//

#import "Story.h"
//#import "SettingsViewController.h"
#import "NSString+HTMLEncoding.h"
#import "SubredditDataSource.h"
#import "Constants.h"

NSMutableArray	*visitedArray;
NSMutableSet	*visitedSet;

NSMutableDictionary *storyDictionary;

@implementation Story

@synthesize title, author, domain, thumbnailURL, identifier, name, subreddit, subredditDataSource, URL, kind, created, ups, downs, likes, dislikes, index, isSelfReddit, totalComments, commentID;
@dynamic score, commentsURL, visited;

#define PORTRAIT_INDEX 0
#define PORTRAIT_THUMBNAIL_INDEX 1
#define LANDSCAPE_INDEX 2
#define LANDSCAPE_THUMBNAIL_INDEX 3

+ (void)initialize
{
	if (!visitedArray)
	{
		visitedArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:visitedStoriesKey]];
		visitedSet = [[NSMutableSet alloc] initWithArray:visitedArray];
		storyDictionary = [[NSMutableDictionary alloc] initWithCapacity:100];
	}
}

+ (Story *)storyWithDictionary:(NSDictionary *)dict inReddit:(id)reddit
{			
	Story *aStory = [[[Story alloc] init] autorelease];
		
	aStory.title = [(NSString *)[dict objectForKey:@"title"] stringByDecodingHTMLEncodedCharacters];
	aStory.author = (NSString *)[dict objectForKey:@"author"];
	aStory.domain = (NSString *)[dict objectForKey:@"domain"];
	aStory.identifier = (NSString *)[dict objectForKey:@"id"];
	aStory.name = (NSString *)[dict objectForKey:@"name"];
    aStory.URL = [(NSString *)[dict objectForKey:@"url"] stringByDecodingHTMLEncodedCharacters];
	aStory.created = (NSString *)[(NSNumber *)[dict objectForKey:@"created_utc"] stringValue];
	aStory.kind = @"t3";
	aStory.thumbnailURL = (NSString *)[dict objectForKey:@"thumbnail"];
	
	aStory.totalComments = [(NSNumber *)[dict objectForKey:@"num_comments"] intValue];
	aStory.downs = [(NSNumber *)[dict objectForKey:@"downs"] intValue];
	aStory.ups = [(NSNumber *)[dict objectForKey:@"ups"] intValue];
	aStory.commentID = @"";

	id likes = [dict objectForKey:@"likes"];
	if (![likes isKindOfClass:[NSNumber class]])
	{
		aStory.likes = NO;
		aStory.dislikes = NO;
	}
	else
	{
		aStory.likes = [(NSNumber *)likes boolValue];
		aStory.dislikes = !aStory.likes;
	}

	aStory.subredditDataSource = reddit;
	
	aStory.subreddit = (NSString *)[dict objectForKey:@"subreddit"];
	aStory.visited = NO;
	
	aStory.isSelfReddit = ([aStory.domain rangeOfString:@"self."].location == 0);
	
	UIFont *storyFont = [UIFont boldSystemFontOfSize:14];
	CGFloat height;
	
	height = (CGFloat)([aStory.title sizeWithFont:storyFont constrainedToSize:CGSizeMake(266.0, 1000.0) lineBreakMode:UILineBreakModeTailTruncation]).height;
	[aStory setHeight:height forIndex:PORTRAIT_INDEX];
	
	height = (CGFloat)([aStory.title sizeWithFont:storyFont constrainedToSize:CGSizeMake(266.0-68.0, 1000.0) lineBreakMode:UILineBreakModeTailTruncation]).height;
	[aStory setHeight:height forIndex:PORTRAIT_THUMBNAIL_INDEX];
	
	height = (CGFloat)[aStory.title sizeWithFont:storyFont constrainedToSize:CGSizeMake(428.0, 1000.0) lineBreakMode:UILineBreakModeTailTruncation].height;
	[aStory setHeight:height forIndex:LANDSCAPE_INDEX];

	height = (CGFloat)[aStory.title sizeWithFont:storyFont constrainedToSize:CGSizeMake(428.0-68.0, 1000.0) lineBreakMode:UILineBreakModeTailTruncation].height;
	[aStory setHeight:height forIndex:LANDSCAPE_THUMBNAIL_INDEX];

	[storyDictionary setObject:aStory forKey:aStory.identifier];
	
	return aStory;
}

+ (Story *)storyWithID:(NSString *)anID
{
	if (!storyDictionary)
		return nil;

	Story *story = [storyDictionary objectForKey:anID];

	return story;
}

- (void)setHeight:(CGFloat)aHeight forIndex:(int)anIndex
{
	heights[anIndex] = aHeight;
}

- (CGFloat)heightForDeviceMode:(UIDeviceOrientation)orientation withThumbnail:(BOOL)showsThumbnail
{	
	if (UIDeviceOrientationIsPortrait(orientation) || !UIDeviceOrientationIsValidInterfaceOrientation(orientation))
		return showsThumbnail ? heights[PORTRAIT_THUMBNAIL_INDEX] : heights[PORTRAIT_INDEX];
	else
		return showsThumbnail ? heights[LANDSCAPE_THUMBNAIL_INDEX] : heights[LANDSCAPE_INDEX];
}

- (int)score
{
	int score = ups - downs;
	
	if (dislikes)
		score--;
	else if (likes)
		score++;
	
	return score;
}

- (void)setVisited:(BOOL)isVisited
{	
	if (isVisited && ![visitedSet containsObject:self.identifier])
	{
		[visitedArray insertObject:self.identifier atIndex:0];
		[visitedSet addObject:self.identifier];
	}
	
	visited = isVisited;
}

- (BOOL)visited
{	
	return [visitedSet containsObject:self.identifier];
}

- (NSString *)commentsURL
{
	return [NSString stringWithFormat:@"http://reddit.com/comments/%@", self.identifier];
}

- (BOOL)hasThumbnail
{
	return ![self.thumbnailURL isEqual:@"/static/noimage.png"] && ![self.thumbnailURL isEqual:@""] && self.thumbnailURL;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ - %@ %d", [super description], self.identifier, self.visited];
}

- (void)dealloc
{	
	[author release];
	[domain release];
	[identifier release];
	[name release];
	[subreddit release];
	[URL release];
	[kind release];
	[thumbnailURL release];
	[created release];
	[title release];
	[commentID release];

	[super dealloc];
}

@end

