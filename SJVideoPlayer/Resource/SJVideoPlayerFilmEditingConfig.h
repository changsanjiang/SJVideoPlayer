//
//  SJVideoPlayerFilmEditingConfig.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SJVideoPlayerFilmEditingResult, SJVideoPlayerFilmEditingResultUpload;

@class SJVideoPlayer, SJFilmEditingResultShareItem;

@interface SJVideoPlayerFilmEditingConfig : NSObject

/**
 result View showed share items.
 */
@property (nonatomic, strong, nullable) NSArray<SJFilmEditingResultShareItem *> *resultShareItems;

/**
 clicked share item call it.
 */
@property (nonatomic, copy, nullable) void(^clickedResultShareItemExeBlock)(SJVideoPlayer *player, SJFilmEditingResultShareItem * item, id<SJVideoPlayerFilmEditingResult> result);

/**
 Exported video or whether the image needs to be uploaded.
 
 导出来的视频或图片是否需要上传
 default is YES
 */
@property (nonatomic) BOOL resultNeedUpload;
@property (nonatomic, weak, nullable) id<SJVideoPlayerFilmEditingResultUpload> resultUploader; // 谁去上传

@property (nonatomic) BOOL disableScreenshot;   // default is NO
@property (nonatomic) BOOL disableRecord;       // default is NO
@property (nonatomic) BOOL disableGIF;          // default is NO

@end
