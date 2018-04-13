//
//  SJVideoPlayerHelper.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerHelper.h"
#import <SJFullscreenPopGesture/UIViewController+SJVideoPlayerAdd.h>
#import "SJVideoPlayer.h"
#import <Masonry/Masonry.h>
#import "SJFilmEditingResultShareItem.h"
#import "SJMoreSettingItems.h"
#import "SJMediaDownloader.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *kSJFilmEditingResultShareItemWechatTimeLineTitle = @"朋友圈";
static NSString *kSJFilmEditingResultShareItemCopyLinkTitle = @"复制链接";
static NSString *kSJFilmEditingResultShareItemAlbumTitle = @"保存本地";
static NSString *kSJFilmEditingResultShareItemQZoneTitle = @"QQ空间";
static NSString *kSJFilmEditingResultShareItemWechatTitle = @"微信";
static NSString *kSJFilmEditingResultShareItemWeiboTitle = @"微博";
static NSString *kSJFilmEditingResultShareItemQQTitle = @"QQ";

typedef NS_ENUM(NSUInteger, SJLightweightTopItemFlag) {
    SJLightweightTopItemFlag_Download,
    SJLightweightTopItemFlag_Share,
};

@interface SJVideoPlayerHelper ()<SJMoreSettingItemsDelegate>

@property (nonatomic, strong, nullable) SJVideoPlayer *videoPlayer; // current video player
@property (nonatomic, strong, readonly) SJMoreSettingItems *items;  // 点击更多, 出现的item
@property (nonatomic) SJVideoPlayerType playerType;

@property (nonatomic, strong, readonly) NSArray<SJFilmEditingResultShareItem *> *resultShareItems;
@property (nonatomic, strong, readonly) NSArray<SJLightweightTopItem *> *topControlItems;
@property (nonatomic) BOOL savedResult; // 截取出来的result(视频/截图/GIF), 是否保存到了本地

@end

NS_ASSUME_NONNULL_END

#import "TestUploader.h" // test test test test test

@implementation SJVideoPlayerHelper

- (instancetype)initWithViewController:(__weak UIViewController<SJVideoPlayerHelperUseProtocol> *)viewController {
    return [self initWithViewController:viewController playerType:0];
}

- (instancetype)initWithViewController:(__weak UIViewController<SJVideoPlayerHelperUseProtocol> *)viewController playerType:(SJVideoPlayerType)playerType {
    self = [super init];
    if ( !self ) return nil;
    self.uploader = [TestUploader sharedManager]; // test test test test test
    self.viewController = viewController;
    self.playerType = playerType;
    return self;
}

- (void)setViewController:(UIViewController<SJVideoPlayerHelperUseProtocol> *)viewController {
    if ( viewController == _viewController ) return;
    _viewController = viewController;
    
    // pop gesture
    __weak typeof(self) _self = self;
    viewController.sj_viewWillBeginDragging = ^(UIViewController *vc) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        // video player stop roatation
        self.videoPlayer.disableRotation = YES;   // 触发全屏手势时, 禁止播放器旋转
    };
    
    viewController.sj_viewDidEndDragging = ^(UIViewController *vc) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        // video player enable roatation
        self.videoPlayer.disableRotation = NO;    // 恢复旋转
    };
}

- (void)playWithAsset:(SJVideoPlayerURLAsset *)asset playerParentView:(nonnull UIView *)playerParentView {
    // old player fade out
    [_videoPlayer stopAndFadeOut];
    
    self.savedResult = NO; // reset
    
    // create new player
    switch ( _playerType ) {
        case SJVideoPlayerType_Default: {
            _videoPlayer = [SJVideoPlayer player];
        }
            break;
        case SJVideoPlayerType_Lightweight: {
            _videoPlayer = [SJVideoPlayer lightweightPlayer];
        }
            break;
    }
    
    // set asset
    _videoPlayer.URLAsset = asset;
    _videoPlayer.pausedToKeepAppearState = YES;
    
    
    [playerParentView addSubview:_videoPlayer.view];
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    // fade in
    _videoPlayer.view.alpha = 0.001;
    [UIView animateWithDuration:0.5 animations:^{
        self->_videoPlayer.view.alpha = 1;
    }];
    
    // setting player
    __weak typeof(self) _self = self;
    _videoPlayer.clickedBackEvent = ^(SJVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.viewController.navigationController popViewControllerAnimated:YES];
    };
    
    _videoPlayer.willRotateScreen = ^(SJVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [UIView animateWithDuration:0.25 animations:^{
            [self.viewController setNeedsStatusBarAppearanceUpdate];
        }];
    };
    
    // Call when the `control view` is `hidden` or `displayed`.
    _videoPlayer.controlLayerAppearStateChanged = ^(SJVideoPlayer * _Nonnull player, BOOL displayed) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [UIView animateWithDuration:0.25 animations:^{
            [self.viewController setNeedsStatusBarAppearanceUpdate];
        }];
    };
    
    // 开启截取功能
    _videoPlayer.enableFilmEditing = YES;
    //    _videoPlayer.filmEditingConfig.resultNeedUpload = NO;
    _videoPlayer.filmEditingConfig.resultShareItems = self.resultShareItems;
    _videoPlayer.filmEditingConfig.resultUploader = self.uploader;
    _videoPlayer.filmEditingConfig.clickedResultShareItemExeBlock = ^(SJVideoPlayer * _Nonnull player, SJFilmEditingResultShareItem * _Nonnull item, id<SJVideoPlayerFilmEditingResult>  _Nonnull result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        NSLog(@"%d - %s", (int)__LINE__, __func__);
        
        if ( item.title == kSJFilmEditingResultShareItemAlbumTitle ) {
            [self _saveResult:result];
        }
        else {
            // test test test
            [player showTitle:item.title duration:1 hiddenExeBlock:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
                [player dismissFilmEditingViewCompletion:^(SJVideoPlayer * _Nonnull player) {
                    [player rotate:SJRotateViewOrientation_Portrait animated:YES completion:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
                        __strong typeof(_self) self = _self;
                        if ( !self ) return;
                        // test test test
                        [self.viewController.navigationController pushViewController:[[self.viewController class] new] animated:YES];
                    }];
                }];
            }];
        }
    };
    
    switch ( _playerType ) {
        case SJVideoPlayerType_Lightweight: {
            // setting lightweight control layer top items
            _videoPlayer.topControlItems = self.topControlItems;
            __weak typeof(self) _self = self;
            _videoPlayer.clickedTopControlItemExeBlock = ^(SJVideoPlayer * _Nonnull player, SJLightweightTopItem * _Nonnull item) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;

                NSLog(@"%d - %s", (int)__LINE__, __func__);
                
                void(^promptHiddenExeBlock)(SJVideoPlayer *player) = ^(SJVideoPlayer *player) {
                    /// test test test test test test
                    [player rotate:SJRotateViewOrientation_Portrait animated:YES completion:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
                        __strong typeof(_self) self = _self;
                        if ( !self ) return;
                        [self.viewController.navigationController pushViewController:[[self.viewController class] new] animated:YES];
                    }];
                };
                
                NSString *prompt = nil;
                switch ( (SJLightweightTopItemFlag)item.flag ) {
                    case SJLightweightTopItemFlag_Share: {
                        prompt = @"clicked share";
                    }
                        break;
                    case SJLightweightTopItemFlag_Download: {
                        prompt = @"clicked download";
                    }
                        break;
                }
                [player showTitle:prompt duration:0.5 hiddenExeBlock:promptHiddenExeBlock];
            };
        }
            break;
        case SJVideoPlayerType_Default: {
            _videoPlayer.moreSettings = self.items.moreSettings;
        }
            break;
    }
}

- (void)clearAsset {
    _videoPlayer.URLAsset = nil;
}

/// 截取出的result(视频/GIF/图片)的操作Items
@synthesize resultShareItems = _resultShareItems;
- (NSArray<SJFilmEditingResultShareItem *> *)resultShareItems {
    if ( _resultShareItems ) return _resultShareItems;
    SJFilmEditingResultShareItem *save = [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemAlbumTitle image:[UIImage imageNamed:@"result_save"]];
    /**
     Whether can clicked When Uploading.
     上传时, 是否可以点击
     */
    save.canAlsoClickedWhenUploading = YES;
    
    SJFilmEditingResultShareItem *qq = [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemQQTitle image:[UIImage imageNamed:@"result_qq"]];
    SJFilmEditingResultShareItem *qzone = [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemQZoneTitle image:[UIImage imageNamed:@"result_qzone"]];
    SJFilmEditingResultShareItem *wechat = [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemWechatTitle image:[UIImage imageNamed:@"result_wechat_friend"]];
    SJFilmEditingResultShareItem *wechatTimeLine = [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemWechatTimeLineTitle image:[UIImage imageNamed:@"result_wechat_timeLine"]];
    SJFilmEditingResultShareItem *weibo = [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemWeiboTitle image:[UIImage imageNamed:@"result_webo"]];
    SJFilmEditingResultShareItem *linkCopy = [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemCopyLinkTitle image:[UIImage imageNamed:@"result_link_copy"]];
    _resultShareItems = @[save, qq, qzone, wechat, wechatTimeLine, weibo, linkCopy];
    return _resultShareItems;
}

#pragma mark - delegate methods
/// 保存截取出来的result(视频/GIF/图片)
- (void)_saveResult:(id<SJVideoPlayerFilmEditingResult>)result {
    if ( self.savedResult ) {
        [self.videoPlayer showTitle:@"Saved"];
        return;
    }
    
    switch ( result.operation ) {
        case SJVideoPlayerFilmEditingOperation_Screenshot:
        case SJVideoPlayerFilmEditingOperation_GIF: {
            UIImageWriteToSavedPhotosAlbum(result.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            UISaveVideoAtPathToSavedPhotosAlbum(result.fileURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
        }
            break;
    }
}

// Save video to album SEL. 保存好的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( error ) {
        [self.videoPlayer showTitle:@"Save failed" duration:2];
    }
    else {
        self.savedResult = YES;
        [self.videoPlayer showTitle:@"Save successfully" duration:2];
    }
}

// Save image to album SEL. 保存好的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( error ) {
        [self.videoPlayer showTitle:@"Save failed" duration:2];
    }
    else {
        self.savedResult = YES;
        [self.videoPlayer showTitle:@"Save successfully" duration:2];
    }
}

#pragma mark -

- (SJVideoPlayerURLAsset *)asset {
    return self.videoPlayer.URLAsset;
}

- (NSTimeInterval)currentTime {
    return self.videoPlayer.currentTime;
}

- (NSTimeInterval)totalTime {
    return self.videoPlayer.totalTime;
}

- (NSURL *)currentPlayURL {
    return self.videoPlayer.assetURL;
}

#pragma mark - 关于视图控制器的一些方法
- (void (^)(void))vc_viewDidAppearExeBlock {
    return ^ () {
        self.videoPlayer.disableRotation = NO;
        if ( !self.videoPlayer.isPlayOnScrollView || (self.videoPlayer.isPlayOnScrollView && self.videoPlayer.isScrollAppeared) ) {
            [self.videoPlayer play];
        }
    };
}

- (void (^)(void))vc_viewWillDisappearExeBlock {
    return ^ () {
        self.videoPlayer.disableRotation = YES;   // 界面将要消失的时候, 禁止旋转.
        if ( self.videoPlayer.state != SJVideoPlayerPlayState_Paused ) [self.videoPlayer pause];
    };
}

- (BOOL (^)(void))vc_prefersStatusBarHiddenExeBlock {
    return ^BOOL () {
        // 全屏播放时, 使状态栏根据控制层显示或隐藏
        if ( self.videoPlayer.isFullScreen ) return !self.videoPlayer.controlLayerAppeared;
        return NO;
    };
}

- (UIStatusBarStyle (^)(void))vc_preferredStatusBarStyleExeBlock {
    return ^UIStatusBarStyle () {
        // 全屏播放时, 使状态栏变成白色
        if ( self.videoPlayer.isFullScreen ) return UIStatusBarStyleLightContent;
        return UIStatusBarStyleDefault;
    };
}

#pragma mark -
@synthesize items = _items;
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

@synthesize topControlItems = _topControlItems;
- (NSArray<SJLightweightTopItem *> *)topControlItems {
    if ( _topControlItems ) return _topControlItems;
    _topControlItems =
    @[
      [[SJLightweightTopItem alloc] initWithFlag:SJLightweightTopItemFlag_Share imageName:@"share"],
      [[SJLightweightTopItem alloc] initWithFlag:SJLightweightTopItemFlag_Download imageName:@"download"],
      ];
    return _topControlItems;
}

@end
