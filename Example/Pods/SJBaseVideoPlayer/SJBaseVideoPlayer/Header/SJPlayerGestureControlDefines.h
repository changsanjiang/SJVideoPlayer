//
//  SJPlayerGestureControlDefines.h
//  Pods
//
//  Created by 畅三江 on 2019/1/3.
//

#ifndef SJPlayerGestureControlProtocol_h
#define SJPlayerGestureControlProtocol_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    SJPlayerGestureType_SingleTap,
    SJPlayerGestureType_DoubleTap,
    SJPlayerGestureType_Pan,
    SJPlayerGestureType_Pinch,
} SJPlayerGestureType;

typedef enum : NSUInteger {
    SJPlayerGestureTypeMask_None,
    SJPlayerGestureTypeMask_SingleTap = 1 << 0,
    SJPlayerGestureTypeMask_DoubleTap = 1 << 1,
    SJPlayerGestureTypeMask_Pan_H = 1 << 2, // 水平方向
    SJPlayerGestureTypeMask_Pan_V = 1 << 3, // 垂直方向
    SJPlayerGestureTypeMask_Pinch = 1 << 4,
    SJPlayerGestureTypeMask_Pan = SJPlayerGestureTypeMask_Pan_H | SJPlayerGestureTypeMask_Pan_V,
    SJPlayerGestureTypeMask_All = SJPlayerGestureTypeMask_SingleTap |
                                   SJPlayerGestureTypeMask_DoubleTap |
                                   SJPlayerGestureTypeMask_Pan |
                                   SJPlayerGestureTypeMask_Pinch,
} SJPlayerGestureTypeMask;

typedef enum : NSUInteger {
    SJPanGestureMovingDirection_H,
    SJPanGestureMovingDirection_V,
} SJPanGestureMovingDirection;

typedef enum : NSUInteger {
    SJPanGestureTriggeredPosition_Left,
    SJPanGestureTriggeredPosition_Right,
} SJPanGestureTriggeredPosition;

typedef enum : NSUInteger {
    SJPanGestureRecognizerStateBegan,
    SJPanGestureRecognizerStateChanged,
    SJPanGestureRecognizerStateEnded,
} SJPanGestureRecognizerState;


@protocol SJPlayerGestureControl <NSObject>
@property (nonatomic) SJPlayerGestureTypeMask supportedGestureTypes; ///< default value is .All
@property (nonatomic, copy, nullable) BOOL(^gestureRecognizerShouldTrigger)(id<SJPlayerGestureControl> control, SJPlayerGestureType type, CGPoint location);
@property (nonatomic, copy, nullable) void(^singleTapHandler)(id<SJPlayerGestureControl> control, CGPoint location);
@property (nonatomic, copy, nullable) void(^doubleTapHandler)(id<SJPlayerGestureControl> control, CGPoint location);
@property (nonatomic, copy, nullable) void(^panHandler)(id<SJPlayerGestureControl> control, SJPanGestureTriggeredPosition position, SJPanGestureMovingDirection direction, SJPanGestureRecognizerState state, CGPoint translate);
@property (nonatomic, copy, nullable) void(^pinchHandler)(id<SJPlayerGestureControl> control, CGFloat scale);

- (void)cancelGesture:(SJPlayerGestureType)type;
- (UIGestureRecognizerState)stateOfGesture:(SJPlayerGestureType)type;

@property (nonatomic, readonly) SJPanGestureMovingDirection movingDirection;
@property (nonatomic, readonly) SJPanGestureTriggeredPosition triggeredPosition;
@end
NS_ASSUME_NONNULL_END

#endif /* SJPlayerGestureControlProtocol_h */
