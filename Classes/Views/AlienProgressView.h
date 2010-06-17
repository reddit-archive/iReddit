//
//  AlienProgressView.h
//  Reddit
//
//  Created by Ross Boucher on 12/26/08.
//  Copyright 2008 280 North. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AlienProgressView : UIControl 
{
	UIImageView *imageView;
	NSArray		*images;
	
	BOOL		isAnimating;
	int			status;
}

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;
- (void)doInit;

@end
