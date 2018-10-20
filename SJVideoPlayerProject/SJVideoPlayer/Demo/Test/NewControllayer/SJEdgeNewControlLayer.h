//
//  SJEdgeNewControlLayer.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/20.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>)
#import <SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>
#else
#import "SJVideoPlayerControlLayerProtocol.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJEdgeNewControlLayer : UIView<SJVideoPlayerControlLayerDataSource, SJVideoPlayerControlLayerDelegate>

@end
NS_ASSUME_NONNULL_END
