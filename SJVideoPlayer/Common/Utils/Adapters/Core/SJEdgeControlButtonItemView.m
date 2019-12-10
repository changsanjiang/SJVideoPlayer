//
//  SJEdgeControlButtonItemView.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/19.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlButtonItemView.h"

NS_ASSUME_NONNULL_BEGIN
@interface _SJItemCustomViewContainerView : UIView
- (nullable __kindof UIView *)customView;

@end

@implementation _SJItemCustomViewContainerView
- (void)layoutSubviews {
    [super layoutSubviews];
    for ( UIView *subview in self.subviews ) {
        subview.frame = self.bounds;
    }
}

- (void)removeCustomView {
    UIView *_Nullable customView = self.customView;
    if ( customView != nil ) {
        [customView removeFromSuperview];
    }
}

- (void)addCustomView:(UIView *)customView {
    if ( self.customView != customView ) {
        [self removeCustomView];
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

- (void)performAction {
    [_item performAction];
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
    
    if ( _item == nil ) {
        // clean
        [_containerView removeCustomView];
        return;
    }
    
    if ( _item.isHidden ) return;
    
    // 1.
    if ( _item.customView != nil ) {
        // show containerView
        if ( _containerView != nil ) {
            _containerView.hidden = NO;
        }
        else {
            _containerView = [_SJItemCustomViewContainerView.alloc initWithFrame:self.bounds];
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

- (void)layoutSubviews {
    [super layoutSubviews];
    for ( UIView *subview in self.subviews ) {
        subview.frame = self.bounds;
    }
}
@end
NS_ASSUME_NONNULL_END
