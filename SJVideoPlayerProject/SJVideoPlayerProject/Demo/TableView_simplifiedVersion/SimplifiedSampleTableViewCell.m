//
//  SimplifiedSampleTableViewCell.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/7/10.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SimplifiedSampleTableViewCell.h"
#import <Masonry.h>
#import <SJUIFactory/SJUIFactory.h>

NS_ASSUME_NONNULL_BEGIN
@interface SimplifiedSampleTableViewCell()
@end

@implementation SimplifiedSampleTableViewCell
@synthesize backgroundImageView = _backgroundImageView;
@synthesize playImageView = _playImageView;

+ (CGFloat)height {
    return SJScreen_Min() * 9 / 16 + 8;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)_setupView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.backgroundImageView];
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.bottom.offset(-8);
    }];
    
    [self.backgroundImageView addSubview:self.playImageView];
    [self.playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_backgroundImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    if ( [_delegate respondsToSelector:@selector(clickedPlayButtonOnTheTabCell:)] ) {
        [_delegate clickedPlayButtonOnTheTabCell:self];
    }
}

- (UIImageView *)backgroundImageView {
    if ( _backgroundImageView ) return _backgroundImageView;
    _backgroundImageView = [UIImageView new];
    _backgroundImageView.backgroundColor = [UIColor whiteColor];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.tag = 101;
    _backgroundImageView.userInteractionEnabled = YES;
    _backgroundImageView.clipsToBounds = YES;
    return _backgroundImageView;
}
- (UIImageView *)playImageView {
    if ( _playImageView ) return _playImageView;
    _playImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play"]];
    _playImageView.contentMode = UIViewContentModeScaleAspectFill;
    return _playImageView;
}
@end
NS_ASSUME_NONNULL_END
