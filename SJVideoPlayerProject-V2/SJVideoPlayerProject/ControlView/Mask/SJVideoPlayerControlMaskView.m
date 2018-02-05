//
//  SJVideoPlayerControlMaskView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerControlMaskView.h"

@interface SJVideoPlayerControlMaskView ()

@property (nonatomic, assign, readwrite) SJMaskStyle style;

@end

@implementation SJVideoPlayerControlMaskView {
    CAGradientLayer *_maskGradientLayer;
}

- (instancetype)initWithStyle:(SJMaskStyle)style {
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    self.style = style;
    [self initializeGL];
    return self;
}

- (void)initializeGL {
    self.backgroundColor = [UIColor clearColor];
    _maskGradientLayer = [CAGradientLayer layer];
    switch (_style) {
        case SJMaskStyle_top: {
            _maskGradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0.42].CGColor,
                                          (__bridge id)[UIColor clearColor].CGColor];
        }
            break;
        case SJMaskStyle_bottom: {
            _maskGradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                          (__bridge id)[UIColor colorWithWhite:0 alpha:0.42].CGColor];
        }
            break;
    }
    [self.layer addSublayer:_maskGradientLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _maskGradientLayer.frame = self.bounds;
}

@end
