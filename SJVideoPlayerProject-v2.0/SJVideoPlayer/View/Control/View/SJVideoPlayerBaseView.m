//
//  SJVideoPlayerBaseView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/30.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerBaseView.h"
#import <Masonry/Masonry.h>
#import <SJUIFactory/SJUIFactory.h>

@implementation SJVideoPlayerBaseView

@synthesize containerView = _containerView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _baseSetupView];
    return self;
}

- (void)_baseSetupView {
    [self addSubview:self.containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (UIView *)containerView {
    if ( _containerView ) return _containerView;
    _containerView = [SJUIFactory viewWithBackgroundColor:nil];
    return _containerView;
}

@end
