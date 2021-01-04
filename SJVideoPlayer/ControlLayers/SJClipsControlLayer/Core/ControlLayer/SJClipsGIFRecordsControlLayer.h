//
//  SJClipsGIFRecordsControlLayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerDefines.h"
#import "SJVideoPlayerClipsDefines.h"

NS_ASSUME_NONNULL_BEGIN
//SJClipsStatus_Unknown,
//SJClipsStatus_Recording,
//SJClipsStatus_Cancelled,
//SJClipsStatus_Paused,
//SJClipsStatus_Finished,
@interface SJClipsGIFRecordsControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>
@property (nonatomic, readonly) SJClipsStatus status;
@property (nonatomic, copy, nullable) void(^statusDidChangeExeBlock)(SJClipsGIFRecordsControlLayer *control);

@property (nonatomic, readonly) CMTimeRange range;
@end
NS_ASSUME_NONNULL_END
