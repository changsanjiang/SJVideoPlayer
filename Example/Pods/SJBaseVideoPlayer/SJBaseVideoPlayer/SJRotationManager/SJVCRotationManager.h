//
//  SJVCRotationManager.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/9/20.
//  Copyright © 2018 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJRotationManagerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJVCRotationManager : NSObject<SJRotationManagerProtocol>
- (instancetype)initWithViewController:(__weak UIViewController *)atViewController;
- (instancetype)initWithViewController:(__weak UIViewController *)atViewController fullscreenToView:(nullable UIView *)fullscreenToView;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;

/// These methods, please call in the controller at the right time
/// 这些方法， 请在控制器中适时调用
- (void)vc_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;
- (BOOL)vc_shouldAutorotate;
- (UIInterfaceOrientationMask)vc_supportedInterfaceOrientations;
- (UIInterfaceOrientation)vc_preferredInterfaceOrientationForPresentation;
@end
NS_ASSUME_NONNULL_END



/*
 - 默认情况下, 播放器将只旋转播放界面, ViewController并不会旋转.
 - 当您想要旋转ViewController时, 可以采用此管理类进行旋转.
 - 使用示例:

 1. 在 viewController 中创建一个旋转管理对象
 
 @interface ViewController ()
 @property (nonatomic, strong) SJVideoPlayer *player;
 @property (nonatomic, strong) SJVCRotationManager *rotationManager;
 @end
 
 - (void)viewDidLoad {
    [super viewDidLoad];

    // 创建并替换播放器原始旋转管理类
    _rotationManager = [[SJVCRotationManager alloc] initWithViewController:self];
    _player.rotationManager = _rotationManager;
 }

 
 2. 将以下代码copy到 viewController 中。
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [_rotationManager vc_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (BOOL)shouldAutorotate {
    return [self.rotationManager vc_shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.rotationManager vc_supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.rotationManager vc_preferredInterfaceOrientationForPresentation];
}
*/
