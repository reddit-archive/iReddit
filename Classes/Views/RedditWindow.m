//
//  RedditWindow.m
//  iReddit
//
//  Created by Ryan Bruels on 12/11/10.

//

#import "RedditWindow.h"
#import "Constants.h"

@implementation RedditWindow

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event 
{
    if (event.type == UIEventSubtypeMotionShake) 
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:DeviceDidShakeNotification object:nil];
    }
}

@end
