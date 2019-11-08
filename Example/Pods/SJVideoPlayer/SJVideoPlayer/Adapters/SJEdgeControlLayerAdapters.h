//
//  SJEdgeControlLayerAdapters.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/20.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJEdgeControlLayerItemAdapter.h"
#import "SJVideoPlayerControlMaskView.h"

NS_ASSUME_NONNULL_BEGIN
struct SJ_Screen {
    CGFloat max;
    CGFloat min;
    BOOL is_iPhoneX;
};

@interface SJEdgeControlLayerAdapters : UIView {
    @protected
    SJEdgeControlLayerItemAdapter *_Nullable _topAdapter;
    SJEdgeControlLayerItemAdapter *_Nullable _leftAdapter;
    SJEdgeControlLayerItemAdapter *_Nullable _bottomAdapter;
    SJEdgeControlLayerItemAdapter *_Nullable _rightAdapter;
    SJEdgeControlLayerItemAdapter *_Nullable _centerAdapter;
    
    SJVideoPlayerControlMaskView *_Nullable _topContainerView;
    SJVideoPlayerControlMaskView *_Nullable _bottomContainerView;
    UIView *_Nullable _leftContainerView;
    UIView *_Nullable _rightContainerView;
    UIView *_Nullable _centerContainerView;
    
    struct SJ_Screen _screen;
}

@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *topAdapter;    // lazy load
@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *leftAdapter;   // lazy load
@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *bottomAdapter; // lazy load
@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *rightAdapter;  // lazy load
@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *centerAdapter; // lazy load


@property (nonatomic, strong, readonly) SJVideoPlayerControlMaskView *topContainerView;
@property (nonatomic, strong, readonly) SJVideoPlayerControlMaskView *bottomContainerView;
@property (nonatomic, strong, readonly) UIView *leftContainerView;
@property (nonatomic, strong, readonly) UIView *rightContainerView;
@property (nonatomic, strong, readonly) UIView *centerContainerView;


/// default is YES.
@property (nonatomic) BOOL autoAdjustTopSpacing; // 自动调整顶部间距, 让出状态栏

/// default is Yes.
@property (nonatomic) BOOL autoAdjustLayoutWhenDeviceIsiPhoneX; // 自动调整布局, 如果是iPhone X

#ifdef DEBUG
@property (nonatomic) BOOL showBackgroundColor;
#endif

// - default is 49.
@property (nonatomic) CGFloat topHeight;
@property (nonatomic) CGFloat leftWidth;
@property (nonatomic) CGFloat bottomHeight;
@property (nonatomic) CGFloat rightWidth;

// - default is 4.
@property (nonatomic) CGFloat topMargin;
// - default is 0.
@property (nonatomic) CGFloat leftMargin;
@property (nonatomic) CGFloat bottomMargin;
@property (nonatomic) CGFloat rightMargin;
@end
NS_ASSUME_NONNULL_END
