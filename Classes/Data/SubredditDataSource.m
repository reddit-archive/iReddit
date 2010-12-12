//
//  SubredditDataSource.m
//  Reddit2
//
//  Created by Ross Boucher on 6/8/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "Story.h"
#import "StoryCell.h"
#import "CommentAccessoryView.h"
#import "Constants.h"

#import "SubredditDataSource.h"
#import "NSDictionary_JSONExtensions.h"
#import "NSDictionary+JSON.h"
#import "SubredditViewController.h"

static id lastLoadedSubreddit = nil;

@implementation SubredditDataSource

@synthesize viewController;

+ (SubredditDataSource *)lastLoadedSubreddit
{
    return lastLoadedSubreddit;
}

- (id)initWithSubreddit:(NSString *)subreddit
{
    if (self = [self init])
	{
        _subredditModel = [[SubredditDataModel alloc] initWithSubreddit:subreddit];
    }
    return self;
}

- (id<TTModel>)model
{
  return _subredditModel;
}

- (void)dealloc
{
    TT_RELEASE_SAFELY(_subredditModel);
    TT_RELEASE_SAFELY(lastLoadedTime);
    
	self.viewController = nil;

	[title release];
	[url release];

	[super dealloc];
}

- (void)tableViewDidLoadModel:(UITableView*)tableView
{
    [lastLoadedTime release];
    lastLoadedTime = [[NSDate date] retain];
    self.items = _subredditModel.stories;
    lastLoadedSubreddit = self;
}

- (Story *)storyWithIndex:(int)anIndex
{	
	if (anIndex < 0 || anIndex > [self.items count])
		return nil;
    return [self.items objectAtIndex:anIndex];
}

#pragma mark TTDataSource
//////////////////////////////////////////////////////////////////////////////////////////////////
// TTDataSource

#pragma mark table view delegate stuff

- (void)tableView:(UITableView *)tableView cell:(UITableViewCell *)cell willAppearAtIndexPath:(NSIndexPath *)indexPath 
{
	id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
	
	if ([cell isKindOfClass:[StoryCell class]])
	{ 
        StoryCell *storyCell = (StoryCell *)cell;
		storyCell.story = object;
		
		CommentAccessoryView *accessory = nil;

		if (!storyCell.accessoryView)
		{
			accessory = [[[CommentAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)] autorelease];
			storyCell.accessoryView = accessory;
		}
		else
		{
			accessory = (CommentAccessoryView *)storyCell.accessoryView;
		}
		
		[accessory setCommentCount:storyCell.story.totalComments];

		[accessory addTarget:self action:@selector(accessoryViewTapped:) forControlEvents:UIControlEventTouchUpInside];
		accessory.story = object;
		
        //storyCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; 
    }
	else
        [super tableView:tableView cell:cell willAppearAtIndexPath:indexPath]; 
} 

- (void)accessoryViewTapped:(id)sender
{
	CommentAccessoryView *accessory = (CommentAccessoryView *)sender;
	[(SubredditViewController *)(self.viewController) didSelectAccessoryForObject:accessory.story atIndexPath:[self tableView:self.viewController.tableView indexPathForObject:accessory.story]];
}

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object 
{ 
    if ([object isKindOfClass:[Story class]]) 
        return [StoryCell class]; 
    else 
        return [super tableView:tableView cellClassForObject:object]; 
} 

@end
