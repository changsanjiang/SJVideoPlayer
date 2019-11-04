//
//  SJEdgeControlLayerAdapters.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/24.
//  Copyright © 2018 畅三江. All rights reserved.
//

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#if __has_include(<SJUIKit/SJAttributesFactory.h>)
#import <SJUIKit/SJAttributesFactory.h>
#else
#import "SJAttributesFactory.h"
#endif

#import "SJVideoPlayerControlMaskView.h"
#import "SJEdgeControlLayerAdapters.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJEdgeControlLayerAdapters ()
@property (nonatomic, readonly) BOOL isFitOnScreen;
@end

@implementation SJEdgeControlLayerAdapters {
    id _notifyToken;
    CGRect _beforeBounds;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
    CGFloat max = MAX(screenW, screenH);
    CGFloat min = MIN(screenW, screenH);
    BOOL is_iPhoneX = (((float)((int)(min / max * 100))) / 100) ==
                      (((float)((int)(1125.0 / 2436 * 100))) / 100);
    _screen = (struct SJ_Screen){max, min, is_iPhoneX};

    _topHeight = _leftWidth = _bottomHeight = _rightWidth = 49;
    _topMargin = 4;
    
    [self _observeOrientationChangeOfStatusBarNotify];
    self.autoAdjustTopSpacing = YES;
    self.autoAdjustLayoutWhenDeviceIsiPhoneX = YES;
    return self;
}

- (void)dealloc {
    if ( _notifyToken ) [NSNotificationCenter.defaultCenter removeObserver:_notifyToken];
}

- (BOOL)isFitOnScreen {
    return (_screen.min == self.bounds.size.width) && (_screen.max == self.bounds.size.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ( _screen.is_iPhoneX && _autoAdjustLayoutWhenDeviceIsiPhoneX ) {
        if ( !CGRectEqualToRect(_beforeBounds, self.bounds) ) {
            CGFloat viewW = self.bounds.size.width;
            CGFloat viewH = self.bounds.size.height;
            
            BOOL isFullscreen = (viewW == _screen.max) && (viewH == _screen.min);
            
            if ( isFullscreen ) {
                [self _updateLayout_isFullScreen_iPhone_X];
            }
            else {
                [self _updateLayout_isNormal_iPhone_X];
            }
        }
    }
    else {
        if ( !CGRectEqualToRect(_beforeBounds, self.bounds) ) {
            [self _updateTopLayout:nil];
        }
    }
    _beforeBounds = self.bounds;
    _topAdapter.frameLayoutItemFillSize = _beforeBounds.size;
    _leftAdapter.frameLayoutItemFillSize = _beforeBounds.size;
    _bottomAdapter.frameLayoutItemFillSize = _beforeBounds.size;
    _rightAdapter.frameLayoutItemFillSize = _beforeBounds.size;
    _centerAdapter.frameLayoutItemFillSize = _beforeBounds.size;
}

- (void)_updateLayout_isNormal_iPhone_X {
    if (@available(iOS 11.0, *)) {
        [_topAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topContainerView.mas_safeAreaLayoutGuideTop).offset(self.topMargin);
            make.left.equalTo(self.topContainerView.mas_safeAreaLayoutGuideLeft);
            make.bottom.offset(0);
            make.right.equalTo(self.topContainerView.mas_safeAreaLayoutGuideRight);
            
            make.height.offset(self.topHeight);
        }];
        
        [_leftAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.offset(0);
            make.left.equalTo(self.leftContainerView.mas_safeAreaLayoutGuideLeft).offset(self.leftMargin);
            
            make.width.offset(self.leftWidth);
        }];
        
        [_bottomAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0);
            make.left.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideRight);
            make.bottom.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideBottom).offset(-self.bottomMargin);
            
            make.height.offset(self.bottomHeight);
        }];
        
        [_rightAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.offset(0);
            make.right.equalTo(self.rightContainerView.mas_safeAreaLayoutGuideRight).offset(-self.rightMargin);
            
            make.width.offset(self.rightWidth);
        }];
    }
}

- (void)_updateLayout_isFullScreen_iPhone_X {
    if (@available(iOS 11.0, *)) {
        CGFloat safeWidth = ceil(_screen.min * 16 / 9.0);
        CGFloat safeLeftMargin = ceil((_screen.max - safeWidth) * 0.5);
        
        [_topAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(self.autoAdjustTopSpacing?20:self.topMargin);
            make.left.mas_greaterThanOrEqualTo(0).priorityLow();
            make.bottom.offset(0);
            make.right.mas_lessThanOrEqualTo(0).priorityLow();
            make.centerX.offset(0);
            
            make.width.offset(safeWidth);
            make.height.offset(self.topHeight);
        }];
        
        [_leftAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0);
            make.left.offset(safeLeftMargin + self.leftMargin);
            make.bottom.offset(0);
            make.right.offset(0);
            
            make.width.offset(self.leftWidth);
        }];
        
        [_bottomAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0);
            make.left.mas_greaterThanOrEqualTo(0).priorityLow();
            make.bottom.offset(-(self.bottomMargin + 20));
            make.right.mas_lessThanOrEqualTo(0).priorityLow();
            make.centerX.offset(0);
            
            make.width.offset(safeWidth);
            make.height.offset(self.bottomHeight);
        }];
        
        [_rightAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.offset(0);
            make.right.offset(-(safeLeftMargin + self.rightMargin));
            
            make.width.offset(self.rightWidth);
        }];
    }
}

- (void)_observeOrientationChangeOfStatusBarNotify {
    __weak typeof(self) _self = self;
    _notifyToken = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationWillChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateTopLayout:note];
    }];
}

- (void)_updateTopLayout:(nullable NSNotification *)notify {
    if ( !_topAdapter ) return;
    if ( _screen.is_iPhoneX ) return;
    [UIView animateWithDuration:0 animations:^{} completion:^(BOOL finished) {
        UIInterfaceOrientation orientation = notify?[notify.userInfo[UIApplicationStatusBarOrientationUserInfoKey] integerValue]: UIApplication.sharedApplication.statusBarOrientation;
        switch ( orientation ) {
            case UIInterfaceOrientationUnknown: break;
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown: {
                [self.topAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    if (@available(iOS 11.0, *)) {
                        make.top.equalTo(self.topContainerView.mas_safeAreaLayoutGuideTop).offset(self.topMargin);
                        make.left.equalTo(self.topContainerView.mas_safeAreaLayoutGuideLeft);
                        make.right.equalTo(self.topContainerView.mas_safeAreaLayoutGuideRight);
                    } else {
                        make.top.offset(self.topMargin + ((self.isFitOnScreen && self.autoAdjustTopSpacing)?20:0));
                        make.left.right.offset(0);
                    }
                    make.bottom.offset(0);
                    make.height.offset(self.topHeight);
                }];
            }
                break;
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight: {
                [self.topAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.offset(self.topMargin + (self.autoAdjustTopSpacing?20:0)); // 统一 20
                    if (@available(iOS 11.0, *)) {
                        make.left.equalTo(self.topContainerView.mas_safeAreaLayoutGuideLeft);
                        make.right.equalTo(self.topContainerView.mas_safeAreaLayoutGuideRight);
                    } else {
                        make.left.right.offset(0);
                    }
                    make.bottom.offset(0);
                    make.height.offset(self.topHeight);
                }];
            }
                break;
        }
        
        [UIView animateWithDuration:0.4 animations:^{
            [self layoutIfNeeded];
        }];
    }];
}

- (SJVideoPlayerControlMaskView *)topContainerView {
    if ( _topContainerView ) return _topContainerView;
    _topContainerView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_top];
    [self addSubview:_topContainerView];
    [_topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(0);
        make.right.offset(0);
    }];
    
#ifdef DEBUG
    if ( self.showBackgroundColor ) {
        _topContainerView.backgroundColor =  [UIColor colorWithRed:arc4random() % 256 / 255.0
                                                             green:arc4random() % 256 / 255.0
                                                              blue:arc4random() % 256 / 255.0
                                                             alpha:1];
    }
#endif
    return _topContainerView;
}

- (UIView *)leftContainerView {
    if ( _leftContainerView ) return _leftContainerView;
    _leftContainerView = [UIView new];
    [self insertSubview:_leftContainerView atIndex:0];
    [_leftContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(0);
        make.bottom.offset(0);
    }];
    
#ifdef DEBUG
    if ( self.showBackgroundColor ) {
        _leftContainerView.backgroundColor =  [UIColor colorWithRed:arc4random() % 256 / 255.0
                                                              green:arc4random() % 256 / 255.0
                                                               blue:arc4random() % 256 / 255.0
                                                              alpha:1];
    }
#endif
    return _leftContainerView;
}

- (SJVideoPlayerControlMaskView *)bottomContainerView {
    if ( _bottomContainerView ) return _bottomContainerView;
    _bottomContainerView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_bottom];
    [self addSubview:_bottomContainerView];
    [_bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.bottom.right.offset(0);
    }];
    
#ifdef DEBUG
    if ( self.showBackgroundColor ) {
        _bottomContainerView.backgroundColor =  [UIColor colorWithRed:arc4random() % 256 / 255.0
                                                                green:arc4random() % 256 / 255.0
                                                                 blue:arc4random() % 256 / 255.0
                                                                alpha:1];
    }
#endif
    return _bottomContainerView;
}

- (UIView *)rightContainerView {
    if ( _rightContainerView ) return _rightContainerView;
    _rightContainerView = [UIView new];
    [self insertSubview:_rightContainerView atIndex:0];
    [_rightContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.right.bottom.offset(0);
    }];
    
#ifdef DEBUG
    if ( self.showBackgroundColor ) {
        _rightContainerView.backgroundColor =  [UIColor colorWithRed:arc4random() % 256 / 255.0
                                                               green:arc4random() % 256 / 255.0
                                                                blue:arc4random() % 256 / 255.0
                                                               alpha:1];
    }
#endif
    return _rightContainerView;
}



- (UIView *)centerContainerView {
    if ( _centerContainerView ) return _centerContainerView;
    _centerContainerView = [UIView new];
    [self addSubview:_centerContainerView];
    [_centerContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
#ifdef DEBUG
    if ( self.showBackgroundColor ) {
        _centerContainerView.backgroundColor =  [UIColor colorWithRed:arc4random() % 256 / 255.0
                                                                green:arc4random() % 256 / 255.0
                                                                 blue:arc4random() % 256 / 255.0
                                                                alpha:1];
    }
#endif
    return _centerContainerView;
}

- (SJEdgeControlLayerItemAdapter *)topAdapter {
    if ( _topAdapter ) return _topAdapter;
    _topAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithLayoutType:SJAdapterItemsLayoutTypeHorizontalLayout];
    _topAdapter.frameLayoutItemFillSize = self.bounds.size;
    [self.topContainerView addSubview:_topAdapter.view];
    [self _updateTopLayout:nil];
    return _topAdapter;
}

- (SJEdgeControlLayerItemAdapter *)leftAdapter {
    if ( _leftAdapter ) return _leftAdapter;
    _leftAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithLayoutType:SJAdapterItemsLayoutTypeVerticalLayout];
    _leftAdapter.frameLayoutItemFillSize = self.bounds.size;
    [self.leftContainerView addSubview:_leftAdapter.view];
    [_leftAdapter.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.offset(0);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.leftContainerView.mas_safeAreaLayoutGuideLeft).offset(self.leftMargin);
        } else {
            make.left.offset(self.leftMargin);
        }
        make.width.offset(self.leftWidth);
    }];
    return _leftAdapter;
}

- (SJEdgeControlLayerItemAdapter *)bottomAdapter {
    if ( _bottomAdapter ) return _bottomAdapter;
    _bottomAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithLayoutType:SJAdapterItemsLayoutTypeHorizontalLayout];
    _bottomAdapter.frameLayoutItemFillSize = self.bounds.size;
    [self.bottomContainerView addSubview:_bottomAdapter.view];
    [_bottomAdapter.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideRight);
            make.bottom.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideBottom).offset(-self.bottomMargin);
        } else {
            make.left.right.offset(0);
            make.bottom.offset(-self.bottomMargin);
        }
        
        make.height.offset(self.bottomHeight);
    }];
    return _bottomAdapter;
}

- (SJEdgeControlLayerItemAdapter *)rightAdapter {
    if ( _rightAdapter ) return _rightAdapter;
    _rightAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithLayoutType:SJAdapterItemsLayoutTypeVerticalLayout];
    _rightAdapter.frameLayoutItemFillSize = self.bounds.size;
    [self.rightContainerView addSubview:_rightAdapter.view];
    [_rightAdapter.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.offset(0);
        if (@available(iOS 11.0, *)) {
            make.right.equalTo(self.rightContainerView.mas_safeAreaLayoutGuideRight).offset(-self.rightMargin);
        } else {
            make.right.offset(-self.rightMargin);
        }
        make.width.offset(self.rightWidth);
    }];
    return _rightAdapter;
}

- (SJEdgeControlLayerItemAdapter *)centerAdapter {
    if ( _centerAdapter ) return _centerAdapter;
    _centerAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithLayoutType:SJAdapterItemsLayoutTypeFrameLayout];
    _centerAdapter.frameLayoutItemFillSize = self.bounds.size;
    [self.centerContainerView addSubview:_centerAdapter.view];
    __weak typeof(self) _self = self;
    _centerAdapter.frameLayoutContentSizeDidChangeExeBlock = ^(CGSize size) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.centerAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
            make.size.mas_equalTo(size);
        }]; 
    };
    return _centerAdapter;
}

#pragma mark -

- (void)setTopHeight:(CGFloat)topHeight {
    _topHeight = topHeight;
    [_topAdapter.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(topHeight);
    }];
}

- (void)setLeftWidth:(CGFloat)leftWidth {
    _leftWidth = leftWidth;
    [_leftAdapter.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.offset(leftWidth);
    }];
}

- (void)setBottomHeight:(CGFloat)bottomHeight {
    _bottomHeight = bottomHeight;
    [_bottomAdapter.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(bottomHeight);
    }];
}

- (void)setRightWidth:(CGFloat)rightWidth {
    _rightWidth = rightWidth;
    [_rightAdapter.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.offset(rightWidth);
    }];
}

#pragma mark -

- (void)setTopMargin:(CGFloat)topMargin {
    _topMargin = topMargin;
    
    [self _updateTopLayout:nil];
}

- (void)setLeftMargin:(CGFloat)leftMargin {
    _leftMargin = leftMargin;
    
    [_leftAdapter.view mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.leftContainerView.mas_safeAreaLayoutGuideLeft).offset(leftMargin);
        } else {
            make.left.offset(leftMargin);
        }
    }];
}

- (void)setBottomMargin:(CGFloat)bottomMargin {
    _bottomMargin = bottomMargin;
    
    [_bottomAdapter.view mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideBottom).offset(-bottomMargin);
        } else {
            make.bottom.offset(-self.bottomMargin).offset(-bottomMargin);
        }
    }];
}

- (void)setRightMargin:(CGFloat)rightMargin {
    _rightMargin = rightMargin;
    
    [_rightAdapter.view mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.right.equalTo(self.rightContainerView.mas_safeAreaLayoutGuideRight).offset(-rightMargin);
        } else {
            make.right.offset(-rightMargin);
        }
    }];
}
@end
NS_ASSUME_NONNULL_END
