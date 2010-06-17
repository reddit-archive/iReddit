//
//  AlienProgressView.m
//  Reddit
//
//  Created by Ross Boucher on 12/26/08.
//  Copyright 2008 280 North. All rights reserved.
//

#import "AlienProgressView.h"

@implementation AlienProgressView

- (void)awakeFromNib
{
	[self doInit];
}

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
	{
		[self doInit];
    }
	
    return self;
}

- (void)doInit
{
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 101, 140)];
	
	[imageView setImage:[UIImage imageNamed:@"Loading0.png"]];
	
	images = [[NSArray alloc] initWithObjects:
			  [UIImage imageNamed:@"Loading4.png"],
			  [UIImage imageNamed:@"Loading3.png"],
			  nil];
	
	[self addSubview:imageView];
	
	isAnimating = NO;
}

- (void)startAnimating
{
	if (isAnimating)
		return;
	
	isAnimating = YES;
	status = 0;
	
	[self setHidden:NO];
	[imageView setImage:[UIImage imageNamed:@"Loading0.png"]];
	
	[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(updateAnimation) userInfo:nil repeats:NO];
}

- (void)updateAnimation
{
	switch (status)
	{
		case 0:
			status = 1;
			[imageView setImage:[UIImage imageNamed:@"Loading1.png"]];
			[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateAnimation) userInfo:nil repeats:NO];
			break;
		case 1:
			status = 2;
			[imageView setImage:[UIImage imageNamed:@"Loading2.png"]];
			[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateAnimation) userInfo:nil repeats:NO];
			break;
		case 2:
			[imageView setAnimationImages:images];
			[imageView setAnimationDuration:1];
			[imageView startAnimating];
			break;
		default:
			break;
	}
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self setHidden:YES];
	return NO;
}

- (void)stopAnimating
{
	isAnimating = NO;
	
	[imageView stopAnimating];
	[imageView setAnimationImages:nil];
}

- (BOOL)isAnimating
{
	return isAnimating;
}

- (void)dealloc 
{
	[imageView release];
	[images release];

    [super dealloc];
}


@end
