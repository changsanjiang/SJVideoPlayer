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
@implementation SJEdgeControlLayerAdapters

#pragma mark -
- (SJVideoPlayerControlMaskView *)topContainerView {
    if ( _topContainerView ) return _topContainerView;
    _topContainerView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_top];
    return _topContainerView;
}

- (UIView *)leftContainerView {
    if ( _leftContainerView ) return _leftContainerView;
    _leftContainerView = [UIView new];
    return _leftContainerView;
}

- (SJVideoPlayerControlMaskView *)bottomContainerView {
    if ( _bottomContainerView ) return _bottomContainerView;
    _bottomContainerView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_bottom];
    return _bottomContainerView;
}

- (UIView *)rightContainerView {
    if ( _rightContainerView ) return _rightContainerView;
    _rightContainerView = [UIView new];
    return _rightContainerView;
}

#pragma mark - top adapter

- (SJEdgeControlLayerItemAdapter *)topAdapter {
    if ( _topAdapter ) return _topAdapter;
    _topAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithDirection:UICollectionViewScrollDirectionHorizontal];
    
    [self addSubview:self.topContainerView];
    [_topContainerView addSubview:_topAdapter.view];

    [_topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
    }];
    
    [_topAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self->_topContainerView.mas_safeAreaLayoutGuideTop).offset(8);
            make.left.equalTo(self->_topContainerView.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self->_topContainerView.mas_safeAreaLayoutGuideRight);
        } else {
            make.top.offset(8);
            make.left.right.offset(0);
        }
        make.bottom.offset(0);
        make.height.offset(49);
    }];
    
#ifdef DEBUG
    if ( self.showBackgroundColor ) {
        _topContainerView.backgroundColor =  [UIColor colorWithRed:arc4random() % 256 / 255.0
                                                             green:arc4random() % 256 / 255.0
                                                              blue:arc4random() % 256 / 255.0
                                                             alpha:1];
    }
#endif
    return _topAdapter;
}

#pragma mark - left adapter

- (SJEdgeControlLayerItemAdapter *)leftAdapter {
    if ( _leftAdapter ) return _leftAdapter;
    _leftAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithDirection:UICollectionViewScrollDirectionVertical];
    
    [self insertSubview:self.leftContainerView atIndex:0];
    [_leftContainerView addSubview:_leftAdapter.view];
    
    [_leftContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.top.bottom.offset(0);
    }];
    
    [_leftAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(49);
        make.top.bottom.right.offset(0);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self->_leftContainerView.mas_safeAreaLayoutGuideLeft);
        } else {
            make.left.offset(0);
        }
    }];
    
#ifdef DEBUG
    if ( self.showBackgroundColor ) {
        _leftContainerView.backgroundColor =  [UIColor colorWithRed:arc4random() % 256 / 255.0
                                                              green:arc4random() % 256 / 255.0
                                                               blue:arc4random() % 256 / 255.0
                                                              alpha:1];
    }
#endif
    return _leftAdapter;
}

#pragma mark - bottom adpater

- (SJEdgeControlLayerItemAdapter *)bottomAdapter {
    if ( _bottomAdapter ) return _bottomAdapter;
    _bottomAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithDirection:UICollectionViewScrollDirectionHorizontal];
    
    [self addSubview:self.bottomContainerView];
    [_bottomContainerView addSubview:_bottomAdapter.view];
    
    [_bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.offset(0);
    }];
    
    [_bottomAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self->_bottomContainerView.mas_safeAreaLayoutGuideBottom).offset(-12);
            make.left.equalTo(self->_bottomContainerView.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self->_bottomContainerView.mas_safeAreaLayoutGuideRight);
        } else {
            make.bottom.offset(0);
            make.left.right.offset(0);
        }
        make.height.offset(49);
    }];
    
#ifdef DEBUG
    if ( self.showBackgroundColor ) {
        _bottomContainerView.backgroundColor =  [UIColor colorWithRed:arc4random() % 256 / 255.0
                                                              green:arc4random() % 256 / 255.0
                                                               blue:arc4random() % 256 / 255.0
                                                              alpha:1];
    }

#endif
    return _bottomAdapter;
}

#pragma mark - right adapter

- (SJEdgeControlLayerItemAdapter *)rightAdapter {
    if ( _rightAdapter ) return _rightAdapter;
    _rightAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithDirection:UICollectionViewScrollDirectionVertical];
    
    [self insertSubview:self.rightContainerView atIndex:0];
    [_rightContainerView addSubview:_rightAdapter.view];
    
    [_rightContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(0);
        make.top.bottom.offset(0);
    }];
    
    [_rightAdapter.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(49);
        make.top.bottom.left.offset(0);
        if (@available(iOS 11.0, *)) {
            make.right.equalTo(self->_rightContainerView.mas_safeAreaLayoutGuideRight);
        } else {
            make.right.offset(0);
        }
    }];
    
#ifdef DEBUG
    if ( self.showBackgroundColor ) {
        _rightContainerView.backgroundColor =  [UIColor colorWithRed:arc4random() % 256 / 255.0
                                                                green:arc4random() % 256 / 255.0
                                                                 blue:arc4random() % 256 / 255.0
                                                                alpha:1];
    }    
#endif
    return _rightAdapter;
}
@end
NS_ASSUME_NONNULL_END
