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
        make.leading.offset(20);
        make.trailing.offset(-20);
        make.centerY.offset(0);
        make.height.equalTo(_backgroundImageView.mas_width).multipliedBy(9.0 / 16.0);
    }];
    
    [_playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(8);
        make.bottom.offset(-8);
        make.size.offset(25);
    }];
}

- (UIImageView *)backgroundImageView {
    if ( _backgroundImageView ) return _backgroundImageView;
    _backgroundImageView = [SJUIFactory imageViewWithImageName:@"placeholder"];
    return _backgroundImageView;
}
- (UIImageView *)playImageView {
    if ( _playImageView ) return _playImageView;
    _playImageView = [SJUIFactory imageViewWithImageName:@"play"];
    return _playImageView;
}
@end
