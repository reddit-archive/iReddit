//
//  AdField.h
//  Reddit2
//
//  Created by Ross Boucher on 6/11/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AdField : NSObject {
	UIView *adView;
}

@property (nonatomic, retain) UIView *adView;

- (UIColor *)adBackgroundColor;

@end
