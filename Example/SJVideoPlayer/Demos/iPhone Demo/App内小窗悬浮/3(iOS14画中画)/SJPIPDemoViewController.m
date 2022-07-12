//
//  SJPIPDemoViewController.m
//  SJVideoPlayer_Example
//
//  Created by 蓝舞者 on 2022/7/12.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJPIPDemoViewController.h"
#import "SJVideoPlayer.h"
#import "Masonry.h"
#import "SJSourceURLs.h"
#import "SJAttributesFactory.h"

#import <objc/message.h>

@interface SJVideoPlayer (SJPictureInPictureAdditions)
@property (nonatomic, strong, nullable) UIViewController *pip_sourceViewController;
@end

@implementation SJVideoPlayer (SJPictureInPictureAdditions)
- (void)setPip_sourceViewController:(UIViewController *)pip_sourceViewController {
    objc_setAssociatedObject(self, @selector(pip_sourceViewController), pip_sourceViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable UIViewController *)pip_sourceViewController {
    return objc_getAssociatedObject(self, _cmd);
}
@end

@interface UIViewController (SJPictureInPictureAdditions)
+ (UIViewController *)pip_appTopViewController;
@end

@implementation UIViewController (SJPictureInPictureAdditions)
+ (UIViewController *)pip_appTopViewController {
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (  [vc isKindOfClass:[UINavigationController class]] ||
             [vc isKindOfClass:[UITabBarController class]] ||
              vc.presentedViewController ) {
        if ( [vc isKindOfClass:[UINavigationController class]] )
            vc = [(UINavigationController *)vc topViewController];
        if ( [vc isKindOfClass:[UITabBarController class]] )
            vc = [(UITabBarController *)vc selectedViewController];
        if ( vc.presentedViewController )
            vc = vc.presentedViewController;
    }
    return vc;
}
@end

@interface SJPIPDemoViewController ()
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJPIPDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIView *superview = [UIView.alloc initWithFrame:CGRectZero];
    superview.backgroundColor = UIColor.blackColor;
    [self.view addSubview:superview];
    [superview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.centerY.offset(0);
        make.height.mas_equalTo(superview.mas_width).multipliedBy(9/16.0);
    }];
    
    _player = [SJVideoPlayer.alloc init];
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0];
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _player.view.frame = superview.bounds;
    [superview addSubview:_player.view];
    
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"请右上角点击画中画按钮, 进入画中画模式");
        make.font([UIFont systemFontOfSize:14]);
        make.textColor(UIColor.whiteColor);
        make.alignment(NSTextAlignmentCenter);
    }] duration:-1];
    
    if ( @available(iOS 14.0, *) ) {
        __weak typeof(self) _self = self;
        _player.playbackObserver.pictureInPictureStatusDidChangeExeBlock = ^(SJVideoPlayer *player) {
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
            switch ( player.playbackController.pictureInPictureStatus ) {
                case SJPictureInPictureStatusRunning: {
                    player.pip_sourceViewController = self;
                    
                    // 进入画中画后, 退出当前的控制器
                    if      ( player.isFullscreen ) {
                        [player rotate:SJOrientation_Portrait animated:YES completion:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    }
                    else if ( player.isFitOnScreen ) {
                        [player setFitOnScreen:NO animated:YES completionHandler:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    }
                    else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
                    break;
                case SJPictureInPictureStatusStopped: {
                    player.pip_sourceViewController = nil;
                }
                    break;
                default:break;
            }
        };
        
        _player.playbackController.restoreUserInterfaceForPictureInPictureStop = ^(id<SJVideoPlayerPlaybackController>  _Nonnull controller, void (^ _Nonnull completionHandler)(BOOL)) {
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
            UIViewController *topViewController = UIViewController.pip_appTopViewController;
            UINavigationController *nav = topViewController.navigationController;
            if ( nav != nil ) [nav pushViewController:self animated:YES];
            completionHandler(YES);
        };
    }
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ( @available(iOS 14.0, *) ) {
        if ( _player.playbackController.pictureInPictureStatus != SJPictureInPictureStatusRunning ) [_player vc_viewDidDisappear];
    }
}
@end
