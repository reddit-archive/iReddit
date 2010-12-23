//
//  SubredditDataModel.m
//  iReddit
//
//  Created by Ryan Bruels on 7/21/10.

//

#import "SubredditDataModel.h"
#import "Constants.h"
#import "Story.h"
#import "LoginController.h"

@implementation SubredditDataModel
@synthesize subreddit = _subreddit, stories = _stories;
@synthesize newsModeIndex;

- (id)initWithSubreddit:(NSString *)subreddit
{
	if (self = [super init])
	{
        self.newsModeIndex = 0;
		_subreddit = [subreddit retain];
        _stories = [[NSMutableArray alloc] init];
    }
	
	return self;
}

- (BOOL)canLoadMore
{
    return canLoadMore;
}

- (BOOL)isLoaded
{
    return [_stories count] > 0;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{	
    NSString *loadURL = [self fullURL];
    if(more) 
    {
        id object = [self.stories lastObject];

        //rb what the fuck is this doing?
        if ([object isKindOfClass:[TTTableMoreButton class]])
             object = [self.stories objectAtIndex:[self.stories count] - 2];

        Story *story = (Story *)object;
        NSString *lastItemID = story.name;

        loadURL = [NSString stringWithFormat:@"%@%@%@", [self fullURL], MoreItemsFormattedString, lastItemID];
    } 
    else
    {
        // clear the stories for this subreddit
        [self.stories removeAllObjects];
    }
    	
    TTURLRequest *activeRequest = [TTURLRequest requestWithURL:loadURL delegate:self];
	activeRequest.cacheExpirationAge = 0;
    activeRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
    activeRequest.shouldHandleCookies = ([[LoginController sharedLoginController] isLoggedIn] || [[LoginController sharedLoginController] isLoggingIn]) ? YES : NO;
    
    id<TTURLResponse> response = [[TTURLDataResponse alloc] init];
    activeRequest.response = response;
    TT_RELEASE_SAFELY(response);

    activeRequest.httpMethod = @"GET";
    [activeRequest send];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request
{        
    NSInteger totalCount = [_stories count];
	canLoadMore = NO;
		
    TTURLDataResponse *response = request.response;
    NSString *responseBody = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];

    // parse the JSON data that we retrieved from the server
    NSDictionary *json = [NSDictionary dictionaryWithJSONString:responseBody error:nil];
    [responseBody release];
        
    // drill down into the JSON object to get the part 
    // that we're actually interested in.
	
	if (![json isKindOfClass:[NSDictionary class]])
	{
	    [self didFinishLoad];
		return;
	}

    NSDictionary *resultSet = [json objectForKey:@"data"];
    NSArray *results = [resultSet objectForKey:@"children"];
    
    for (NSDictionary *result in results) 
	{     
		NSDictionary *data = [result objectForKey:@"data"];
		
		Story *theStory = [Story storyWithDictionary:data inReddit:self];
		theStory.index = [_stories count];
		
        [_stories addObject:theStory];
	}
    
	canLoadMore = [_stories count] > totalCount;
    [super requestDidFinishLoad:request];
}

- (NSString *)fullURL
{
	return [NSString stringWithFormat:@"%@%@%@%@", RedditBaseURLString, self.subreddit, [self newsModeString], RedditAPIExtensionString];
}

- (NSUInteger)totalStories
{
    return [self.stories count];
}

- (NSString *)newsModeString
{
	switch (newsModeIndex)
	{
		case 0:
			return SubRedditNewsModeHot;
		case 1:
			return SubRedditNewsModeNew;
		case 2:
			return SubRedditNewsModeTop;
		case 3:
			return SubRedditNewsModeControversial;
	}
	
	return @"";
}

- (void)invalidate:(BOOL)erase 
{
	[self.stories removeAllObjects];
}

- (void)dealloc
{
    TT_RELEASE_SAFELY(_stories);
    TT_RELEASE_SAFELY(_subreddit);
    [super dealloc];
}



@end
