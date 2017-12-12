//
//  SJPlayerGestureControl.h
//  SJPlayerGestureControl
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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

@interface SJPlayerGestureControl : NSObject

- (instancetype)initWithTargetView:(__weak UIView *)view;

@property (nonatomic, copy, readwrite, nullable) BOOL(^triggerCondition)(SJPlayerGestureControl *control, UIGestureRecognizer *gesture);

@property (nonatomic, copy, readwrite, nullable) void(^singleTapped)(SJPlayerGestureControl *control);
@property (nonatomic, copy, readwrite, nullable) void(^doubleTapped)(SJPlayerGestureControl *control);
@property (nonatomic, copy, readwrite, nullable) void(^beganPan)(SJPlayerGestureControl *control, SJPanDirection direction, SJPanLocation location);
@property (nonatomic, copy, readwrite, nullable) void(^changedPan)(SJPlayerGestureControl *control, SJPanDirection direction, SJPanLocation location, CGPoint translate);
@property (nonatomic, copy, readwrite, nullable) void(^endedPan)(SJPlayerGestureControl *control, SJPanDirection direction, SJPanLocation location);

@end

NS_ASSUME_NONNULL_END
