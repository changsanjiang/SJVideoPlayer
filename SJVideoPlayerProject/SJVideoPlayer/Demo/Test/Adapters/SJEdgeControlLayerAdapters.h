//
//  SJEdgeControlLayerAdapters.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/20.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJEdgeControlLayerItemAdapter.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJEdgeControlLayerAdapters : UIView {
    @protected
    SJEdgeControlLayerItemAdapter *_Nullable _topAdapter;
    SJEdgeControlLayerItemAdapter *_Nullable _leftAdapter;
    SJEdgeControlLayerItemAdapter *_Nullable _bottomAdapter;
    SJEdgeControlLayerItemAdapter *_Nullable _rightAdapter;
    
    __kindof UIView *_Nullable _topContainerView;
    __kindof UIView *_Nullable _bottomContainerView;
    UIView *_Nullable _leftContainerView;
    UIView *_Nullable _rightContainerView;
    UIView *_safeAreaView;
}

@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *topAdapter;    // lazy load
@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *leftAdapter;   // lazy load
@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *bottomAdapter; // lazy load
@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *rightAdapter;  // lazy load

@property (nonatomic, strong, readonly) UIView *topContainerView;
@property (nonatomic, strong, readonly) UIView *bottomContainerView;
@property (nonatomic, strong, readonly) UIView *leftContainerView;
@property (nonatomic, strong, readonly) UIView *rightContainerView;

/// default is NO.
@property (nonatomic) BOOL showBackgroundColor;
@property (nonatomic) BOOL autoMarginForTop; // 是否自动让出状态栏的高度(仅在全屏状态下有效)
@end
NS_ASSUME_NONNULL_END
