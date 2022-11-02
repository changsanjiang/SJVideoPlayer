![readme](https://user-images.githubusercontent.com/37614260/43947531-922a0712-9cb2-11e8-8f8d-4823a21308d3.png)

[![Build Status](https://travis-ci.org/changsanjiang/SJVideoPlayer.svg?branch=master)](https://travis-ci.org/changsanjiang/SJVideoPlayer)
[![Version](https://img.shields.io/cocoapods/v/SJVideoPlayer.svg?style=flat)](https://cocoapods.org/pods/SJVideoPlayer)
[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://github.com/changsanjiang)
[![License](https://img.shields.io/github/license/changsanjiang/SJVideoPlayer.svg)](https://github.com/changsanjiang/SJVideoPlayer/blob/master/LICENSE.md)

## [前往文档](https://github.com/changsanjiang/SJVideoPlayer/wiki)

# 安装
 
```ruby
pod 'SJVideoPlayer'
```

# 项目配置旋转

- step 1:
前往`Targets` -> `General` -> `Device Orientation` -> 选择 `Portrait`;
![](https://user-images.githubusercontent.com/25744224/101907041-ebdb2a00-3bf4-11eb-8d90-6faf1f9a73c8.png)

- step 2:
前往`AppDelegate`, 导入头文件`#import "SJRotationManager.h"`, 在`application:supportedInterfaceOrientationsForWindow:`中返回`[SJRotationManager supportedInterfaceOrientationsForWindow:window]`;
```Objective-C
#import "SJRotationManager.h"

@implementation AppDelegate
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return [SJRotationManager supportedInterfaceOrientationsForWindow:window];
}
@end

/// swift
/// class AppDelegate: UIResponder, UIApplicationDelegate {
///     func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> /// UIInterfaceOrientationMask {
///         return window.supportedInterfaceOrientations(window)
///     }
/// }
```

- step 3:
以下分类在项目中随便找个地方, 复制进去即可;
```Objective-C
@implementation UIViewController (RotationConfiguration)
- (BOOL)shouldAutorotate { 
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end


@implementation UITabBarController (RotationConfiguration)
- (UIViewController *)sj_topViewController {
    if ( self.selectedIndex == NSNotFound )
        return self.viewControllers.firstObject;
    return self.selectedViewController;
}

- (BOOL)shouldAutorotate {
    return [[self sj_topViewController] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [[self sj_topViewController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self sj_topViewController] preferredInterfaceOrientationForPresentation];
}
@end

@implementation UINavigationController (RotationConfiguration)
- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}
@end
``` 

- setup 4: iOS 13.0 之后, 需在自己的vc中实现`shouldAutorotate`, 并返回`NO`.
```Objective-C
@interface YourPlayerViewController ()
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation YourPlayerViewController 
- (BOOL)shouldAutorotate { 
    return NO;
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
    [_player vc_viewDidDisappear]; 
}
@end
```

# 快速开始

1. 导入头文件
```Objective-C
#import <SJVideoPlayer/SJVideoPlayer.h>
```

2. 添加`player`属性
```Objective-C
@interface ViewController ()
@property (nonatomic, strong, readonly) SJVideoPlayer *player;
@end
```

3. 创建`player`对象
```Objective-C
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _player = SJVideoPlayer.player;
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.offset(20);
        }
        make.left.right.offset(0);
        make.height.equalTo(self.player.view.mas_width).multipliedBy(9/16.0);
    }];
}

- (BOOL)shouldAutorotate {
    return NO;
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
    [_player vc_viewDidDisappear];
}
```

4. 通过URL进行播放
```Objective-C
SJVideoPlayerURLAsset *asset = [SJVideoPlayerURLAsset.alloc initWithURL:_media.URL];
_player.URLAsset = asset;
```

## Author

Email: changsanjiang@gmail.com

QQGroup: 610197491 (iOS 开发 2)

QQGroup: 930508201 (iOS 开发)(这个群满员了, 请加2群吧)

## 赞助
如果对您有所帮助，欢迎您的赞赏

<img src="https://github.com/changsanjiang/SJBaseVideoPlayer/blob/master/Project/Project/imgs/thanks_zfb.JPG?raw=true" width="200">
<img src="https://github.com/changsanjiang/SJBaseVideoPlayer/blob/master/Project/Project/imgs/thanks_wechat.JPG?raw=true" width="200">
