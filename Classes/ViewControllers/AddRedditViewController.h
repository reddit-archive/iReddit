//
//  AddRedditViewController.h
//  iReddit
//
//  Created by Ross Boucher on 7/2/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>

@interface AddRedditViewController : TTTableViewController 
{
	UINavigationBar *navigationBar;	
	TTURLRequest *activeRequest;
	
	BOOL shouldViewOnly;
}

@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (BOOL)shouldViewOnly;
- (id)initForViewing;

//private
- (void)loadReddit:(NSString *)redditURL;
- (void)requestFailed;


@end
