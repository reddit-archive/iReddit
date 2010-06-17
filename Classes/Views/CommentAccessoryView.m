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

		showCommentsButton.backgroundColor = [UIColor whiteColor];

		showCommentsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 44.0)];

		[showCommentsButton setImage:[[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"commentBubble" ofType:@"png"]] autorelease] forState:UIControlStateNormal];
		
		showCommentsButton.adjustsImageWhenHighlighted = YES;
		
		[showCommentsButton setBackgroundColor:[UIColor whiteColor]];
		showCommentsButton.opaque = YES;
		
		commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0, 12.0, 18.0, 13.0)];
		
		commentCountLabel.opaque = NO;
		commentCountLabel.backgroundColor = [UIColor clearColor];
    
		commentCountLabel.textAlignment = UITextAlignmentCenter;
		commentCountLabel.adjustsFontSizeToFitWidth = YES;
		
		[commentCountLabel setFont:[UIFont boldSystemFontOfSize:10.0]];
		[commentCountLabel setTextColor:[UIColor whiteColor]];
		[commentCountLabel setShadowColor:[UIColor grayColor]];
		[commentCountLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
		
		[self addSubview:showCommentsButton];
		[self addSubview:commentCountLabel];
		
		[showCommentsButton addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
	}
	
    return self;
}

- (void)selected:(id)sender
{
	[target performSelector:action withObject:self];
}

- (void)setTarget:(id)aTarget action:(SEL)anAction
{
	target = aTarget;
	action = anAction;
}

- (void)setCommentCount:(unsigned)aCount
{
	[commentCountLabel setText:[NSString stringWithFormat:@"%u", aCount]];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	self.story = nil;
	[commentCountLabel release];
	[showCommentsButton release];
    [super dealloc];
}


@end
