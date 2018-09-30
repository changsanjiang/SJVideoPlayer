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

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithStyle:(SJMaskStyle)style {
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    self.style = style;
    CAGradientLayer *maskGradientLayer = (id)self.layer;
    switch (_style) {
        case SJMaskStyle_top: {
            maskGradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0.42].CGColor,
                                         (__bridge id)[UIColor clearColor].CGColor];
        }
            break;
        case SJMaskStyle_bottom: {
            maskGradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                         (__bridge id)[UIColor colorWithWhite:0 alpha:0.42].CGColor];
        }
            break;
    }
    return self;
}

@end
