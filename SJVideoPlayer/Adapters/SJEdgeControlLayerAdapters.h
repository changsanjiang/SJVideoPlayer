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
    SJEdgeControlLayerItemAdapter *_Nullable _centerAdapter;
    
    __kindof UIView *_Nullable _topContainerView;
    __kindof UIView *_Nullable _bottomContainerView;
    UIView *_Nullable _leftContainerView;
    UIView *_Nullable _rightContainerView;
    UIView *_Nullable _centerContainerView;
}

@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *topAdapter;    // lazy load
@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *leftAdapter;   // lazy load
@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *bottomAdapter; // lazy load
@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *rightAdapter;  // lazy load
@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *centerAdapter; // lazy load


@property (nonatomic, strong, readonly) UIView *topContainerView;
@property (nonatomic, strong, readonly) UIView *bottomContainerView;
@property (nonatomic, strong, readonly) UIView *leftContainerView;
@property (nonatomic, strong, readonly) UIView *rightContainerView;
@property (nonatomic, strong, readonly) UIView *centerContainerView;


/// default is YES.
@property (nonatomic) BOOL autoAdjustTopSpacing; // 自动调整顶部间距, 让出状态栏

@property (nonatomic) BOOL isFitOnScreen;

#ifdef DEBUG
@property (nonatomic) BOOL showBackgroundColor;
#endif
@end
NS_ASSUME_NONNULL_END
