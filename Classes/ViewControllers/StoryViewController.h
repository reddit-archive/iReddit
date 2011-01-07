//
//  StoryViewController.h
//  Reddit2
//
//  Created by Ross Boucher on 6/12/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "Story.h"
#import "AlienProgressView.h"

@interface StoryViewController : TTViewController <UIWebViewDelegate>
{
	BOOL		isForComments;
	
	UIWebView	*webview;
	UIButton	*scoreItem;
	UIButton	*commentCountItem;
	UIBarButtonItem	*toggleButtonItem;
	UIBarButtonItem *moreButtonItem;
	UISegmentedControl *segmentedControl;
	AlienProgressView  *loadingView;
	UIActionSheet *currentSheet;
	
	Story	*story;
}

@property (nonatomic, retain) IBOutlet UIWebView			*webview;
@property (nonatomic, retain) IBOutlet UIButton				*scoreItem;
@property (nonatomic, retain) IBOutlet UIButton				*commentCountItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem		*toggleButtonItem;	
@property (nonatomic, retain) IBOutlet UISegmentedControl	*segmentedControl;
@property (nonatomic, retain) IBOutlet AlienProgressView	*loadingView;

@property (nonatomic, retain) Story *story;

- (void)setStoryID:(NSString *)storyID commentID:(NSString *)commentID URL:(NSString *)aURL;
- (id)initForComments;

- (void)loadStoryComments;
- (void)loadStory;

- (IBAction)showComments:(id)sender;
- (IBAction)showStory:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)voteUp:(id)sender;
- (IBAction)voteDown:(id)sender;
- (IBAction)segmentAction:(id)sender;
- (void)saveCurrentStory:(id)sender;
- (void)saveOnInstapaper:(id)sender;
- (void)hideCurrentStory:(id)sender;

- (void)setScore:(int)score;
- (void)setNumberOfComments:(unsigned)num;

@end
