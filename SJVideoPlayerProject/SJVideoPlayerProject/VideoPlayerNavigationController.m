//
//  VideoPlayerNavigationController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/28.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "VideoPlayerNavigationController.h"

@interface VideoPlayerNavigationController ()

@end

@implementation VideoPlayerNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.interactivePopGestureRecognizer.delegate action:@selector(handleNavigationTransition:)];
#pragma clang diagnostic pop
    pan.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:pan];
    
    self.interactivePopGestureRecognizer.enabled = NO;
    
    // Do any additional setup after loading the view.
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return self.childViewControllers.count > 0;
    
}

@end
