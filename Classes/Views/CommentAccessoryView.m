//
//  CommentAccessoryView.m
//  Reddit2
//
//  Created by Ross Boucher on 6/11/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "CommentAccessoryView.h"


@implementation CommentAccessoryView

@synthesize story;

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame])
	{
		self.backgroundColor = [UIColor whiteColor];
		self.opaque = YES;
        self.contentMode = UIViewContentModeCenter;
		[self setBackgroundImage:[[UIImage imageNamed:@"commentBubble.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:0.0] forState:UIControlStateNormal];
		
		self.titleEdgeInsets = UIEdgeInsetsMake(0.0, 1.0, 6.0, 0.0);
		self.titleLabel.font = [UIFont boldSystemFontOfSize:11.0];
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];
		[self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.75] forState:UIControlStateNormal];
		self.titleLabel.shadowOffset = CGSizeMake(0.0, -0.5);
    }
	
    return self;
}

- (void)setCommentCount:(unsigned)aCount
{
	[self setTitle:[NSString stringWithFormat:@"%u", aCount] forState:UIControlStateNormal];
}

- (void)dealloc
{
	self.story = nil;
    [super dealloc];
}


@end
