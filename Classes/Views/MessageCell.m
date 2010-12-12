//
//  MessageCell.m
//  Reddit
//
//  Created by Ross Boucher on 3/11/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "MessageCell.h"
#import "NSString+HTMLEncoding.h"

@implementation MessageCell

@synthesize message, subjectLabel, fromLabel, bodyLabel, dateLabel;

+ (float)tableView:(UITableView *)aTableView rowHeightForObject:(RedditMessage *)aMessage
{
    return [aMessage heightForDeviceMode:[[UIDevice currentDevice] orientation]];
}

- (id)initWithStyle:(UITableViewCellStyle)aStyle reuseIdentifier:(NSString *)reuseIdentifier 
{
    if (self = [super initWithStyle:aStyle reuseIdentifier:reuseIdentifier]) 
	{
		message = nil;
		
		fromLabel = [[UILabel alloc] initWithFrame:CGRectZero];		
		fromLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		[fromLabel setFont:[UIFont boldSystemFontOfSize:14]];
		[fromLabel setTextColor:[UIColor grayColor]];
		
		[fromLabel setLineBreakMode:UILineBreakModeTailTruncation];
		[fromLabel setNumberOfLines:1];
		
		
		subjectLabel = [[UILabel alloc] initWithFrame:CGRectZero];		
		subjectLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		[subjectLabel setFont:[UIFont boldSystemFontOfSize:14]];
		[subjectLabel setTextColor:[UIColor blueColor]];
		
		[subjectLabel setLineBreakMode:UILineBreakModeTailTruncation];
		[subjectLabel setNumberOfLines:0];
		
		
		bodyLabel = [[TTStyledTextLabel alloc] initWithFrame:CGRectZero];		
        bodyLabel.userInteractionEnabled = NO;
		bodyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[bodyLabel setFont:[UIFont systemFontOfSize:14]];
		[bodyLabel setTextColor:[UIColor blackColor]];
		
		dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];		
		dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
		
		[dateLabel setFont:[UIFont systemFontOfSize:14]];
		[dateLabel setTextColor:[UIColor grayColor]];
		
		[dateLabel setLineBreakMode:UILineBreakModeTailTruncation];
		[dateLabel setNumberOfLines:1];
				
		[[self contentView] addSubview:fromLabel];
		[[self contentView] addSubview:subjectLabel];
		[[self contentView] addSubview:bodyLabel];
		[[self contentView] addSubview:dateLabel];
	}
    
	return self;
}

- (void)setMessage:(RedditMessage *)aMessage 
{		
	[message autorelease];
	message = [aMessage retain];
	
	if (!message)
	{
		[bodyLabel setText:[TTStyledText textFromXHTML:@""]];
		[fromLabel setText:@""];
		[subjectLabel setText:@""];
		[dateLabel setText:@""];
	
		return;
	}
	
	[subjectLabel setText:message.subject];
	[bodyLabel setText:message.body];
	[fromLabel setText:message.author];
	[dateLabel setText:[NSString stringWithFormat:@"%@ ago", [message.created stringByConvertingUTCTimestampToFriendlyString]]];
	
	[bodyLabel setNeedsDisplay];
	[fromLabel setNeedsDisplay];
	[subjectLabel setNeedsDisplay];
	[dateLabel setNeedsDisplay];
}


- (void)layoutSubviews 
{
	[super layoutSubviews];

	CGSize size = [subjectLabel sizeThatFits:CGRectInset([self bounds], 20.0, 12.0).size];
	CGRect frame = subjectLabel.frame;
 
	frame.size = size;
	frame.origin.y = 6.0;
	frame.origin.x = 10.0;
 
	subjectLabel.frame = frame;

    CGSize constrainedSize = CGRectInset([self bounds], 20.0, 12.0).size;
    bodyLabel.text.width = constrainedSize.width;
	size = [bodyLabel sizeThatFits:constrainedSize];
	frame = bodyLabel.frame;
	
	frame.size = size;
	frame.origin.y = CGRectGetMaxY(subjectLabel.frame) + 6.0;
	frame.origin.x = 10.0;
	
	bodyLabel.frame = frame;
	
	size = [fromLabel sizeThatFits:CGRectInset([self bounds], 20.0, 12.0).size];
	frame = fromLabel.frame;
	
	frame.size = size;
	frame.origin.y = CGRectGetMaxY(bodyLabel.frame) + 6.0;
	frame.origin.x = 10.0;
	
	fromLabel.frame = frame;
	
	frame.origin.x = frame.size.width + 22.0;
	frame.size.width = CGRectGetWidth([self bounds]) - CGRectGetMinX(frame);
	
	dateLabel.frame = frame;
}

- (void)setHighlighted:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	
	UIColor *subjectColor = selected ? [UIColor whiteColor] : [UIColor blueColor];
	UIColor *bodyColor = selected ? [UIColor whiteColor] : [UIColor blackColor];
	UIColor *descriptionColor = selected ? [UIColor colorWithWhite:0.8 alpha:1.0] : 
										   (message.isNew ? [UIColor orangeColor] : [UIColor grayColor]);
	
	[bodyLabel setTextColor:bodyColor];
	[subjectLabel setTextColor:subjectColor];
	[fromLabel setTextColor:descriptionColor];
	[dateLabel setTextColor:descriptionColor];
}


- (void)dealloc 
{
	self.fromLabel = nil;
	self.subjectLabel = nil;
	self.bodyLabel = nil;
	self.message = nil;
	self.dateLabel = nil;

    [super dealloc];
}


@end
