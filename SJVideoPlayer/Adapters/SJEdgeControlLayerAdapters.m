//
//  SJEdgeControlLayerAdapters.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/24.
//  Copyright © 2018 畅三江. All rights reserved.
//

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#if __has_include(<SJAttributesFactory/SJAttributeWorker.h>)
#import <SJAttributesFactory/SJAttributeWorker.h>
#else
#import "SJAttributeWorker.h"
#endif

#import "SJVideoPlayerControlMaskView.h"
#import "SJEdgeControlLayerAdapters.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJEdgeControlLayerAdapters {
    id _notifyToken;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _observeOrientationChangeOfStatusBarNotify];
    self.autoAdjustTopSpacing = YES;
    return self;
}

- (void)dealloc {
    if ( _notifyToken ) [NSNotificationCenter.defaultCenter removeObserver:_notifyToken];
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
    if ( !_autoAdjustTopSpacing ) return;
    if ( !_topAdapter ) return;
    UIInterfaceOrientation orientation = notify?[notify.userInfo[UIApplicationStatusBarOrientationUserInfoKey] integerValue]: UIApplication.sharedApplication.statusBarOrientation;
    switch ( orientation ) {
        case UIInterfaceOrientationUnknown: break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown: {
            [_topAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.offset(49);
                make.bottom.offset(0);
                if (@available(iOS 11.0, *)) {
                    make.top.equalTo(self.topContainerView.mas_safeAreaLayoutGuideTop).offset(8);
                    make.left.equalTo(self.topContainerView.mas_safeAreaLayoutGuideLeft);
                    make.right.equalTo(self.topContainerView.mas_safeAreaLayoutGuideRight);
                } else {
                    make.top.offset(self.isFitOnScreen?20:8);
                    make.left.right.offset(0);
                }
            }];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            [_topAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(20); // 统一 20
                make.height.offset(49);
                make.bottom.offset(0);
                if (@available(iOS 11.0, *)) {
                    make.left.equalTo(self.topContainerView.mas_safeAreaLayoutGuideLeft);
                    make.right.equalTo(self.topContainerView.mas_safeAreaLayoutGuideRight);
                } else {
                    make.left.right.offset(0);
                }
            }];
        }
            break;
    }
}

- (void)setIsFitOnScreen:(BOOL)isFitOnScreen {
    if ( isFitOnScreen == _isFitOnScreen ) return;
    _isFitOnScreen = isFitOnScreen;
    [self _updateTopLayout:nil];
}

- (SJVideoPlayerControlMaskView *)topContainerView {
    if ( _topContainerView ) return _topContainerView;
    _topContainerView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_top];
    [self addSubview:_topContainerView];
    [_topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
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
        make.top.left.bottom.offset(0);
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
        make.left.bottom.right.offset(0);
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
        make.top.right.bottom.offset(0);
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
    [self.topContainerView addSubview:_topAdapter.view];
    [self _updateTopLayout:nil];
    return _topAdapter;
}

- (SJEdgeControlLayerItemAdapter *)leftAdapter {
    if ( _leftAdapter ) return _leftAdapter;
    _leftAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithLayoutType:SJAdapterItemsLayoutTypeVerticalLayout];
    [self.leftContainerView addSubview:_leftAdapter.view];
    [_leftAdapter.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(49);
        make.top.bottom.right.offset(0);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.leftContainerView.mas_safeAreaLayoutGuideLeft);
        } else {
            make.left.offset(0);
        }
    }];
    return _leftAdapter;
}

- (SJEdgeControlLayerItemAdapter *)bottomAdapter {
    if ( _bottomAdapter ) return _bottomAdapter;
    _bottomAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithLayoutType:SJAdapterItemsLayoutTypeHorizontalLayout];
    [self.bottomContainerView addSubview:_bottomAdapter.view];
    [_bottomAdapter.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideRight);
            make.bottom.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideBottom);
        } else {
            make.left.bottom.right.offset(0);
        }
        
        make.height.offset(49);
        make.top.offset(0);
    }];
    return _bottomAdapter;
}

- (SJEdgeControlLayerItemAdapter *)rightAdapter {
    if ( _rightAdapter ) return _rightAdapter;
    _rightAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithLayoutType:SJAdapterItemsLayoutTypeVerticalLayout];
    [self.rightContainerView addSubview:_rightAdapter.view];
    [_rightAdapter.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(49);
        make.top.left.bottom.offset(0);
        if (@available(iOS 11.0, *)) {
            make.right.equalTo(self.rightContainerView.mas_safeAreaLayoutGuideRight);
        } else {
            make.right.offset(0);
        }
    }];
    return _rightAdapter;
}

- (SJEdgeControlLayerItemAdapter *)centerAdapter {
    if ( _centerAdapter ) return _centerAdapter;
    _centerAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithLayoutType:SJAdapterItemsLayoutTypeFrameLayout];
    [self.centerContainerView addSubview:_centerAdapter.view];
    __weak typeof(self) _self = self;
    _centerAdapter.maxSizeDidUpdateOfFrameLayoutExeBlock = ^(CGSize size) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.centerAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
            make.size.mas_equalTo(size);
        }];
    };
    return _centerAdapter;
}
@end
NS_ASSUME_NONNULL_END
