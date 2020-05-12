//
//  CALayer+SJBaseVideoPlayerExtended.h
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/11/22.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^SJAnimationDidStartHandler)(__kindof CAAnimation *anim);
typedef void(^SJAnimationDidStopHandler)(__kindof CAAnimation *anim, BOOL isFinished);

@interface CALayer (SJBaseVideoPlayerExtended)

- (void)pauseAnimation;

- (void)resumeAnimation;

- (void)addAnimation:(CAAnimation *)anim startHandler:(SJAnimationDidStartHandler)startHandler;
- (void)addAnimation:(CAAnimation *)anim stopHandler:(SJAnimationDidStopHandler)stopHandler;
- (void)addAnimation:(CAAnimation *)anim startHandler:(nullable SJAnimationDidStartHandler)startHandler stopHandler:(nullable SJAnimationDidStopHandler)stopHandler;
@end
NS_ASSUME_NONNULL_END
