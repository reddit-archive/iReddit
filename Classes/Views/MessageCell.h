//
//  MessageCell.h
//  Reddit
//
//  Created by Ross Boucher on 3/11/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedditMessage.h"
#import <Three20/Three20.h>

@interface MessageCell : UITableViewCell 
{
	RedditMessage *message;
	UILabel *fromLabel;
	UILabel *subjectLabel;
	TTStyledTextLabel *bodyLabel;
	UILabel *dateLabel;
}

@property (nonatomic,retain) RedditMessage *message;
@property (nonatomic,retain) UILabel *fromLabel;
@property (nonatomic,retain) UILabel *subjectLabel;
@property (nonatomic,retain) TTStyledTextLabel *bodyLabel;
@property (nonatomic,retain) UILabel *dateLabel;

@end
