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

- (NSString *)getPlayStatusStr:(SJVideoPlayerPlayStatus)status {
    NSString *playStatusStr = nil;
    switch ( status ) {
        case SJVideoPlayerPlayStatusUnknown:
            playStatusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Unknown\n", self];
            break;
        case SJVideoPlayerPlayStatusPrepare:
            playStatusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Prepare\n", self];
            break;
        case SJVideoPlayerPlayStatusReadyToPlay:
            playStatusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.ReadyToPlay\n", self];
            break;
        case SJVideoPlayerPlayStatusPlaying:
            playStatusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Playing\n", self];
            break;
        case SJVideoPlayerPlayStatusPaused: {
            switch ( self.pausedReason ) {
                case SJVideoPlayerPausedReasonBuffering:
                    playStatusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Paused(Reason: Buffering)\n", self];
                    break;
                case SJVideoPlayerPausedReasonPause:
                    playStatusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Paused(Reason: Pause)\n", self];
                    break;
                case SJVideoPlayerPausedReasonSeeking:
                    playStatusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Paused(Reason: Seeking)\n", self];
                    break;
            }
        }
            break;
        case SJVideoPlayerPlayStatusInactivity: {
            switch ( self.inactivityReason ) {
                case SJVideoPlayerInactivityReasonPlayEnd :
                    playStatusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Inactivity(Reason: PlayEnd)\n", self];
                    break;
                case SJVideoPlayerInactivityReasonPlayFailed:
                    playStatusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.SJVideoPlayerPlayStatus.Inactivity(Reason: PlayFailed)\n", self];
                    break;
            }
        }
            break;
    }
    return playStatusStr;
}

@end
