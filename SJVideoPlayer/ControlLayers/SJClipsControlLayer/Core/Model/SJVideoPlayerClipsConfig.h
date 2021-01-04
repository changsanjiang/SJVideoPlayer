//
//  SJVideoPlayerClipsConfig.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/4/12.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerClipsDefines.h"
#import "SJClipsResultShareItem.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SJVideoPlayerClipsResult, SJVideoPlayerClipsResultUpload;
@class SJBaseVideoPlayer;

@interface SJVideoPlayerClipsConfig : NSObject
/**
 If return YES, Start operation [GIF/Export/Screenshot]
 The default is YES if this block is nil.
 
 返回YES, 则开始操作[GIF/Export/Screenshot]
 如果这个block为空, 将默认为YES
 */
@property (nonatomic, copy, nullable) BOOL (^shouldStart)(__kindof SJBaseVideoPlayer *videoPlayer, SJVideoPlayerClipsOperation selectedOperation);

/**
 result View showed share items.
 */
@property (nonatomic, strong, nullable) NSArray<SJClipsResultShareItem *> *resultShareItems;

/**
 clicked share item call it.
 */
@property (nonatomic, copy, nullable) void(^clickedResultShareItemExeBlock)(__kindof SJBaseVideoPlayer *player, SJClipsResultShareItem * item, id<SJVideoPlayerClipsResult> result);

/**
 Exported video or whether the image needs to be uploaded.
 
 导出来的视频或图片是否需要上传
 default is NO
 */
@property (nonatomic) BOOL resultNeedUpload;
@property (nonatomic, weak, nullable) id<SJVideoPlayerClipsResultUpload> resultUploader;

@property (nonatomic) BOOL disableScreenshot;   // default is NO
@property (nonatomic) BOOL disableRecord;       // default is NO
@property (nonatomic) BOOL disableGIF;          // default is NO

/// 导出成功后, 保存到相册
@property (nonatomic) BOOL saveResultToAlbum; // default is NO

- (void)config:(SJVideoPlayerClipsConfig *)otherConfig;
@end
NS_ASSUME_NONNULL_END
