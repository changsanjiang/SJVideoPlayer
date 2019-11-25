//
//  CALayer+SJBaseVideoPlayerExtended.h
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2019/11/22.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^SJAnimationDidStartHandler)(CAAnimation *anim);
typedef void(^SJAnimationDidStopHandler)(CAAnimation *anim, BOOL isFinished);

@interface CALayer (SJBaseVideoPlayerExtended)

- (void)pauseAnimation;

- (void)resumeAnimation;

- (void)addAnimation:(CAAnimation *)anim startHandler:(SJAnimationDidStartHandler)startHandler;
- (void)addAnimation:(CAAnimation *)anim stopHandler:(SJAnimationDidStopHandler)stopHandler;
- (void)addAnimation:(CAAnimation *)anim startHandler:(nullable SJAnimationDidStartHandler)startHandler stopHandler:(nullable SJAnimationDidStopHandler)stopHandler;
@end
NS_ASSUME_NONNULL_END
