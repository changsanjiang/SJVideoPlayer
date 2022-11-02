//
//  SJEdgeControlButtonItemView.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/19.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlButtonItemView.h"

@interface _SJItemCustomViewContainerView : UIView
- (nullable __kindof UIView *)customView;

@end

@implementation _SJItemCustomViewContainerView
- (void)removeCustomView {
    UIView *_Nullable customView = self.customView;
    if ( customView != nil ) {
        [customView removeFromSuperview];
    }
}

- (void)addCustomView:(UIView *)customView {
    if ( self.customView != customView ) {
        [self removeCustomView];
        customView.frame = self.bounds;
        customView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:customView];
    }
}

- (nullable __kindof UIView *)customView {
    return self.subviews.firstObject;
}

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    return view != self ? view : nil;
}
@end

@interface SJEdgeControlButtonItemView ()
@property (nonatomic, strong, nullable) _SJItemCustomViewContainerView *containerView;
@property (nonatomic, strong, nullable) UIImageView *itemImageView;
@property (nonatomic, strong, nullable) UILabel *itemTitleLabel;
@end

@implementation SJEdgeControlButtonItemView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        [self addTarget:self action:@selector(performAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    if ( [super pointInside:point withEvent:event] ) {
        return [self _shouldPerformAction];
    }
    return NO;
}

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    if ( [self pointInside:point withEvent:event] ) {
        if ( _item.customView != nil && _item.actions == nil ) {
            return [_item.customView hitTest:[self convertPoint:point toView:_item.customView] withEvent:event];
        }
        return self;
    }
    return [super hitTest:point withEvent:event];
}

- (void)performAction {
    [_item performActions];
}

- (void)reloadItemIfNeeded {
    self.alpha = _item.alpha;
    
    ///
    /// 优先级
    ///
    /// 1. 自定义视图
    /// 2. 图片视图
    /// 3. 标签视图
    /// 4. 空白
    ///

    _containerView.hidden = YES;
    _itemImageView.hidden = YES;
    _itemTitleLabel.hidden = YES;
    
    if ( _item == nil || _item.isHidden ) {
        // clean
        [_containerView removeCustomView];
        return;
    }
    
    // 1.
    if ( _item.customView != nil ) {
        // show containerView
        if ( _containerView != nil ) {
            _containerView.hidden = NO;
        }
        else {
            _containerView = [_SJItemCustomViewContainerView.alloc initWithFrame:self.bounds];
            _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:_containerView];
        }
        
        // add customView
        [_containerView addCustomView:_item.customView];
    }
    // 2.
    else if ( _item.image != nil ) {
        // show itemImageView
        if ( _itemImageView != nil ) {
            _itemImageView.hidden = NO;
        }
        else {
            _itemImageView = [[UIImageView alloc] initWithFrame:self.bounds];
            _itemImageView.contentMode = UIViewContentModeCenter;
            _itemImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:_itemImageView];
        }
        
        // set image
        if ( _item.image != _itemImageView.image ) {
            _itemImageView.image = _item.image;
        }
    }
    // 3.
    else if ( _item.title != nil ) {
        // show itemTitleLabel
        if ( _itemTitleLabel != nil ) {
            _itemTitleLabel.hidden = NO;
        }
        else {
            _itemTitleLabel = [[UILabel alloc] initWithFrame:self.bounds];
            _itemTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:_itemTitleLabel];
        }
        
        // set title
        if ( _item.title != _itemTitleLabel.attributedText ) {
            _itemTitleLabel.attributedText = _item.title;
        }
        if ( _item.numberOfLines != _itemTitleLabel.numberOfLines ) {
            _itemTitleLabel.numberOfLines = _item.numberOfLines;
        }
    }
    // 4.
    // else
}

#pragma mark -

- (BOOL)_shouldPerformAction {
    if ( _item == nil )
        return NO;
    
    if ( _item.isHidden == YES || _item.alpha < 0.01 )
        return NO;
    
    if ( _item.customView == nil && _item.actions == nil )
        return NO;
    
    return YES;
}
@end
