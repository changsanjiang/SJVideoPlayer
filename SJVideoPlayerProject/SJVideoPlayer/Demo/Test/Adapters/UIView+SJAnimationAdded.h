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
    SJViewDisappearDirection_None,
    SJViewDisappearDirection_Top,
    SJViewDisappearDirection_Left,
    SJViewDisappearDirection_Bottom,
    SJViewDisappearDirection_Right
} SJViewDisappearDirection;

NS_ASSUME_NONNULL_BEGIN
@interface UIView (SJAnimationAdded)
@property (nonatomic, readonly) BOOL sjv_disappeared;
@property (nonatomic) SJViewDisappearDirection sjv_disappearDirection;

- (void)sjv_disapear; // Animatable. 可动画的
- (void)sjv_appear; // Animatable. 可动画的
@end
NS_ASSUME_NONNULL_END
