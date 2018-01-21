//
//  SJScreenshotView.h
//  SJBackGR
//
//  Created by BlueDancer on 2017/9/27.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJScreenshotTransitionMode.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJScreenshotView : UIView

@property (nonatomic) SJScreenshotTransitionMode transitionMode;

@property (nonatomic, strong, readwrite, nullable) UIImage *image;

- (void)beginTransition;

- (void)transitioningWithOffset:(CGFloat)offset;

- (void)reset;

- (void)finishedTransition;

@end

NS_ASSUME_NONNULL_END
