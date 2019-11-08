//
//  SJNetworkLoadingView.h
//  Pods
//
//  Created by 畅三江 on 2017/12/24.
//  Copyright © 2017年 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJEdgeControlLayerLoadingViewDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJNetworkLoadingView : UIView<SJEdgeControlLayerLoadingViewProtocol>
@property (nonatomic, readonly, getter=isAnimating) BOOL animating;

@property (nonatomic, strong, null_resettable) UIColor *lineColor;
@property (nonatomic, strong, nullable) NSAttributedString *networkSpeedStr;

- (void)start;
- (void)stop;
@end
NS_ASSUME_NONNULL_END
