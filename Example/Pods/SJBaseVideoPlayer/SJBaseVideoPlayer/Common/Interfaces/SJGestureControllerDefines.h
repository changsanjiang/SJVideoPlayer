//
//  SJGestureControllerDefines.h
//  Pods
//
//  Created by 畅三江 on 2019/1/3.
//

#ifndef SJGestureControllerProtocol_h
#define SJGestureControllerProtocol_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, SJPlayerGestureType) {
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
};

typedef NS_OPTIONS(NSUInteger, SJPlayerGestureTypeMask) {
    SJPlayerGestureTypeMask_None,
    SJPlayerGestureTypeMask_SingleTap   = 1 << SJPlayerGestureType_SingleTap,
    SJPlayerGestureTypeMask_DoubleTap   = 1 << SJPlayerGestureType_DoubleTap,
    SJPlayerGestureTypeMask_Pan_H       = 0x100, // 水平方向
    SJPlayerGestureTypeMask_Pan_V       = 0x200, // 垂直方向
    SJPlayerGestureTypeMask_Pan         = SJPlayerGestureTypeMask_Pan_H | SJPlayerGestureTypeMask_Pan_V,
    SJPlayerGestureTypeMask_Pinch       = 1 << SJPlayerGestureType_Pinch,
    SJPlayerGestureTypeMask_LongPress   = 1 << SJPlayerGestureType_LongPress,
    
    
    SJPlayerGestureTypeMask_Default = SJPlayerGestureTypeMask_SingleTap | SJPlayerGestureTypeMask_DoubleTap | SJPlayerGestureTypeMask_Pan | SJPlayerGestureTypeMask_Pinch,
    SJPlayerGestureTypeMask_All = SJPlayerGestureTypeMask_Default | SJPlayerGestureTypeMask_LongPress,
};

/// 移动方向
typedef NS_ENUM(NSUInteger, SJPanGestureMovingDirection) {
    SJPanGestureMovingDirection_H,
    SJPanGestureMovingDirection_V,
};
 
/// 移动手势触发时的位置
typedef NS_ENUM(NSUInteger, SJPanGestureTriggeredPosition) {
    SJPanGestureTriggeredPosition_Left,
    SJPanGestureTriggeredPosition_Right,
};

/// 移动手势的状态
typedef NS_ENUM(NSUInteger, SJPanGestureRecognizerState) {
    SJPanGestureRecognizerStateBegan,
    SJPanGestureRecognizerStateChanged,
    SJPanGestureRecognizerStateEnded,
};

/// 长按手势的状态
typedef NS_ENUM(NSUInteger, SJLongPressGestureRecognizerState) {
    SJLongPressGestureRecognizerStateBegan,
    SJLongPressGestureRecognizerStateChanged,
    SJLongPressGestureRecognizerStateEnded,
};

@protocol SJGestureController <NSObject>
@property (nonatomic) SJPlayerGestureTypeMask supportedGestureTypes; ///< default value is .Default
@property (nonatomic, copy, nullable) BOOL(^gestureRecognizerShouldTrigger)(id<SJGestureController> control, SJPlayerGestureType type, CGPoint location);
@property (nonatomic, copy, nullable) void(^singleTapHandler)(id<SJGestureController> control, CGPoint location);
@property (nonatomic, copy, nullable) void(^doubleTapHandler)(id<SJGestureController> control, CGPoint location);
@property (nonatomic, copy, nullable) void(^panHandler)(id<SJGestureController> control, SJPanGestureTriggeredPosition position, SJPanGestureMovingDirection direction, SJPanGestureRecognizerState state, CGPoint translate);
@property (nonatomic, copy, nullable) void(^pinchHandler)(id<SJGestureController> control, CGFloat scale);
@property (nonatomic, copy, nullable) void(^longPressHandler)(id<SJGestureController> control, SJLongPressGestureRecognizerState state);

- (void)cancelGesture:(SJPlayerGestureType)type;
- (UIGestureRecognizerState)stateOfGesture:(SJPlayerGestureType)type;

@property (nonatomic, readonly) SJPanGestureMovingDirection movingDirection;
@property (nonatomic, readonly) SJPanGestureTriggeredPosition triggeredPosition;
@end
NS_ASSUME_NONNULL_END

#endif /* SJGestureControllerProtocol_h */
