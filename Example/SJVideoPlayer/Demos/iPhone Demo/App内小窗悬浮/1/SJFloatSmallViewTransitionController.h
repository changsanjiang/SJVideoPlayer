//
//  SJFloatSmallViewTransitionController.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2021/1/13.
//  Copyright © 2021 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJFloatSmallViewController.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJFloatSmallViewTransitionController : NSObject<SJFloatSmallViewController>
- (void)resume;
@property (nonatomic) BOOL ignoreSafeAreaInsets API_AVAILABLE(ios(11.0));
/// default value is SJFloatViewLayoutPositionBottomRight.
@property (nonatomic) SJFloatViewLayoutPosition layoutPosition;
/// default value is UIEdgeInsetsMake(20, 12, 20, 12).
@property (nonatomic) UIEdgeInsets layoutInsets;
@property (nonatomic) CGSize layoutSize;
@end

@interface UIViewController (SJFloatSmallViewTransitionControllerExtended)
@property (nonatomic, strong, readonly, nullable) SJFloatSmallViewTransitionController *SVTC_floatSmallViewTransitionController;
@end
NS_ASSUME_NONNULL_END
