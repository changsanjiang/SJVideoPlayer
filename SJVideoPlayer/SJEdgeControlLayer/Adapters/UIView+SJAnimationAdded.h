//
//  UIView+SJAnimationAdded.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/23.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 视图
typedef enum : NSUInteger {
    SJViewDisappearAnimation_None,
    SJViewDisappearAnimation_Top,
    SJViewDisappearAnimation_Left,
    SJViewDisappearAnimation_Bottom,
    SJViewDisappearAnimation_Right,
    SJViewDisappearAnimation_HorizontalScaling, // 水平缩放
    SJViewDisappearAnimation_VerticalScaling,   // 垂直缩放
} SJViewDisappearAnimation;

NS_ASSUME_NONNULL_BEGIN
@interface UIView (SJAnimationAdded)
@property (nonatomic) SJViewDisappearAnimation sjv_disappearDirection;
@property (nonatomic, readonly) BOOL sjv_disappeared;
@property (nonatomic) BOOL sjv_doNotSetAlpha; // 是否不设置透明度, 默认动画会设置透明度

- (void)sjv_disapear; // Animatable. 可动画的
- (void)sjv_appear; // Animatable. 可动画的

@end
NS_ASSUME_NONNULL_END
