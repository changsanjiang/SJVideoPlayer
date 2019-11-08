//
//  SJFilmEditingInVideoRecordingsControlLayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerDefines.h"
#import "SJFilmEditingStatus.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJFilmEditingInVideoRecordingsControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>
@property (nonatomic, readonly) SJFilmEditingStatus status;
@property (nonatomic, copy, nullable) void(^statusDidChangeExeBlock)(SJFilmEditingInVideoRecordingsControlLayer *control);

@property (nonatomic, readonly) CMTimeRange range;
@end
NS_ASSUME_NONNULL_END
