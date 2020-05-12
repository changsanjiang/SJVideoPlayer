//
//  SJBaseVideoPlayer+TestLog.m
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/9/11.
//

#ifdef SJDEBUG
#import "SJBaseVideoPlayer+TestLog.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJBaseVideoPlayer (TestLog)
- (void)showLog_TimeControlStatus {
    SJPlaybackTimeControlStatus status = self.timeControlStatus;
    NSString *statusStr = nil;
    switch ( status ) {
        case SJPlaybackTimeControlStatusPaused: {
            statusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.TimeControlStatus.Paused\n", self];
        }
            break;
        case SJPlaybackTimeControlStatusWaitingToPlay: {
            NSString *reasonStr = nil;
            if      ( self.reasonForWaitingToPlay == SJWaitingToMinimizeStallsReason ) {
                reasonStr = @"WaitingToMinimizeStallsReason";
            }
            else if ( self.reasonForWaitingToPlay == SJWaitingWhileEvaluatingBufferingRateReason ) {
                reasonStr = @"WaitingWhileEvaluatingBufferingRateReason";
            }
            else if ( self.reasonForWaitingToPlay == SJWaitingWithNoAssetToPlayReason ) {
                reasonStr = @"WaitingWithNoAssetToPlayReason";
            }
            statusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.TimeControlStatus.WaitingToPlay(Reason: %@)\n", self, reasonStr];
        }
            break;
        case SJPlaybackTimeControlStatusPlaying: {
            statusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.TimeControlStatus.Playing\n", self];
        }
            break;
    }
    
    printf("%s", statusStr.UTF8String);
}
- (void)showLog_AssetStatus {
    SJAssetStatus status = self.assetStatus;
    NSString *statusStr = nil;
    switch ( status ) {
        case SJAssetStatusUnknown:
            statusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.assetStatus.Unknown\n", self];
            break;
        case SJAssetStatusPreparing:
            statusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.assetStatus.Preparing\n", self];
            break;
        case SJAssetStatusReadyToPlay:
            statusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.assetStatus.ReadyToPlay\n", self];
            break;
        case SJAssetStatusFailed:
            statusStr = [NSString stringWithFormat:@"SJBaseVideoPlayer<%p>.assetStatus.Failed\n", self];
            break;
    }
    
    printf("%s", statusStr.UTF8String);
}
@end
NS_ASSUME_NONNULL_END
#endif
