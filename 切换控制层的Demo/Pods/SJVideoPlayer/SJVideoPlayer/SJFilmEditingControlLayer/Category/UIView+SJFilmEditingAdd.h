//
//  UIView+SJFilmEditingAdd.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/5.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SJViewDisappearType) {
    SJViewDisappearType_Transform = 1 << 0,
    SJViewDisappearType_Alpha = 1 << 1,
    SJViewDisappearType_All = 1 << 2,
};

NS_ASSUME_NONNULL_BEGIN
@interface UIView (SJFilmEditingAdd)

@property (nonatomic, assign) SJViewDisappearType sj_disappearType;

@property (nonatomic, assign) CGAffineTransform sj_disappearTransform;

@property (nonatomic, assign) BOOL sj_appearState; // appear is `YES`, disappear is `NO`.

@property (nonatomic, copy, nullable) void(^sj_appearExeBlock)(__kindof UIView *view);

@property (nonatomic, copy, nullable) void(^sj_disappearExeBlock)(__kindof UIView *view);

- (void)sj_appear; // Animatable. 可动画的.

- (void)sj_disappear;  // Animatable. 可动画的.

@end
NS_ASSUME_NONNULL_END

