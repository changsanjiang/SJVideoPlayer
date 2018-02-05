//
//  SJPlayerGestureControl.h
//  SJPlayerGestureControl
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJPlayerGestureType) {
    SJPlayerGestureType_Unknown,
    SJPlayerGestureType_SingleTap,
    SJPlayerGestureType_DoubleTap,
    SJPlayerGestureType_Pan,
    SJPlayerGestureType_Pinch
};

typedef NS_ENUM(NSUInteger, SJPanDirection) {
    SJPanDirection_Unknown,
    SJPanDirection_V,
    SJPanDirection_H,
};

typedef NS_ENUM(NSUInteger, SJPanLocation) {
    SJPanLocation_Unknown,
    SJPanLocation_Left,
    SJPanLocation_Right,
};

typedef NS_ENUM(NSUInteger, SJPanMovingDirection) {
    SJPanMovingDirection_Unkown,
    SJPanMovingDirection_Top,
    SJPanMovingDirection_Left,
    SJPanMovingDirection_Bottom,
    SJPanMovingDirection_Right,
};

@interface SJPlayerGestureControl : NSObject

- (instancetype)initWithTargetView:(__weak UIView *)view;

@property (nonatomic, copy, readwrite, nullable) BOOL(^triggerCondition)(SJPlayerGestureControl *control, SJPlayerGestureType type, UIGestureRecognizer *gesture);

@property (nonatomic, copy, readwrite, nullable) void(^singleTapped)(SJPlayerGestureControl *control);
@property (nonatomic, copy, readwrite, nullable) void(^doubleTapped)(SJPlayerGestureControl *control);
@property (nonatomic, copy, readwrite, nullable) void(^beganPan)(SJPlayerGestureControl *control, SJPanDirection direction, SJPanLocation location);
@property (nonatomic, copy, readwrite, nullable) void(^changedPan)(SJPlayerGestureControl *control, SJPanDirection direction, SJPanLocation location, CGPoint translate);
@property (nonatomic, copy, readwrite, nullable) void(^endedPan)(SJPlayerGestureControl *control, SJPanDirection direction, SJPanLocation location);
@property (nonatomic, copy, readwrite, nullable) void(^pinched)(SJPlayerGestureControl *control, float scale);

@property (nonatomic, assign, readonly) SJPanDirection panDirection;
@property (nonatomic, assign, readonly) SJPanLocation panLocation;
@property (nonatomic, assign, readonly) SJPanMovingDirection panMovingDirection;
@end

NS_ASSUME_NONNULL_END
