//
//  SJVideoPlayer+PlaybackRatelevelsAdd.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/3/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJVideoPlayer.h"

NS_ASSUME_NONNULL_BEGIN
extern SJControlLayerIdentifier const SJControlLayer_SetPlaybackRate;

@interface SJVideoPlayer (PlaybackRatelevelsAdd)
@property (nonatomic) BOOL showSetPlaybackRateItem;
@end
NS_ASSUME_NONNULL_END
