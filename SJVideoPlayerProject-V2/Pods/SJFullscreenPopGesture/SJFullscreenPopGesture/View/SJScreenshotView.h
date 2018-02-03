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

- (void)beginTransitionWithSnapshot:(UIView *)snapshot;

- (void)transitioningWithOffset:(CGFloat)offset;

- (void)reset;

- (void)finishedTransition;

@end

NS_ASSUME_NONNULL_END
