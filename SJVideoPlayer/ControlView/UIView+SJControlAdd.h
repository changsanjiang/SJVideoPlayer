//
//  UIView+SJControlAdd.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/5.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SJDisappearType) {
    SJDisappearType_Transform = 1 << 0,
    SJDisappearType_Alpha = 1 << 1,
    SJDisappearType_All = 1 << 2,
};

NS_ASSUME_NONNULL_BEGIN
@interface UIView (SJControlAdd)

@property (nonatomic, assign) SJDisappearType disappearType;

@property (nonatomic, assign) CGAffineTransform disappearTransform;

@property (nonatomic, assign) BOOL appearState; // appear is `YES`, disappear is `NO`.

@property (nonatomic, copy, nullable) void(^appearExeBlock)(__kindof UIView *view);

@property (nonatomic, copy, nullable) void(^disappearExeBlock)(__kindof UIView *view);

- (void)appear; // Animatable. 可动画的.

- (void)disappear;  // Animatable. 可动画的.

@end
NS_ASSUME_NONNULL_END

