//
//  SJBaseVideoPlayer+PlayStatus.h
//  Masonry
//
//  Created by 畅三江 on 2018/7/3.
//

#import "SJBaseVideoPlayer.h"

@interface SJBaseVideoPlayer (PlayStatus)

- (NSString *)getPlayStatusStr:(SJVideoPlayerPlayStatus)status;

- (BOOL)playStatus_isUnknown;

- (BOOL)playStatus_isPrepare;

- (BOOL)playStatus_isReadyToPlay;

- (BOOL)playStatus_isPlaying;

- (BOOL)playStatus_isPaused;

- (BOOL)playStatus_isPaused_ReasonBuffering;

- (BOOL)playStatus_isPaused_ReasonPause;

- (BOOL)playStatus_isPaused_ReasonSeeking;

- (BOOL)playStatus_isInactivity;

- (BOOL)playStatus_isInactivity_ReasonPlayEnd;

- (BOOL)playStatus_isInactivity_ReasonPlayFailed;

@end
