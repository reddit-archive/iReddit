//
//  StoryCell.m
//  Reddit
//
//  Created by Ross Boucher on 11/25/08.
//  Copyright 2008 280 North. All rights reserved.
//

#import "StoryCell.h"
#import "Constants.h"

@implementation StoryCell

@synthesize storyTitleView, storyDescriptionView, storyImage;
@dynamic story;

+ (float)tableView:(UITableView *)aTableView rowHeightForObject:(Story *)aStory
{
    float height = [aStory heightForDeviceMode:[[UIDevice currentDevice] orientation] 
								 withThumbnail:[[NSUserDefaults standardUserDefaults] boolForKey:showStoryThumbnailKey] && [aStory hasThumbnail]] + 46.0;
	
    if ([[NSUserDefaults standardUserDefaults] boolForKey:showStoryThumbnailKey])
		return MAX(height, 68.0);
	else
		return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{	
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
	{
        self.opaque = YES;
		self.backgroundColor = [UIColor whiteColor];

		for (UIView *view in [self subviews])
		{
			[view setBackgroundColor:[UIColor whiteColor]];
			[view setOpaque:YES];
		}

		self.superview.opaque = YES;
		self.superview.backgroundColor = [UIColor whiteColor];

		for (UIView *view in [[self superview] subviews])
		{
			[view setBackgroundColor:[UIColor whiteColor]];
			[view setOpaque:YES];
		}
		
		story = nil;

		storyTitleView = [[UILabel alloc] initWithFrame:CGRectZero];		
		storyTitleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		[storyTitleView setFont:[UIFont boldSystemFontOfSize:14]];
		[storyTitleView setTextColor:[UIColor blueColor]];
		[storyTitleView setLineBreakMode:UILineBreakModeTailTruncation];
		[storyTitleView setNumberOfLines:0];
		//[storyTitleView setLineBreakMode:UILineBreakModeWordWrap];
		
		storyDescriptionView = [[UILabel alloc] initWithFrame:CGRectZero];
		storyDescriptionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		[storyDescriptionView setFont:[UIFont boldSystemFontOfSize:12]];
		[storyDescriptionView setTextColor:[UIColor grayColor]];
		[storyDescriptionView setLineBreakMode:UILineBreakModeTailTruncation];
		
		secondaryDescriptionView = [[UILabel alloc] initWithFrame:CGRectZero];
		secondaryDescriptionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		[secondaryDescriptionView setFont:[UIFont systemFontOfSize:12]];
		[secondaryDescriptionView setTextColor:[UIColor grayColor]];
		[secondaryDescriptionView setLineBreakMode:UILineBreakModeTailTruncation];

		[[self contentView] addSubview:storyTitleView];
		[[self contentView] addSubview:storyDescriptionView];
		[[self contentView] addSubview:secondaryDescriptionView];
		
		storyImage = [[TTImageView alloc] initWithFrame:CGRectZero];
		storyImage.defaultImage = [UIImage imageNamed:@"noimage.png"];

		storyImage.autoresizesToImage = NO;
		storyImage.autoresizesSubviews = NO;
		storyImage.contentMode = UIViewContentModeScaleAspectFill;
		storyImage.clipsToBounds = YES;
		storyImage.opaque = YES;
		storyImage.backgroundColor = [UIColor whiteColor];
		storyImage.style =  [TTSolidFillStyle styleWithColor:[UIColor clearColor] 
														next:[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:6.0f] 
																					 next:[TTContentStyle styleWithNext:nil]]];

		[[self contentView] addSubview:storyImage];
        
        virtualAccessory = [[UIButton alloc] initWithFrame:CGRectZero];
        virtualAccessory.adjustsImageWhenHighlighted = NO;
        [virtualAccessory addTarget:self action:@selector(virtualAccessoryTapped:) forControlEvents:UIControlEventTouchUpInside];
        virtualAccessory.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
        virtualAccessory.backgroundColor = [UIColor clearColor];
        [self addSubview:virtualAccessory];
    }
	
    return self;
}

- (void)virtualAccessoryTapped:(id)sender
{
    UITableView *enclosingTable = (UITableView *)self.superview;
    if(self.accessoryView && enclosingTable.delegate && [enclosingTable.delegate respondsToSelector:@selector(virtualAccessoryViewTapped:)])
    {
        [enclosingTable.delegate virtualAccessoryViewTapped:self.accessoryView];
    }
}

- (void)layoutSubviews 
{
	[super layoutSubviews];
	
    CGRect cellRect = self.bounds;
	CGRect contentRect = self.contentView.bounds;
	CGRect labelRect = contentRect;

	//contentRect.size.width = 320;
	
	float yOffset = 4.0;
	if (contentRect.size.height > 68)
		yOffset = 8.0;
	
	storyImage.frame = CGRectMake(8, yOffset, 60, 60);

	//BOOL showThumbnails = [[NSUserDefaults standardUserDefaults] boolForKey:@"showStoryThumbnails"];
	
    virtualAccessory.frame = CGRectMake(cellRect.size.width-40, 0, 40, cellRect.size.height);
    
	if ([storyImage isHidden])
	{
		//[storyImage setHidden:YES];
		
		labelRect.origin.y = contentRect.origin.y + 4.0;
		labelRect.origin.x = contentRect.origin.x + 8.0;
		
		labelRect.size.width = contentRect.size.width - 14.0;
		labelRect.size.height = contentRect.size.height - 44.0;
	}
	else
	{
		//[storyImage setHidden:NO];

		labelRect.origin.y = labelRect.origin.y + 4.0;
		labelRect.origin.x = labelRect.origin.x + 16.0 + storyImage.frame.size.height;
				
		labelRect.size.width = contentRect.size.width - 22.0 - storyImage.frame.size.width;
		labelRect.size.height = contentRect.size.height - 44.0;		
	}
	
	storyTitleView.frame = labelRect;
	storyDescriptionView.frame = CGRectMake(labelRect.origin.x, CGRectGetHeight(contentRect) - 40.0, labelRect.size.width, 16);
	secondaryDescriptionView.frame = CGRectMake(labelRect.origin.x, CGRectGetHeight(contentRect) - 24.0, labelRect.size.width, 16);
}

- (void)dealloc 
{
	[story release];
	[storyTitleView release];
	[storyDescriptionView release];
	
	if (storyImage)
		[storyImage release];
	
    [super dealloc];
}

- (void)setHighlighted:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	
	//UIColor *titleColor = selected ? [UIColor colorWithRed:85.0/255.0 green:26.0/255.0 blue:139.0/255.0 alpha:1.0] : [UIColor blueColor];
	UIColor *titleColor = story.visited ? [UIColor colorWithRed:85.0/255.0 green:26.0/255.0 blue:139.0/255.0 alpha:1.0] : [UIColor blueColor];
	UIColor *finalColor = selected ? [UIColor whiteColor] : titleColor;
	UIColor *descriptionColor = selected ? [UIColor colorWithWhite:0.8 alpha:1.0] : [UIColor grayColor];
	
	[storyTitleView setTextColor:finalColor];
	[storyDescriptionView setTextColor:descriptionColor];
	[secondaryDescriptionView setTextColor:descriptionColor];
}

- (Story *)story
{
	return story;
}

- (void)setStory:(Story *)aStory 
{		
	[story autorelease];
	story = [aStory retain];

	if (!story)
	{
		[storyImage setUrlPath:nil];
		[storyTitleView setText:@""];
		[storyDescriptionView setText:@""];
		[secondaryDescriptionView setText:@""];
		return;
	}

	if ([[NSUserDefaults standardUserDefaults] boolForKey:showStoryThumbnailKey])
	{
		if ([story hasThumbnail])
		{
			[storyImage setHidden:NO];
			[storyImage setUrlPath:story.thumbnailURL];
		}
		else
		{
			[storyImage setHidden:YES];
		}
	}
	else
		[storyImage setHidden:YES];
	
	UIColor *titleColor = story.visited ? [UIColor colorWithRed:85.0/255.0 green:26.0/255.0 blue:139.0/255.0 alpha:1.0] : [UIColor blueColor];
	[storyTitleView setTextColor:titleColor];
	
	[storyTitleView setText:story.title];
	[storyTitleView setNeedsDisplay];
	
	[storyDescriptionView setText:[NSString stringWithFormat:@"%@", story.domain]];
	[storyDescriptionView setNeedsDisplay];
	
	[secondaryDescriptionView setText:[NSString stringWithFormat:@"%d points in %@ by %@", story.score, story.subreddit, story.author, story.totalComments, story.totalComments == 1  ? @"" : @"s"]];
	[secondaryDescriptionView setNeedsDisplay];
}

@end
