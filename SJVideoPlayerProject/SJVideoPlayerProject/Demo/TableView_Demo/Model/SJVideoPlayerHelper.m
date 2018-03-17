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

NS_ASSUME_NONNULL_BEGIN

static NSString *kSJFilmEditingResultShareItemQQTitle = @"QQ";
static NSString *kSJFilmEditingResultShareItemWechatTitle = @"Wechat";
static NSString *kSJFilmEditingResultShareItemWeiboTitle = @"Weibo";
static NSString *kSJFilmEditingResultShareItemAlbumTitle = @"Album";

@interface SJVideoPlayerHelper ()<SJFilmEditingResultShareDelegate, SJMoreSettingItemsDelegate>

@property (nonatomic, strong, readwrite) SJVideoPlayer *videoPlayer;
@property (nonatomic, strong, readonly) SJMoreSettingItems *items;
@property (nonatomic, strong, readonly) SJFilmEditingResultUploader *uploader;
@property (nonatomic, strong, readonly) SJFilmEditingResultShare *resultShare;
@property (nonatomic, readwrite) BOOL savedToAblum;

@end

NS_ASSUME_NONNULL_END

@implementation SJVideoPlayerHelper
@synthesize uploader = _uploader;
@synthesize resultShare = _resultShare;

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
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    // fade in
    _videoPlayer.view.alpha = 0.001;
    [UIView animateWithDuration:0.5 animations:^{
        _videoPlayer.view.alpha = 1;
    }];
    
    // setting player
    __weak typeof(self) _self = self;
    
    _videoPlayer.prompt.update(^(SJPromptConfig * _Nonnull config) {
        config.backgroundColor = [UIColor colorWithWhite:0 alpha:0.618];
    });
    
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
    
    // show right control view.
    _videoPlayer.enableFilmEditing = YES;
    _videoPlayer.filmEditingResultShare = self.resultShare;
    
    _videoPlayer.pausedToKeepAppearState = YES;
    
    _videoPlayer.moreSettings = self.items.moreSettings;
}

- (void)clearAsset {
    _videoPlayer.URLAsset = nil;
}

- (SJFilmEditingResultShare *)resultShare {
    if ( _resultShare ) return _resultShare;
    SJFilmEditingResultShareItem *qq = [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemQQTitle image:[UIImage imageNamed:@"qq"]];
    SJFilmEditingResultShareItem *wechat = [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemWechatTitle image:[UIImage imageNamed:@"wechat"]];
    SJFilmEditingResultShareItem *weibo = [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemWeiboTitle image:[UIImage imageNamed:@"weibo"]];
    SJFilmEditingResultShareItem *savoToAlbum = [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemAlbumTitle image:[UIImage imageNamed:@"album"]];
    _resultShare = [[SJFilmEditingResultShare alloc] initWithShateItems:@[qq, wechat, weibo, savoToAlbum]];
    _resultShare.delegate = self;
    return _resultShare;
}

#pragma mark - delegate methods

- (SJFilmEditingResultUploader *)prepareToExport {
    // clear old value.
    _uploader.progress = 0;             // 上传进度清零
    _uploader.uploaded = NO;
    _uploader.failed = NO;
    _uploader.exportedVideoURL = nil;
    _uploader.screenshot = nil;
    _savedToAblum = NO;
    return self.uploader;
}

- (void)successfulExportedVideo:(NSURL *)sandboxURL screenshot:(UIImage *)screenshot {
    
    // sample upload code...
    __weak typeof(self) _self = self;
    [self _uploadWithFileURL:sandboxURL progress:^(float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.uploader.progress = progress;          // need update this property when uploading.
    } completion:^(NSString *URLStr){
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.uploader.progress = 1;
        self.uploader.uploaded = YES;               // need update this property when uploaded.
        [self.videoPlayer showTitle:@"Upload Successful"];
    } failed:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.uploader.failed = YES;                 // need update this property when failed.
        [self.videoPlayer showTitle:@"Upload Failed"];
    }];
    
    // update new value.
    self.uploader.exportedVideoURL = sandboxURL;
    self.uploader.screenshot = screenshot;
}

- (void)successfulScreenshot:(UIImage *)screenshot {
    // need call your upload code..
    // need call your upload code..
    
    self.uploader.screenshot = screenshot;
    
    
    // some test code..
    NSURL *url = nil;
    [self successfulExportedVideo:url screenshot:screenshot];
}

- (void)_uploadWithImage:(UIImage *)image progress:(void(^)(float progress))progressBlock completion:(void(^)(NSString *URLStr))completion failed:(void(^)(void))failed {
    
    // your upload code ..
    // your upload code ..
    // your upload code ..
    
    // some test code..
    [self _uploadWithFileURL:nil progress:progressBlock completion:completion failed:failed];
}

- (void)_uploadWithFileURL:(NSURL *)fileURL progress:(void(^)(float progress))progressBlock completion:(void(^)(NSString *URLStr))completion failed:(void(^)(void))failed {
    
    // your upload code ..
    // your upload code ..
    // your upload code ..
    
    // some test code..
    __block float progress = 0;
    for ( int i = 1 ; i <= 10 ; ++i ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            progressBlock(progress = i * 0.1);
            if ( progress == 1 ) completion(@"http://www.github.com");
        });
    }
}

- (void)clickedItem:(SJFilmEditingResultShareItem *)item {
    
    if ( self.uploader.uploaded == NO ) {
        [self.videoPlayer showTitle:@"Uploading, please wait."];
        return;
    }
    
    if ( self.uploader.failed == YES ) {
        [self.videoPlayer showTitle:@"Can't continue! The operation failed!"];
        return;
    }
    
    if ( item.title == kSJFilmEditingResultShareItemAlbumTitle ) {
        if ( self.savedToAblum ) {
            [self.videoPlayer showTitle:@"Saved"];
            return;
        }
        
        [self.videoPlayer showTitle:@"Saving" duration:-1];
        
        if ( self.uploader.exportedVideoURL ) {
            UISaveVideoAtPathToSavedPhotosAlbum(self.uploader.exportedVideoURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
        }
        else {
            UIImageWriteToSavedPhotosAlbum(self.uploader.screenshot, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
    }
    else {
        [self.videoPlayer showTitle:[NSString stringWithFormat:@"Clicked %@", item.title]];
        __weak typeof(self) _self = self;
        // exit editing
        [self.videoPlayer exitFilmEditingCompletion:^(SJVideoPlayer * _Nonnull player) {
            // rotate
            [player rotate:SJRotateViewOrientation_Portrait animated:YES completion:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                // push
                UIViewController *newVC = [[self.viewController class] new];
                [self.viewController.navigationController pushViewController:newVC animated:YES];
            }];
        }];

    }
}

- (void)clickedCancelButton {
    if ( self.uploader.failed ) {
        [self.videoPlayer exitFilmEditingCompletion:nil];
    }
    else if ( !self.uploader.uploaded ) {
        [self.videoPlayer showTitle:@"Uploading, please wait."];
    }
    else {
        [self.videoPlayer exitFilmEditingCompletion:nil];
    }
}

// Save video to album SEL.
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( error ) {
        [self.videoPlayer showTitle:@"Save failed" duration:2];
    }
    else {
        self.savedToAblum = YES;
        [self.videoPlayer showTitle:@"Save successfully" duration:2];
    }
}

// Save image to album SEL.
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( error ) {
        [self.videoPlayer showTitle:@"Save failed" duration:2];
    }
    else {
        self.savedToAblum = YES;
        [self.videoPlayer showTitle:@"Save successfully" duration:2];
    }
}

#pragma mark -

- (SJVideoPlayerURLAsset *)asset {
    return self.videoPlayer.URLAsset;
}

- (void (^)(void))vc_viewDidAppearExeBlock {
    __weak typeof(self) _self = self;
    return ^ () {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        self.videoPlayer.disableRotation = NO;
        
        if ( [self.viewController respondsToSelector:@selector(needConvertAsset)] ) {
            if ( [self.viewController needConvertAsset] == NO ) [self.asset convertToOriginal];
        }
        else {
            [self.asset convertToOriginal];
        }
        
        if ( self.videoPlayer.isPlayOnScrollView ) {
            if ( self.videoPlayer.isScrollAppeared ) [self.videoPlayer play];
        }
        else {
            [self.videoPlayer play];
        }
    };
}

- (void (^)(void))vc_viewWillDisappearExeBlock {
    __weak typeof(self) _self = self;
    return ^ () {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.videoPlayer.disableRotation = YES;   // 界面将要消失的时候, 禁止旋转.
        if ( [self.viewController respondsToSelector:@selector(needConvertAsset)] ) {
            if ( [self.viewController needConvertAsset] ) [self clearAsset];
        }
    };
}

- (void (^)(void))vc_viewDidDisappearExeBlock {
    __weak typeof(self) _self = self;
    return ^ () {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.asset.converted ) [self.videoPlayer pause];
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

#pragma mark -
- (SJFilmEditingResultUploader *)uploader {
    if ( _uploader ) return _uploader;
    _uploader = [SJFilmEditingResultUploader new];
    return _uploader;
}
@end
