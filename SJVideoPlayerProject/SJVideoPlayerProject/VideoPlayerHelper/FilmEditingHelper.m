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

NS_ASSUME_NONNULL_BEGIN
static NSString *const kSJFilmEditingResultShareItemWechatTimeLineTitle = @"朋友圈";
static NSString *const kSJFilmEditingResultShareItemCopyLinkTitle = @"复制链接";
static NSString *const kSJFilmEditingResultShareItemAlbumTitle = @"保存本地";
static NSString *const kSJFilmEditingResultShareItemQZoneTitle = @"QQ空间";
static NSString *const kSJFilmEditingResultShareItemWechatTitle = @"微信";
static NSString *const kSJFilmEditingResultShareItemWeiboTitle = @"微博";
static NSString *const kSJFilmEditingResultShareItemQQTitle = @"QQ";

@interface FilmEditingHelper () {
    NSArray<SJFilmEditingResultShareItem *> *_resultShareItems;
    SJVideoPlayerFilmEditingConfig *_filmEditingConfig;
}

@property (nonatomic, strong, readonly) NSArray<SJFilmEditingResultShareItem *> *resultShareItems;
@property (nonatomic, weak, nullable) UIViewController *viewController;
@property (nonatomic, weak, nullable) SJVideoPlayer *player;

@end

@implementation FilmEditingHelper

- (instancetype)initWithViewController:(__weak UIViewController *)viewController {
    self = [super init];
    if ( !self ) return nil;
    _viewController = viewController;
    
    __weak typeof(self) _self = self;
    _filmEditingConfig = [SJVideoPlayerFilmEditingConfig new];
    _filmEditingConfig.resultShareItems = self.resultShareItems;
    _filmEditingConfig.resultNeedUpload = NO;

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
