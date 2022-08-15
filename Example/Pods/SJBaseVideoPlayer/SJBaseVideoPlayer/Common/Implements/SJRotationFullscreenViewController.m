//
//  SJRotationFullscreenViewController.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/8/14.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJRotationFullscreenViewController.h"

@interface SJRotationFullscreenView : UIView
@end

@implementation SJRotationFullscreenView
- (UIEdgeInsets)safeAreaInsets {
    CGSize size = self.bounds.size;
    if ( size.width > size.height ) return [super safeAreaInsets];
    return [UIApplication.sharedApplication.keyWindow safeAreaInsets];
}
@end

@implementation SJRotationFullscreenViewController

- (void)loadView {
    self.view = [SJRotationFullscreenView.alloc initWithFrame:UIScreen.mainScreen.bounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = NO;
    self.view.backgroundColor = UIColor.clearColor;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [_delegate preferredStatusBarStyleForRotationFullscreenViewController:self];
}

- (BOOL)prefersStatusBarHidden {
    return [_delegate prefersStatusBarHiddenForRotationFullscreenViewController:self];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}
@end
