//
//  SJNotReachableControlLayer.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/1/15.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerDefines.h"

NS_ASSUME_NONNULL_BEGIN
extern SJEdgeControlButtonItemTag const SJNotReachableControlLayerTopItem_Back;

@interface SJButtonContainerView : UIView
- (instancetype)initWithEdgeInsets:(UIEdgeInsets)insets;
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic, getter=isRoundedRect) BOOL roundedRect;
@property (nonatomic, strong, readonly) UIButton *button;
@end

@interface SJNotReachableControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>
@property (nonatomic, strong, readonly) UILabel *promptLabel;
@property (nonatomic, strong, readonly) SJButtonContainerView *reloadView;
@property (nonatomic) BOOL hideBackButtonWhenOrientationIsPortrait;

@property (nonatomic, copy, nullable) void(^clickedBackButtonExeBlock)(__kindof SJNotReachableControlLayer *control);
@property (nonatomic, copy, nullable) void(^clickedReloadButtonExeBlock)(__kindof SJNotReachableControlLayer *control);
@property (nonatomic, copy, nullable) void(^prepareToPlayNewAssetExeBlock)(__kindof SJNotReachableControlLayer *control);
@property (nonatomic, copy, nullable) void(^playStatusDidChangeExeBlock)(__kindof SJNotReachableControlLayer *control);
@end
NS_ASSUME_NONNULL_END
