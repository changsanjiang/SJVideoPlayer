//
//  SJLoadFailedControlLayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/27.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#if __has_include(<SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>)
#import <SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>
#else
#import "SJVideoPlayerControlLayerProtocol.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJLoadFailedControlLayer : SJEdgeControlLayerAdapters<SJVideoPlayerControlLayerDelegate, SJVideoPlayerControlLayerDataSource>

@end
NS_ASSUME_NONNULL_END
