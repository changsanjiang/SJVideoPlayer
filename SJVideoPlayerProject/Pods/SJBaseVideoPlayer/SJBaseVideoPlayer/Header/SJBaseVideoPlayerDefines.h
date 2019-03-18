//
//  SJBaseVideoPlayerDefines.h
//  Pods
//
//  Created by 畅三江 on 2019/1/5.
//

#ifndef SJBaseVideoPlayerDefines_h
#define SJBaseVideoPlayerDefines_h
#import "SJVideoPlayerPlayStatusDefines.h"

@protocol SJReachability, SJPlayStatusObserver;
@class SJVideoPlayerURLAsset;

@protocol SJBaseVideoPlayer <NSObject>
- (id<SJPlayStatusObserver>)getPlayStatusObserver;
@property (nonatomic, strong, null_resettable) id<SJReachability> reachability;
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *URLAsset;
@property (nonatomic) NSTimeInterval delayToAutoRefreshWhenPlayFailed;
- (void)refresh;
@property (nonatomic, readonly) SJVideoPlayerPlayStatus playStatus;
@property (nonatomic, readonly) SJVideoPlayerPausedReason pausedReason;
@property (nonatomic, readonly) SJVideoPlayerInactivityReason inactivityReason;
@property (nonatomic, strong, readonly, nullable) NSError *error;
@end
#endif /* SJBaseVideoPlayerDefines_h */
