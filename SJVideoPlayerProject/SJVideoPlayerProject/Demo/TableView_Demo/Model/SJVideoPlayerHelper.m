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

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerHelper ()<SJFilmEditingResultShareDelegate>

@property (nonatomic, strong, readwrite) SJVideoPlayer *videoPlayer;
@property (nonatomic, strong, readonly) SJFilmEditingResultUploader *uploader;

@end

NS_ASSUME_NONNULL_END

@implementation SJVideoPlayerHelper
@synthesize uploader = _uploader;

- (instancetype)initWithViewController:(__weak UIViewController<SJVideoPlayerHelperUseProtocol> *)viewController {
    self = [super init];
    if ( !self ) return nil;
    self.viewController = viewController;
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
    
    // create new player
    _videoPlayer = [SJVideoPlayer player];
    
    [playerParentView addSubview:_videoPlayer.view];
    _videoPlayer.view.frame = playerParentView.bounds;
    
    // fade in
    _videoPlayer.view.alpha = 0.001;
    [UIView animateWithDuration:0.5 animations:^{
        _videoPlayer.view.alpha = 1;
    }];
    
    // setting player
    __weak typeof(self) _self = self;
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
    
    _videoPlayer.clickedBackEvent = ^(SJVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.viewController.navigationController popViewControllerAnimated:YES];
    };
    
    // set asset
    _videoPlayer.URLAsset = asset;

    SJFilmEditingResultShareItem *qq = [[SJFilmEditingResultShareItem alloc] initWithTitle:@"QQ" image:[UIImage imageNamed:@"qq"]];
    SJFilmEditingResultShareItem *wechat = [[SJFilmEditingResultShareItem alloc] initWithTitle:@"Wechat" image:[UIImage imageNamed:@"wechat"]];
    SJFilmEditingResultShareItem *weibo = [[SJFilmEditingResultShareItem alloc] initWithTitle:@"Weibo" image:[UIImage imageNamed:@"weibo"]];
    SJFilmEditingResultShareItem *savoToAlbum = [[SJFilmEditingResultShareItem alloc] initWithTitle:@"Album" image:[UIImage imageNamed:@"album"]];

    SJFilmEditingResultShare *resultShare = [[SJFilmEditingResultShare alloc] initWithShateItems:@[qq, wechat, weibo, savoToAlbum]];
    resultShare.delegate = self;
    self.videoPlayer.filmEditingResultShare = resultShare;
}

- (SJFilmEditingResultUploader *)successfulScreenshot:(UIImage *)screenshot {
    __weak typeof(self) _self = self;
    [self _uploadWithImage:screenshot progress:^(float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.uploader.progress = progress;  // update progress
    } completion:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.uploader.progress = 1;
        self.uploader.uploaded = YES;       // completed upload
    } failed:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.uploader.failed = YES;         // upload failed
    }];
    
    _uploader.progress = 0;
    _uploader.uploaded = NO;
    return self.uploader;
}

- (void)_uploadWithImage:(UIImage *)image progress:(void(^)(float progress))progressBlock completion:(void(^)(void))completion failed:(void(^)(void))failed {
    // your upload code ..
    
    // test
    __block float progress = 0;
    for ( int i = 1 ; i <= 10 ; ++i ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            progressBlock(progress = i * 0.1);
            if ( progress == 1 ) completion();
        });
    }
}

- (void)_uploadWithFileURL:(NSURL *)fileURL progress:(void(^)(float progress))progressBlock completion:(void(^)(void))completion failed:(void(^)(void))failed {
    // your upload code ..
    
    
    // test
    __block float progress = 0;
    for ( int i = 1 ; i <= 10 ; ++i ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            progressBlock(progress = i * 0.1);
            if ( progress == 1 ) completion();
        });
    }
}

- (SJFilmEditingResultUploader *)successfulExportedVideo:(NSURL *)fileURL {
    __weak typeof(self) _self = self;
    [self _uploadWithFileURL:fileURL progress:^(float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.uploader.progress = progress;
    } completion:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.uploader.progress = 1;
        self.uploader.uploaded = YES;
    } failed:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.uploader.failed = YES;
    }];
    
    _uploader.progress = 0;
    _uploader.uploaded = NO;
    return self.uploader;
}

- (void)clickedItem:(SJFilmEditingResultShareItem *)item screenshot:(nullable UIImage *)screenshot recordedVideoFileURL:(nullable NSURL *)recordedVideoFileURL {
    if ( [item.title isEqualToString:@"Album"] ) {
        [self.videoPlayer showTitle:@"Saving" duration:-1];
        if ( recordedVideoFileURL ) {
            UISaveVideoAtPathToSavedPhotosAlbum(recordedVideoFileURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
        }
        else {
            UIImageWriteToSavedPhotosAlbum(screenshot, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
    }
    else {
        [self.videoPlayer showTitle:[NSString stringWithFormat:@"Clicked %@", item.title]];
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( error ) {
        [self.videoPlayer showTitle:@"Save failed" duration:2];
    }
    else {
        [self.videoPlayer showTitle:@"Save successfully" duration:2];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( error ) {
        [self.videoPlayer showTitle:@"Save failed" duration:2];
    }
    else {
        [self.videoPlayer showTitle:@"Save successfully" duration:2];
    }
}

#pragma mark -

- (SJVideoPlayerURLAsset *)asset {
    return self.videoPlayer.URLAsset;
}

- (void (^)(void))vc_viewWillAppearExeBlock {
    __weak typeof(self) _self = self;
    return ^ () {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.videoPlayer.disableRotation = NO;    // 界面显示的时候, 恢复旋转.
    };
}

- (void (^)(void))vc_viewDidAppearExeBlock {
    __weak typeof(self) _self = self;
    return ^ () {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        // fade in
        [UIView animateWithDuration:0.6 animations:^{
            self.videoPlayer.view.alpha = 1;
        }];
        if ( self.asset.converted ) [self.asset convertToOriginal];     // 如果资源被转化成其他类型, 恢复原样
        if ( self.videoPlayer.isScrollAppeared ) [self.videoPlayer play];
    };}

- (void (^)(void))vc_viewWillDisappearExeBlock {
    __weak typeof(self) _self = self;
    return ^ () {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.videoPlayer.disableRotation = YES;   // 界面将要消失的时候, 禁止旋转.
    };
}

- (void (^)(void))vc_viewDidDisappearExeBlock {
    __weak typeof(self) _self = self;
    return ^ () {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.videoPlayer pause];                 // 界面消失的时候, 暂停
        self.videoPlayer.view.alpha = 0.001;      // hidden
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
- (SJFilmEditingResultUploader *)uploader {
    if ( _uploader ) return _uploader;
    _uploader = [SJFilmEditingResultUploader new];
    return _uploader;
}
@end
