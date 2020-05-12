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
    /// 单击手势
    SJPlayerGestureType_SingleTap,
    /// 双击手势
    SJPlayerGestureType_DoubleTap,
    /// 移动手势
    SJPlayerGestureType_Pan,
    /// 捏合手势
    SJPlayerGestureType_Pinch,
    /// 长按手势
    SJPlayerGestureType_LongPress,
} SJPlayerGestureType;

typedef enum : NSUInteger {
    SJPlayerGestureTypeMask_None,
    SJPlayerGestureTypeMask_SingleTap   = 1 << 0,
    SJPlayerGestureTypeMask_DoubleTap   = 1 << 1,
    SJPlayerGestureTypeMask_Pan_H       = 1 << 2, // 水平方向
    SJPlayerGestureTypeMask_Pan_V       = 1 << 3, // 垂直方向
    SJPlayerGestureTypeMask_Pinch       = 1 << 4,
    SJPlayerGestureTypeMask_LongPress   = 1 << 5,
    
    SJPlayerGestureTypeMask_Pan = SJPlayerGestureTypeMask_Pan_H | SJPlayerGestureTypeMask_Pan_V,
    SJPlayerGestureTypeMask_Default = SJPlayerGestureTypeMask_SingleTap | SJPlayerGestureTypeMask_DoubleTap | SJPlayerGestureTypeMask_Pan | SJPlayerGestureTypeMask_Pinch,
    SJPlayerGestureTypeMask_All = SJPlayerGestureTypeMask_Default | SJPlayerGestureTypeMask_LongPress,
} SJPlayerGestureTypeMask;

/// 移动方向
typedef enum : NSUInteger {
    SJPanGestureMovingDirection_H,
    SJPanGestureMovingDirection_V,
} SJPanGestureMovingDirection;

/// 移动手势触发时的位置
typedef enum : NSUInteger {
    SJPanGestureTriggeredPosition_Left,
    SJPanGestureTriggeredPosition_Right,
} SJPanGestureTriggeredPosition;

/// 移动手势的状态
typedef enum : NSUInteger {
    SJPanGestureRecognizerStateBegan,
    SJPanGestureRecognizerStateChanged,
    SJPanGestureRecognizerStateEnded,
} SJPanGestureRecognizerState;

/// 长按手势的状态
typedef enum : NSUInteger {
    SJLongPressGestureRecognizerStateBegan,
    SJLongPressGestureRecognizerStateChanged,
    SJLongPressGestureRecognizerStateEnded,
} SJLongPressGestureRecognizerState;

@protocol SJPlayerGestureControl <NSObject>
@property (nonatomic) SJPlayerGestureTypeMask supportedGestureTypes; ///< default value is .Default
@property (nonatomic, copy, nullable) BOOL(^gestureRecognizerShouldTrigger)(id<SJPlayerGestureControl> control, SJPlayerGestureType type, CGPoint location);
@property (nonatomic, copy, nullable) void(^singleTapHandler)(id<SJPlayerGestureControl> control, CGPoint location);
@property (nonatomic, copy, nullable) void(^doubleTapHandler)(id<SJPlayerGestureControl> control, CGPoint location);
@property (nonatomic, copy, nullable) void(^panHandler)(id<SJPlayerGestureControl> control, SJPanGestureTriggeredPosition position, SJPanGestureMovingDirection direction, SJPanGestureRecognizerState state, CGPoint translate);
@property (nonatomic, copy, nullable) void(^pinchHandler)(id<SJPlayerGestureControl> control, CGFloat scale);
@property (nonatomic, copy, nullable) void(^longPressHandler)(id<SJPlayerGestureControl> control, SJLongPressGestureRecognizerState state);

- (void)cancelGesture:(SJPlayerGestureType)type;
- (UIGestureRecognizerState)stateOfGesture:(SJPlayerGestureType)type;

@property (nonatomic, readonly) SJPanGestureMovingDirection movingDirection;
@property (nonatomic, readonly) SJPanGestureTriggeredPosition triggeredPosition;
@end
NS_ASSUME_NONNULL_END

#endif /* SJPlayerGestureControlProtocol_h */
