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

FOUNDATION_STATIC_INLINE BOOL
_isIPhoneXSeries(void) {
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if ( @available(iOS 13.0, *) ) {
            for ( UIScene *scene in UIApplication.sharedApplication.connectedScenes ) {
                if ( [scene isKindOfClass:UIWindowScene.class] ) {
                    UIWindow *window = [(UIWindowScene *)scene windows].firstObject;
                    if ( window.isKeyWindow ) return window.safeAreaInsets.bottom > 0.0;
                }
            }
        }
        if ( @available(iOS 11.0, *) ) {
            UIWindow *window = [UIApplication sharedApplication].delegate.window;
            return window.safeAreaInsets.bottom > 0.0;
        }
    }
    return NO;
}

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
    _screen = (struct SJ_Screen){max, min, _isIPhoneXSeries()};

    _topHeight = _leftWidth = _bottomHeight = _rightWidth = 49;
    _topMargin = 4;
    
    [self _observeNotifies];
    self.autoAdjustTopSpacing = YES;
    self.autoAdjustLayoutWhenDeviceIsIPhoneXSeries = YES;
    return self;
}

- (void)dealloc {
    if ( _notifyToken ) [NSNotificationCenter.defaultCenter removeObserver:_notifyToken];
}

- (BOOL)isFitOnScreen {
    return ( _screen.min == self.bounds.size.width && _screen.max == self.bounds.size.height ) ||
           ( _screen.min == self.bounds.size.height && _screen.max == self.bounds.size.width );
}

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    /// 自身不消费事件, 由子视图消费;
    return view == self ? nil : view;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self _updateLayout];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self _updateLayout];
}

- (void)_updateLayout {
    _centerAdapter.itemFillSizeForFrameLayout = self.bounds.size;

    CGRect curr = self.bounds;
    if ( _screen.is_iPhoneXSeries && _autoAdjustLayoutWhenDeviceIsIPhoneXSeries ) {
        if ( !CGRectEqualToRect(_beforeBounds, curr) ) {
            CGFloat viewW = curr.size.width;
            CGFloat viewH = curr.size.height;
            
            BOOL isFullscreen = (viewW == _screen.max) && (viewH == _screen.min);
            
            if ( isFullscreen ) {
                [self _updateLayout_isFullscreen_iPhone_X];
            }
            else {
                [self _updateLayout_isNormal_iPhone_X];
            }
        }
    }
    else if ( !CGRectEqualToRect(_beforeBounds, curr) ) {
        [self _updateTopLayout:nil];
    }
    _beforeBounds = curr;
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

- (void)_updateLayout_isFullscreen_iPhone_X {
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

- (void)_observeNotifies {
    __weak typeof(self) _self = self;
    _notifyToken = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationWillChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateTopLayout:note];
    }];
}

- (void)_updateTopLayout:(nullable NSNotification *)notify {
    if ( !_topAdapter ) return;
    if ( _screen.is_iPhoneXSeries && _autoAdjustLayoutWhenDeviceIsIPhoneXSeries ) return;
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
                        make.top.offset(self.topMargin + ((self.isFitOnScreen && self.autoAdjustTopSpacing) ? 20 : 0));
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
                    make.top.offset(self.topMargin + (self.isFitOnScreen && self.autoAdjustTopSpacing ? 20 : 0)); // 统一 20
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
        
//        [UIView animateWithDuration:0.4 animations:^{
//            [self layoutIfNeeded];
//        }];
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

- (SJEdgeControlButtonItemAdapter *)topAdapter {
    if ( _topAdapter ) return _topAdapter;
    _topAdapter = [SJEdgeControlButtonItemAdapter.alloc initWithFrame:CGRectZero layoutType:SJAdapterLayoutTypeHorizontalLayout];
    [self.topContainerView addSubview:_topAdapter.view];
    [self _updateTopLayout:nil];
    return _topAdapter;
}

- (SJEdgeControlButtonItemAdapter *)leftAdapter {
    if ( _leftAdapter ) return _leftAdapter;
    _leftAdapter = [[SJEdgeControlButtonItemAdapter alloc] initWithFrame:CGRectZero layoutType:SJAdapterLayoutTypeVerticalLayout];
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

- (SJEdgeControlButtonItemAdapter *)bottomAdapter {
    if ( _bottomAdapter ) return _bottomAdapter;
    _bottomAdapter = [[SJEdgeControlButtonItemAdapter alloc] initWithFrame:CGRectZero layoutType:SJAdapterLayoutTypeHorizontalLayout];
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

- (SJEdgeControlButtonItemAdapter *)rightAdapter {
    if ( _rightAdapter ) return _rightAdapter;
    _rightAdapter = [[SJEdgeControlButtonItemAdapter alloc] initWithFrame:CGRectZero layoutType:SJAdapterLayoutTypeVerticalLayout];
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

- (SJEdgeControlButtonItemAdapter *)centerAdapter {
    if ( _centerAdapter ) return _centerAdapter;
    _centerAdapter = [[SJEdgeControlButtonItemAdapter alloc] initWithFrame:CGRectZero layoutType:SJAdapterLayoutTypeFrameLayout];
    _centerAdapter.itemFillSizeForFrameLayout = self.bounds.size;
    [self.centerContainerView addSubview:_centerAdapter];
    [_centerAdapter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
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
    
    [self _updateLayout];
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
