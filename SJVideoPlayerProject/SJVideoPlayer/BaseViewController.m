//
//  BaseViewController.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/11/14.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "BaseViewController.h"
#import <SJFullscreenPopGesture/UIViewController+SJVideoPlayerAdd.h>

@interface BaseViewController ()

@end

@implementation BaseViewController
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - -[%@ dealloc]", (int)__LINE__, NSStringFromClass([self class]));
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.sj_displayMode = SJPreViewDisplayMode_Origin;
}
@end
