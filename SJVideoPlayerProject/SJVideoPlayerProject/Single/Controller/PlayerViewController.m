//
//  PlayerViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "PlayerViewController.h"
#import "SJVideoPlayer.h"
#import <Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import "SJMoreSettingItems.h"
#import <UIViewController+SJVideoPlayerAdd.h>

@interface PlayerViewController ()<SJMoreSettingItemsDelegate>

@property (nonatomic, strong) SJVideoPlayer *videoPlayer;
@property (nonatomic, strong, readonly) SJMoreSettingItems *items;

@end

@implementation PlayerViewController

@synthesize items = _items;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _playerVCSetupViews];
    [self _playerVCAccessNetwork];
    
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    [_videoPlayer stop];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _videoPlayer.disableRotation = NO;  // 界面将要显示的时候, 恢复旋转.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _videoPlayer.disableRotation = YES; // 界面将要消失的时候, 禁止旋转. (考虑用户体验)
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_videoPlayer pause];   // 界面消失的时候, 暂停播放
}

#pragma mark - networking

- (void)_playerVCAccessNetwork {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 模拟网络延时
        __strong typeof(_self) self = _self;
        if ( !self ) return;
//        self.videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[NSURL URLWithString:@"http://rec.app.lanwuzhe.com/recordings/z1.lanwuzhe.2071517398365077/1517398365_1517484765.m3u8"]]; // 播放网络视频
        
        self.videoPlayer.URLAsset = /** 播放本地视频*/
        [[SJVideoPlayerURLAsset alloc] initWithTitle:@"DIY心情转盘 #手工##手工制作#"
                                     alwaysShowTitle:YES
                                            assetURL:[[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"]];
    });
}


#pragma mark - setup views

- (void)_playerVCSetupViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _videoPlayer = [SJVideoPlayer sharedPlayer];
    [self.view addSubview:_videoPlayer.view];
    
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(SJ_is_iPhoneX() ? 34 : 20);
        make.leading.trailing.offset(0);
        make.height.equalTo(_videoPlayer.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    self.sj_viewWillBeginDragging = ^(PlayerViewController * _Nonnull vc) {
        vc.videoPlayer.disableRotation = YES; // 全屏手势触发时, 禁止播放器旋转
    };
    
    
    self.sj_viewDidEndDragging = ^(PlayerViewController * _Nonnull vc) {
        vc.videoPlayer.disableRotation = NO; // 恢复
    };
    
    
    [self _settingPlayer]; // 配置 默认的控制层
}

- (void)_settingPlayer {
    
    __weak typeof(self) _self = self;
    _videoPlayer.clickedBackEvent = ^(SJVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.videoPlayer stop];
        [self.navigationController popViewControllerAnimated:YES]; // 点击返回按钮执行的block.
    };
    
    
    _videoPlayer.rotatedScreen = ^(SJVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [UIView animateWithDuration:0.25 animations:^{
            [self setNeedsStatusBarAppearanceUpdate]; // 屏幕旋转的时候, 更新状态栏状态
        }];
    };
    
    
    _videoPlayer.controlLayerAppearStateChanged = ^(SJVideoPlayer * _Nonnull player, BOOL displayed) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [UIView animateWithDuration:0.25 animations:^{
            [self setNeedsStatusBarAppearanceUpdate]; // 控制层显示的时候, 更新状态栏状态
        }];
    };
    
    _videoPlayer.moreSettings = self.items.moreSettings;  // 配置`更多页面`展示的`item`
}


#pragma mark - 配置播放器`更多页面`展示的`item`

- (SJMoreSettingItems *)items {
    if ( _items ) return _items;
    _items = [SJMoreSettingItems new];
    _items.delegate = self;
    return _items;
}
- (void)clickedShareItem:(SJSharePlatform)platform {
    switch ( platform ) {
        case SJSharePlatform_Wechat: {
            [_videoPlayer showTitle:@"分享到微信"];
        }
            break;
        case SJSharePlatform_Weibo: {
            [_videoPlayer showTitle:@"分享到微博"];
        }
            break;
        case SJSharePlatform_QQ: {
            [_videoPlayer showTitle:@"分享到QQ"];
        }
            break;
        case SJSharePlatform_Unknown: break;
    }
}

- (void)clickedDownloadItem {
    [_videoPlayer showTitle:@"点击下载"];
}

- (void)clickedCollectItem {
    [_videoPlayer showTitle:@"点击收藏"];
}

#pragma mark -

- (BOOL)prefersStatusBarHidden {
    // 全屏播放时, 使状态栏根据控制层显示或隐藏
    if ( _videoPlayer.isFullScreen ) return !_videoPlayer.controlLayerAppeared;
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    // 全屏播放时, 使状态栏变成白色
    if ( _videoPlayer.isFullScreen ) return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
}
@end
