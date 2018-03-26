//
//  PlayerCollectionViewCell.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/11.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "PlayerCollectionViewCell.h"
#import <SJUIFactory/SJUIFactory.h>
#import <Masonry.h>

@interface PlayerCollectionViewCell ()

@property (nonatomic, strong, readonly) UIImageView *playImageView;

@end

@implementation PlayerCollectionViewCell
@synthesize playImageView = _playImageView;
@synthesize backgroundImageView = _backgroundImageView;

+ (CGSize)itemSize {
    CGFloat w = SJScreen_W() - 44;
    CGFloat h = w * 9.0 / 16;
    return CGSizeMake(w, h);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self setupView];
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.backgroundImageView];
    [_backgroundImageView addSubview:self.playImageView];
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.offset(8);
        make.bottom.offset(-8);
        make.width.equalTo(self->_backgroundImageView.mas_height).multipliedBy(16.0 / 9);
    }];
    
    [_playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.size.offset(25);
    }];
}

- (void)handleTap {
    if ( [_delegate respondsToSelector:@selector(clickedPlayOnColCell:)] ) {
        [_delegate clickedPlayOnColCell:self];
    }
}

- (UIImageView *)backgroundImageView {
    if ( _backgroundImageView ) return _backgroundImageView;
    _backgroundImageView = [SJUIImageViewFactory imageViewWithImageName:@"placeholder" viewMode:UIViewContentModeScaleAspectFill];
    _backgroundImageView.userInteractionEnabled = YES;
    [_backgroundImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)]];
#warning should be set it tag. 应该设置它的`tag`. 请不要设置为0.
    _backgroundImageView.tag = 101;
    return _backgroundImageView;
}
- (UIImageView *)playImageView {
    if ( _playImageView ) return _playImageView;
    _playImageView = [SJUIImageViewFactory imageViewWithImageName:@"play"];
    return _playImageView;
}
@end
