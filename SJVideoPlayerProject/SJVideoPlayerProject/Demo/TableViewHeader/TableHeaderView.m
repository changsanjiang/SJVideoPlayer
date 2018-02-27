//
//  TableHeaderView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/27.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "TableHeaderView.h"
#import <SJUIFactory/SJUIFactory.h>
#import <Masonry.h>

@interface TableHeaderView ()

@property (nonatomic, strong, readonly) UIButton *playBtn;

@end

@implementation TableHeaderView

@synthesize playBtn = _playBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    return self;
}

- (void)_setupViews {
    [self addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
}

- (UIButton *)playBtn {
    if ( _playBtn ) return _playBtn;
    _playBtn = [SJUIButtonFactory buttonWithImageName:@"play" target:self sel:@selector(clicked) tag:0];
    return _playBtn;
}

- (void)clicked {
    if ( self.clickedPlayBtn ) self.clickedPlayBtn(self);
}

@end
