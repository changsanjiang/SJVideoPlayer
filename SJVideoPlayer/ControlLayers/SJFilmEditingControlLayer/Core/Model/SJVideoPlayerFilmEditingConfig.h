//
//  SJVideoPlayerFilmEditingConfig.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/4/12.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerFilmEditingDefines.h"
#import "SJFilmEditingResultShareItem.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SJVideoPlayerFilmEditingResult, SJVideoPlayerFilmEditingResultUpload;

@class SJBaseVideoPlayer;

@interface SJVideoPlayerFilmEditingConfig : NSObject

- (void)config:(SJVideoPlayerFilmEditingConfig *)otherConfig;

/**
 If return YES, Start operation [GIF/Export/Screenshot]
 The default is YES if this block is nil.
 
 返回YES, 则开始操作[GIF/Export/Screenshot]
 如果这个block为空, 将默认为YES
 */
@property (nonatomic, copy, nullable) BOOL (^shouldStartWhenUserSelectedAnOperation)(__kindof SJBaseVideoPlayer *videoPlayer, SJVideoPlayerFilmEditingOperation selectedOperation);

/**
 result View showed share items.
 */
@property (nonatomic, strong, nullable) NSArray<SJFilmEditingResultShareItem *> *resultShareItems;

/**
 clicked share item call it.
 */
@property (nonatomic, copy, nullable) void(^clickedResultShareItemExeBlock)(__kindof SJBaseVideoPlayer *player, SJFilmEditingResultShareItem * item, id<SJVideoPlayerFilmEditingResult> result);

/**
 Exported video or whether the image needs to be uploaded.
 
 导出来的视频或图片是否需要上传
 default is NO
 */
@property (nonatomic) BOOL resultNeedUpload;
@property (nonatomic, weak, nullable) id<SJVideoPlayerFilmEditingResultUpload> resultUploader;

@property (nonatomic) BOOL disableScreenshot;   // default is NO
@property (nonatomic) BOOL disableRecord;       // default is NO
@property (nonatomic) BOOL disableGIF;          // default is NO

/// 导出成功后, 保存到相册
@property (nonatomic) BOOL saveResultToAlbumWhenExportSuccess; // default is NO
@end
NS_ASSUME_NONNULL_END
