//
//  SJBaseVideoPlayer+PlayStatus.m
//  Masonry
//
//  Created by 畅三江 on 2018/7/3.
//

#import "SJBaseVideoPlayer+PlayStatus.h"

@implementation SJBaseVideoPlayer (PlayStatus)

- (BOOL)playStatus_isUnknown {
    return self.playStatus == SJVideoPlayerPlayStatusUnknown;
}

- (BOOL)playStatus_isPrepare {
    return self.playStatus == SJVideoPlayerPlayStatusPrepare;
}

- (BOOL)playStatus_isReadyToPlay {
    return self.playStatus == SJVideoPlayerPlayStatusReadyToPlay;
}

- (BOOL)playStatus_isPlaying {
    return self.playStatus == SJVideoPlayerPlayStatusPlaying;
}

- (BOOL)playStatus_isPaused {
    return self.playStatus == SJVideoPlayerPlayStatusPaused;
}

- (BOOL)playStatus_isPaused_ReasonBuffering {
    return self.playStatus == SJVideoPlayerPlayStatusPaused && self.pausedReason == SJVideoPlayerPausedReasonBuffering;
}

- (BOOL)playStatus_isPaused_ReasonPause {
    return self.playStatus == SJVideoPlayerPlayStatusPaused && self.pausedReason == SJVideoPlayerPausedReasonPause;
}

- (BOOL)playStatus_isPaused_ReasonSeeking {
    return self.playStatus == SJVideoPlayerPlayStatusPaused && self.pausedReason == SJVideoPlayerPausedReasonSeeking;
}

- (BOOL)playStatus_isInactivity {
    return self.playStatus == SJVideoPlayerPlayStatusInactivity;
}

- (BOOL)playStatus_isInactivity_ReasonPlayEnd {
    return self.playStatus == SJVideoPlayerPlayStatusInactivity && self.inactivityReason == SJVideoPlayerInactivityReasonPlayEnd;
}

- (BOOL)playStatus_isInactivity_ReasonPlayFailed {
    return self.playStatus == SJVideoPlayerPlayStatusInactivity && self.inactivityReason == SJVideoPlayerInactivityReasonPlayFailed;
}

@end
