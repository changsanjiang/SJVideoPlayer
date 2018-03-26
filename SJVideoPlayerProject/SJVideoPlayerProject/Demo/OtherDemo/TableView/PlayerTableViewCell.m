//
//  PlayerTableViewCell.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/6.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "PlayerTableViewCell.h"
#import <SJUIFactory/SJUIFactory.h>
#import <Masonry.h>

@interface PlayerTableViewCell ()

@property (nonatomic, strong, readonly) UIImageView *playImageView;

@end

@implementation PlayerTableViewCell
@synthesize playImageView = _playImageView;
@synthesize backgroundImageView = _backgroundImageView;

+ (CGFloat)height {
    return 200;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( !self ) return nil;
    [self setupView];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    if ( [_delegate respondsToSelector:@selector(clickedPlayOnTabCell:)] ) {
        [_delegate clickedPlayOnTabCell:self];
    }
}

- (UIImageView *)backgroundImageView {
    if ( _backgroundImageView ) return _backgroundImageView;
    _backgroundImageView = [SJUIImageViewFactory imageViewWithImageName:@"placeholder" viewMode:UIViewContentModeScaleAspectFill];
    _backgroundImageView.tag = 100;
    _backgroundImageView.userInteractionEnabled = YES;
    [_backgroundImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)]];
    return _backgroundImageView;
}
- (UIImageView *)playImageView {
    if ( _playImageView ) return _playImageView;
    _playImageView = [SJUIImageViewFactory imageViewWithImageName:@"play"];
    return _playImageView;
}
@end
