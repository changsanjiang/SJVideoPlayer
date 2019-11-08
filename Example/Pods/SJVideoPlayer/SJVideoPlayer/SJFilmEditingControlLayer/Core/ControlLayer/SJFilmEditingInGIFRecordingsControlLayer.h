//
//  SJFilmEditingInGIFRecordingsControlLayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerDefines.h"
#import "SJFilmEditingStatus.h"

NS_ASSUME_NONNULL_BEGIN
//SJFilmEditingStatus_Unknown,
//SJFilmEditingStatus_Recording,
//SJFilmEditingStatus_Cancelled,
//SJFilmEditingStatus_Paused,
//SJFilmEditingStatus_Finished,
@interface SJFilmEditingInGIFRecordingsControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>
@property (nonatomic, readonly) SJFilmEditingStatus status;
@property (nonatomic, copy, nullable) void(^statusDidChangeExeBlock)(SJFilmEditingInGIFRecordingsControlLayer *control);

@property (nonatomic, readonly) CMTimeRange range;
@end
NS_ASSUME_NONNULL_END
