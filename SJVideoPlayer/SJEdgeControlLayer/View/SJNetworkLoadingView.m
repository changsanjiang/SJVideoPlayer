//
//  SJNetworkLoadingView.m
//  Pods
//
//  Created by 畅三江 on 2017/12/24.
//  Copyright © 2017年 畅三江. All rights reserved.
//

#import "SJNetworkLoadingView.h"
#import "SJLoadingView.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

@interface SJNetworkLoadingView ()
@property (nonatomic, strong, readonly) UILabel *speedLabel;
@property (nonatomic, strong, readonly) SJLoadingView *loadingView;
@end

@implementation SJNetworkLoadingView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)_setupView {
    self.clipsToBounds = NO;
    
    _loadingView = [[SJLoadingView alloc] initWithFrame:CGRectZero];
    [self addSubview:_loadingView];
    
    _speedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_speedLabel];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_loadingView.mas_bottom).offset(8);
        make.centerX.offset(0);
        make.width.offset(80);
    }];
    
    self.alpha = 0.001;
}

- (void)setLineColor:(nullable UIColor *)lineColor {
    _loadingView.lineColor = lineColor;
}
- (UIColor *)lineColor {
    return _loadingView.lineColor;
}

- (BOOL)isAnimating {
    return _loadingView.isAnimating;
}

- (void)start {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(_start) withObject:nil afterDelay:0.1 inModes:@[NSRunLoopCommonModes]];
}

- (void)stop {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(_stop) withObject:nil afterDelay:0.1 inModes:@[NSRunLoopCommonModes]];
}

- (void)_start {
    if ( self->_loadingView.isAnimating )
        return;
    [UIView animateWithDuration:0.3 animations:^{
        [self->_loadingView start];
        self.alpha = 1;
    }];
}

- (void)_stop {
    if ( !self->_loadingView.isAnimating )
        return;
    [UIView animateWithDuration:0.3 animations:^{
        [self->_loadingView stop];
        self.alpha = 0.001;
    }];
}

- (void)setNetworkSpeedStr:(NSAttributedString *)networkSpeedStr {
    _speedLabel.attributedText = networkSpeedStr;
}
- (NSAttributedString *)networkSpeedStr {
    return _speedLabel.attributedText;
}
@end
