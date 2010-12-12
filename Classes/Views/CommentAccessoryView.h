//
//  CommentAccessoryView.h
//  Reddit2
//
//  Created by Ross Boucher on 6/11/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"

@interface CommentAccessoryView : UIButton 
{
	//UIButton *showCommentsButton;
	//UILabel  *commentCountLabel;
	Story *story;
}

- (void)setCommentCount:(unsigned)aCount;
@property (nonatomic, retain) Story *story;

@end
