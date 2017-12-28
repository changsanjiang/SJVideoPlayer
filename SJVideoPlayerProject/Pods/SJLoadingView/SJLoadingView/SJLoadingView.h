//
//  SJLoadingView.h
//  SJLoadingViewProject
//
//  Created by 畅三江 on 2017/12/24.
//  Copyright © 2017年 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJLoadingType) {
    SJLoadingType_Keep,
    SJLoadingType_FadeOut,
};

@interface SJLoadingView : UIView

/// default is SJLoadingType_Keep.
@property (nonatomic, assign) SJLoadingType animType;

/// default is whiteColor.
@property (nonatomic, strong, null_resettable) UIColor *lineColor;

/// default is 1.
@property (nonatomic, assign) double speed;

/// anima state
@property (nonatomic, assign, readonly, getter=isAnimating) BOOL animating;

/// begin anim
- (void)start;

/// stop anim
- (void)stop;

@end

NS_ASSUME_NONNULL_END
