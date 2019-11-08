//
//  SJCommonProgressSlider.m
//  SJProgressSlider
//
//  Created by 畅三江 on 2017/11/20.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJCommonProgressSlider.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif


@interface SJCommonProgressSlider ()

@property (nonatomic, strong, readonly) UIView *containerView;

@end

@implementation SJCommonProgressSlider
@synthesize containerView = _containerView;
@synthesize leftContainerView = _leftContainerView;
@synthesize slider = _slider;
@synthesize rightContainerView = _rightContainerView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _c_setupView];
    self.spacing = 4;
    return self;
}

- (void)setSpacing:(float)spacing {
    _spacing = spacing;
    [_slider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self->_leftContainerView.mas_trailing).offset(spacing);
        make.trailing.equalTo(self->_rightContainerView.mas_leading).offset(-spacing);
    }];
}

- (void)_c_setupView {
    [self addSubview:self.containerView];
    [_containerView addSubview:self.leftContainerView];
    [_containerView addSubview:self.slider];
    [_containerView addSubview:self.rightContainerView];
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_leftContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.equalTo(self->_leftContainerView.superview);
        make.width.equalTo(self->_leftContainerView.mas_height).priorityLow();
    }];
    
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
    }];
    
    [_rightContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.equalTo(self->_rightContainerView.superview);
        make.width.equalTo(self->_rightContainerView.mas_height).priorityLow();
    }];
}

- (UIView *)leftContainerView {
    if ( _leftContainerView ) return _leftContainerView;
    _leftContainerView = [UIView new];
    _leftContainerView.backgroundColor = [UIColor clearColor];
    return _leftContainerView;
}

- (SJProgressSlider *)slider {
    if ( _slider ) return _slider;
    _slider = [SJProgressSlider new];
    return _slider;
}

- (UIView *)rightContainerView {
    if ( _rightContainerView ) return _rightContainerView;
    _rightContainerView = [UIView new];
    _rightContainerView.backgroundColor = [UIColor clearColor];
    return _rightContainerView;
}

- (UIView *)containerView {
    if ( _containerView ) return _containerView;
    _containerView = [UIView new];
    _containerView.backgroundColor = [UIColor clearColor];
    return _containerView;
}

@end
