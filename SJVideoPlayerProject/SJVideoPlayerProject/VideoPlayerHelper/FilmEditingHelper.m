//
//  FilmEditingHelper.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "FilmEditingHelper.h"
#import "SJVideoPlayer.h"
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN
static NSString *const kSJFilmEditingResultShareItemWechatTimeLineTitle = @"朋友圈";
static NSString *const kSJFilmEditingResultShareItemCopyLinkTitle = @"复制链接";
static NSString *const kSJFilmEditingResultShareItemAlbumTitle = @"保存本地";
static NSString *const kSJFilmEditingResultShareItemQZoneTitle = @"QQ空间";
static NSString *const kSJFilmEditingResultShareItemWechatTitle = @"微信";
static NSString *const kSJFilmEditingResultShareItemWeiboTitle = @"微博";
static NSString *const kSJFilmEditingResultShareItemQQTitle = @"QQ";



@interface SJUploader : NSObject<SJVideoPlayerFilmEditingResultUpload>
@end

@implementation SJUploader
- (void)upload:(id<SJVideoPlayerFilmEditingResult>)result progress:(void (^__nullable)(float))progressBlock success:(void (^__nullable)(void))success failure:(void (^__nullable)(NSError * _Nonnull))failure {
//    [YourUploader upload:]
}
- (void)cancelUpload:(id<SJVideoPlayerFilmEditingResult>)result {
//    [YourUploader cancel:]
}
@end



@interface FilmEditingHelper () {
    NSArray<SJFilmEditingResultShareItem *> *_resultShareItems;
    SJVideoPlayerFilmEditingConfig *_filmEditingConfig;
}

@property (nonatomic, strong, readonly) NSArray<SJFilmEditingResultShareItem *> *resultShareItems;
@property (nonatomic, weak, nullable) UIViewController *viewController;
@property (nonatomic, weak, nullable) SJVideoPlayer *player;
@property (nonatomic, strong) id<SJVideoPlayerFilmEditingResultUpload> uploader; // 上传. 截屏/导出视频/GIF 时使用.

@end

@implementation FilmEditingHelper

- (instancetype)initWithViewController:(__weak UIViewController *)viewController {
    self = [super init];
    if ( !self ) return nil;
    _viewController = viewController;
    
    __weak typeof(self) _self = self;
    _filmEditingConfig = [SJVideoPlayerFilmEditingConfig new];
    _filmEditingConfig.resultUploader = self.uploader = [SJUploader new];
    _filmEditingConfig.resultShareItems = self.resultShareItems;
    // 导出结果是否需要上传
    _filmEditingConfig.resultNeedUpload = NO;
    // 用户选择某个操作是否应该开始
    _filmEditingConfig.shouldStartWhenUserSelectedAnOperation = ^BOOL(__kindof SJBaseVideoPlayer *videoPlayer, SJVideoPlayerFilmEditingOperation selectedOperation) {
        
//        BOOL isLogout = YES;
//        if ( isLogout ) {
//            [videoPlayer showTitle:@"未登录 未登录 未登录 未登录"];
//            /* some code */
//            /* some code */
//            /* some code */
//            return NO;
//        }
        
        return YES;
    };

    _filmEditingConfig.clickedResultShareItemExeBlock = ^(SJVideoPlayer *player, SJFilmEditingResultShareItem *item, id<SJVideoPlayerFilmEditingResult> result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.player = player;
        [self _userClickedShareItem:item result:result];
    };
    return self;
}

- (NSArray<SJFilmEditingResultShareItem *> *)resultShareItems {
    if ( _resultShareItems ) return _resultShareItems;
    
    // 保存本地
    SJFilmEditingResultShareItem *save =
    [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemAlbumTitle image:[UIImage imageNamed:@"result_save"]];
    save.canAlsoClickedWhenUploading = YES; // Whether can clicked When Uploading.
    
    // QQ
    SJFilmEditingResultShareItem *qq =
    [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemQQTitle image:[UIImage imageNamed:@"result_qq"]];
    
    // 空间
    SJFilmEditingResultShareItem *qzone =
    [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemQZoneTitle image:[UIImage imageNamed:@"result_qzone"]];
    
    // 微信
    SJFilmEditingResultShareItem *wechat =
    [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemWechatTitle image:[UIImage imageNamed:@"result_wechat_friend"]];
    
    // 朋友圈
    SJFilmEditingResultShareItem *wechatTimeLine =
    [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemWechatTimeLineTitle image:[UIImage imageNamed:@"result_wechat_timeLine"]];
    
    // 微博
    SJFilmEditingResultShareItem *weibo =
    [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemWeiboTitle image:[UIImage imageNamed:@"result_webo"]];
    
    // 复制链接
    SJFilmEditingResultShareItem *linkCopy =
    [[SJFilmEditingResultShareItem alloc] initWithTitle:kSJFilmEditingResultShareItemCopyLinkTitle image:[UIImage imageNamed:@"result_link_copy"]];
    
    _resultShareItems = @[save, qq, qzone, wechat, wechatTimeLine, weibo, linkCopy];
    return _resultShareItems;
}

#pragma mark -
- (void)_userClickedShareItem:(SJFilmEditingResultShareItem *)item result:(id<SJVideoPlayerFilmEditingResult>) result {
    if ( item.title == kSJFilmEditingResultShareItemAlbumTitle ) {
        [self _saveResult:result];
    }
    else {
        __weak typeof(self) _self = self;
        // test test test
        [self.player showTitle:item.title duration:1 hiddenExeBlock:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
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
}

- (void)_saveResult:(id<SJVideoPlayerFilmEditingResult>)result {
    switch ( result.operation ) {
        case SJVideoPlayerFilmEditingOperation_Screenshot: {
            UIImageWriteToSavedPhotosAlbum(result.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
            break;
        case SJVideoPlayerFilmEditingOperation_GIF: {
            [self writeGifImgToAlbum:result];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            UISaveVideoAtPathToSavedPhotosAlbum(result.fileURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
        }
            break;
    }
}
- (void)writeGifImgToAlbum:(id<SJVideoPlayerFilmEditingResult>)result {
    if ( @available(iOS 9.0, *) ) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:result.fileURL];
        } completionHandler:^(BOOL success, NSError *error) {
            if (error) {
                [self.player showTitle:@"保存失败" duration:2];
            }else{
                [self.player showTitle:@"保持成功" duration:2];
            }
        }];
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        NSDictionary *metadata = @{@"UTI":(__bridge NSString *)kUTTypeGIF};
        [library writeImageDataToSavedPhotosAlbum:result.data metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                [self.player showTitle:@"保存失败" duration:2];
            }
            else{
                [self.player showTitle:@"保持成功" duration:2];
            }
        }];
#pragma clang diagnostic pop
    }
}
/// Save video to album SEL. 保存好的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( error ) {
        [self.player showTitle:@"保存失败" duration:2];
    }
    else {
        [self.player showTitle:@"保持成功" duration:2];
    }
}

/// Save image to album SEL. 保存好的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( error ) {
        [self.player showTitle:@"保存失败" duration:2];
    }
    else {
        [self.player showTitle:@"保持成功" duration:2];
    }
}
@end
NS_ASSUME_NONNULL_END
