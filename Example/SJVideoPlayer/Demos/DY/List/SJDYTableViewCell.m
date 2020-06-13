//
//  SJDYTableViewCell.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/6/12.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJDYTableViewCell.h"
#import <Masonry/Masonry.h>
#import "SJPlayerSuperImageView.h"

@interface SJDYTableViewCell ()
@property (nonatomic, strong) SJPlayerSuperImageView *playerSuperImageView;
@property (nonatomic, strong) UIImageView *playImageView;
@end

@implementation SJDYTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( self ) {
        [self _setupViews];
    }
    return self;
}

- (void)_setupViews {
    _playerSuperImageView = [SJPlayerSuperImageView.alloc initWithFrame:CGRectZero];
    _playerSuperImageView.image = [UIImage imageNamed:@"placeholder"];
    _playerSuperImageView.contentMode = UIViewContentModeScaleAspectFill;
    _playerSuperImageView.userInteractionEnabled = YES;
    _playerSuperImageView.clipsToBounds = YES;
    [self.contentView addSubview:_playerSuperImageView];
    [_playerSuperImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    if (@available(iOS 13.0, *)) {
        _playImageView = [UIImageView.alloc initWithImage:[[UIImage imageNamed:@"play"] imageWithTintColor:[UIColor colorWithRed:0.92 green:0.05 blue:0.5 alpha:1]]];
    } else {
        _playImageView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"play"]];
    }
    [self.contentView addSubview:_playImageView];
    [_playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
}

- (void)setIsPlayImageViewHidden:(BOOL)isPlayImageViewHidden {
    _playImageView.hidden = isPlayImageViewHidden;
}

- (BOOL)isPlayImageViewHidden {
    return _playImageView.isHidden;
}
@end
