
//
//  SJSharedVideoPlayerHelper.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/23.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJSharedVideoPlayerHelper.h"
#import <UIViewController+SJVideoPlayerAdd.h>
#import "SJMoreSettingItems.h"
#import <Masonry.h>
#import "SJVideoPlayer.h"

#pragma mark -

NS_ASSUME_NONNULL_BEGIN
@interface SJSharedVideoPlayerHelper ()<SJMoreSettingItemsDelegate>

@property (nonatomic, strong, readonly) SJMoreSettingItems *items;
@property (nonatomic, weak, readwrite, nullable) UIViewController<SJSharedVideoPlayerHelperUseProtocol> *viewController;

@end
NS_ASSUME_NONNULL_END

@implementation SJSharedVideoPlayerHelper
@synthesize items = _items;

+ (instancetype)sharedHelper {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    
    // 设置更多视图中的`items`
    [SJVideoPlayer sharedPlayer].moreSettings = self.items.moreSettings;  // 配置`更多页面`展示的`item`

    /// 配置单例播放器
    __weak typeof(self) _self = self;
    // 点击返回按钮执行的block.
    [SJVideoPlayer sharedPlayer].clickedBackEvent = ^(SJVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.viewController ) return;
        [player stop];
        [self.viewController.navigationController popViewControllerAnimated:YES];
    };
    
    // 屏幕旋转执行的block
    [SJVideoPlayer sharedPlayer].rotatedScreen = ^(SJVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( !self.viewController ) return;
        [UIView animateWithDuration:0.25 animations:^{
            [self.viewController setNeedsStatusBarAppearanceUpdate]; // 屏幕旋转的时候, 更新状态栏状态
        }];
    };
    
    // 控制层[显示/或隐藏]执行的block
    [SJVideoPlayer sharedPlayer].controlLayerAppearStateChanged = ^(SJVideoPlayer * _Nonnull player, BOOL displayed) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.viewController ) return;
        [UIView animateWithDuration:0.25 animations:^{
            [self.viewController setNeedsStatusBarAppearanceUpdate]; // 控制层显示的时候, 更新状态栏状态
        }];
    };
    return self;
}

- (void)setViewController:(UIViewController<SJSharedVideoPlayerHelperUseProtocol> *)viewController {
    if ( viewController == _viewController ) return;
    _viewController = viewController;
    
    // 全屏手势触发时, 禁止播放器旋转
    viewController.sj_viewWillBeginDragging = ^(UIViewController * _Nonnull vc) {
        [SJVideoPlayer sharedPlayer].disableRotation = YES; // 全屏手势触发时, 禁止播放器旋转
    };
    
    // 全屏手势结束时, 恢复播放器旋转
    viewController.sj_viewDidEndDragging = ^(UIViewController * _Nonnull vc) {
        [SJVideoPlayer sharedPlayer].disableRotation = NO; // 恢复
    };
}

- (void (^)(UIViewController<SJSharedVideoPlayerHelperUseProtocol> * _Nonnull, SJVideoPlayerURLAsset * _Nullable))vc_viewWillAppearExeBlock {
    __weak typeof(self) _self = self;
    return ^ (UIViewController<SJSharedVideoPlayerHelperUseProtocol> *vc, SJVideoPlayerURLAsset *asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [SJVideoPlayer sharedPlayer].disableRotation = NO;  // 界面将要显示的时候, 恢复旋转.
        [vc.playerBackgroundView addSubview:[SJVideoPlayer sharedPlayer].view];
        [[SJVideoPlayer sharedPlayer].view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
        self.viewController = vc;

        [[SJVideoPlayer sharedPlayer] stop];    // stop
        
        if ( asset ) {
            [SJVideoPlayer sharedPlayer].URLAsset = asset;  // 继续播放记录的 asset.
        }
    };
}

- (void (^)(void))vc_viewWillDisappearExeBlock {
    __weak typeof(self) _self = self;
    return ^ () {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [SJVideoPlayer sharedPlayer].disableRotation = YES;  // 界面将要消失的时候, 禁止旋转. (考虑用户体验)
        [[SJVideoPlayer sharedPlayer] stop];                 // 界面将要消失的时候, 暂停或者stop都可以. 最好是stop. 这样可以清空播放器的资源.
    };
}

- (BOOL (^)(void))vc_prefersStatusBarHiddenExeBlock {
    return ^BOOL () {
        // 全屏播放时, 使状态栏根据控制层显示或隐藏
        if ( [SJVideoPlayer sharedPlayer].isFullScreen ) return ![SJVideoPlayer sharedPlayer].controlLayerAppeared;
        return NO;
    };
}

- (UIStatusBarStyle (^)(void))vc_preferredStatusBarStyleExeBlock {
    return ^UIStatusBarStyle () {
        // 全屏播放时, 使状态栏变成白色
        if ( [SJVideoPlayer sharedPlayer].isFullScreen ) return UIStatusBarStyleLightContent;
        return UIStatusBarStyleDefault;
    };
}

- (void (^)(void))vc_deallocExeBlock {
    return ^() {
        [[SJVideoPlayer sharedPlayer] stop];
        [SJVideoPlayer sharedPlayer].disableRotation = NO;      // 恢复
    };
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
            [[SJVideoPlayer sharedPlayer] showTitle:@"分享到微信"];
        }
            break;
        case SJSharePlatform_Weibo: {
            [[SJVideoPlayer sharedPlayer] showTitle:@"分享到微博"];
        }
            break;
        case SJSharePlatform_QQ: {
            [[SJVideoPlayer sharedPlayer] showTitle:@"分享到QQ"];
        }
            break;
        case SJSharePlatform_Unknown: break;
    }
}

- (void)clickedDownloadItem {
    [[SJVideoPlayer sharedPlayer] showTitle:@"点击下载"];
}

- (void)clickedCollectItem {
    [[SJVideoPlayer sharedPlayer] showTitle:@"点击收藏"];
}

@end

