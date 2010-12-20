//
//  SubredditTableViewDelegate.m
//  iReddit
//
//  Created by Ryan Bruels on 12/12/10.

//

#import "SubredditTableViewDelegate.h"
#import "SubredditDataSource.h"

@interface SubredditTableViewDelegate ()
- (void)teardownRefreshingView;
- (void)refreshingHideAnimationStopped;
@end

static const CGFloat kRefreshingViewHeight = 22;

@implementation SubredditTableViewDelegate

// load more stories if we're at the bottom

- (id)initWithController:(TTTableViewController*)controller 
{
    if(self = [super initWithController:controller])
    {
        [self.controller.dataSource.model.delegates addObject:self];
    }
    return self;
}

- (void)virtualAccessoryViewTapped:(id)sender
{
    [self.controller.dataSource accessoryViewTapped:sender];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView 
{
    [super scrollViewDidEndDecelerating:scrollView];

    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height)
        if ([self.controller.dataSource.model respondsToSelector:@selector(canLoadMore)])
            if ([((SubredditDataModel *)self.controller.dataSource.model) canLoadMore])
            {                
                if(!_refreshingView)
                {
                    _refreshingView = [[TTActivityLabel alloc] initWithFrame:
                        CGRectMake(0, self.controller.tableView.frame.size.height + self.controller.tableView.frame.origin.y, self.controller.tableView.bounds.size.width, kRefreshingViewHeight)
                        style:TTActivityLabelStyleBlackBox text:@"Updating..."];
                    _refreshingView.userInteractionEnabled = NO;
                    _refreshingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                    _refreshingView.font = [UIFont boldSystemFontOfSize:12];

                    NSInteger tableIndex = [self.controller.view.subviews indexOfObject:self.controller.tableView];
                    [self.controller.view insertSubview:_refreshingView atIndex:tableIndex+1];

                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                    _refreshingView.frame = CGRectOffset(_refreshingView.frame, 0, -kRefreshingViewHeight);
                    [UIView commitAnimations];
                }
                
                [self.controller.dataSource.model load:TTURLRequestCachePolicyNoCache more:YES];
            }
}

- (void)modelDidFinishLoad:(id<TTModel>)model
{
    [self teardownRefreshingView];
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error
{
    [self teardownRefreshingView];
}

- (void)modelDidCancelLoad:(id<TTModel>)model
{
    [self teardownRefreshingView];
}

- (void)teardownRefreshingView
{
    if(_refreshingView)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:TT_TRANSITION_DURATION];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(refreshingHideAnimationStopped)];
        _refreshingView.alpha = 0;
        [UIView commitAnimations];
    }
}

- (void)refreshingHideAnimationStopped 
{
    [_refreshingView removeFromSuperview];
    [self.controller.tableView flashScrollIndicators];
    TT_RELEASE_SAFELY(_refreshingView);
}

- (void)dealloc
{
    [self.controller.dataSource.model.delegates removeObject:self];
    [super dealloc];
}

@end
