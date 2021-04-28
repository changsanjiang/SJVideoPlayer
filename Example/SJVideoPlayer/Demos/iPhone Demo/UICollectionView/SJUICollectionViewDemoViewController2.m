//
//  SJUICollectionViewDemoViewController1.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/5/10.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJUICollectionViewDemoViewController2.h"
#import <Masonry/Masonry.h>
#import <SJUIKit/SJBaseCollectionReusableView.h>
#import <Masonry/Masonry.h>
#import "SJSourceURLs.h"

@interface SJUICollectionViewSectionHeaderView : SJBaseCollectionReusableView
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UIView *playerSuperview;
@property (nonatomic, strong) UIImageView *playImageView;

@property (nonatomic, copy, nullable) void(^playerSuperviewWasTapped)(SJUICollectionViewSectionHeaderView *headerView);
@end

@implementation SJUICollectionViewSectionHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        self.backgroundColor = UIColor.lightGrayColor;
        
        _avatarImageView = [UIImageView.alloc initWithFrame:CGRectZero];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.image = [UIImage imageNamed:@"2"];
        _avatarImageView.clipsToBounds = YES;
        [self addSubview:_avatarImageView];
        [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.offset(12);
            make.height.offset(40);
        }];
        
        _usernameLabel = [UILabel.alloc initWithFrame:CGRectZero];
        _usernameLabel.text = @"请点击黑色区域进行播放";
        [self addSubview:_usernameLabel];
        [_usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImageView.mas_right).offset(8);
            make.centerY.equalTo(self.avatarImageView);
        }];
        
        _playerSuperview = [UIView.alloc initWithFrame:CGRectZero];
        _playerSuperview.backgroundColor = UIColor.blackColor;
        [self addSubview:_playerSuperview];
        [_playerSuperview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_bottom).offset(8);
            make.left.offset(8);
            make.bottom.right.offset(-8);
        }];
        
        _playImageView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"play"]];
        [_playerSuperview addSubview:_playImageView];
        [_playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.offset(0);
        }];
        
        UITapGestureRecognizer *tap = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(handleTap)];
        [_playerSuperview addGestureRecognizer:tap];
    }
    return self;
}

- (void)handleTap {
    if ( _playerSuperviewWasTapped != nil ) _playerSuperviewWasTapped(self);
}
@end


#pragma mark -


@interface SJUICollectionViewDemoViewController2 ()

@end

@implementation SJUICollectionViewDemoViewController2
- (BOOL)shouldAutorotate {
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
 
    [SJUICollectionViewSectionHeaderView registerWithCollectionView:self.collectionView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.bounds.size.width, 300);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SJUICollectionViewSectionHeaderView *view = [SJUICollectionViewSectionHeaderView reusableViewWithCollectionView:collectionView indexPath:indexPath];
    __weak typeof(self) _self = self;
    view.playerSuperviewWasTapped = ^(SJUICollectionViewSectionHeaderView *headerView) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;

        if ( self.player == nil ) self.player = SJVideoPlayer.player;
        
        self.player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0 playModel:[SJPlayModel playModelWithCollectionView:collectionView inHeaderForSection:indexPath.section superviewSelector:NSSelectorFromString(@"playerSuperview")]];
    };
    return view;
}
@end
