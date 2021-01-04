//
//  SJSpeedupPlaybackPopupViewDefines.h
//  Pods
//
//  Created by BlueDancer on 2020/2/21.
//

#ifndef SJSpeedupPlaybackPopupViewDefines_h
#define SJSpeedupPlaybackPopupViewDefines_h

#import <UIKit/UIKit.h>
#import <SJBaseVideoPlayer/SJPlayerGestureControlDefines.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJSpeedupPlaybackPopupView <NSObject>
@property (nonatomic) CGFloat rate;

@property (nonatomic, readonly, getter=isAnimating) BOOL animating;
- (void)show;
- (void)hidden;

@optional
- (void)layoutInRect:(CGRect)rect gestureState:(SJLongPressGestureRecognizerState)state playbackRate:(CGFloat)rate;
@end
NS_ASSUME_NONNULL_END
#endif /* SJSpeedupPlaybackPopupViewDefines_h */
