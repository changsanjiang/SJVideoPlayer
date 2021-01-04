//
//  SJNotReachableControlLayer.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/15.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerDefines.h"

#pragma mark - 无网状态下显示的控制层

@protocol SJNotReachableControlLayerDelegate;
@class SJButtonContainerView;

NS_ASSUME_NONNULL_BEGIN
extern SJEdgeControlButtonItemTag const SJNotReachableControlLayerTopItem_Back;


@interface SJNotReachableControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>
@property (nonatomic, weak, nullable) id<SJNotReachableControlLayerDelegate> delegate;
@property (nonatomic, strong, readonly) UILabel *promptLabel;
@property (nonatomic, strong, readonly) SJButtonContainerView *reloadView;
@property (nonatomic) BOOL hiddenBackButtonWhenOrientationIsPortrait;
@end


@interface SJButtonContainerView : UIView
- (instancetype)initWithEdgeInsets:(UIEdgeInsets)insets;
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic, getter=isRoundedRect) BOOL roundedRect;
@property (nonatomic, strong, readonly) UIButton *button;
@end


@protocol SJNotReachableControlLayerDelegate <NSObject>
- (void)backItemWasTappedForControlLayer:(id<SJControlLayer>)controlLayer;
- (void)reloadItemWasTappedForControlLayer:(id<SJControlLayer>)controlLayer;
@end
NS_ASSUME_NONNULL_END
