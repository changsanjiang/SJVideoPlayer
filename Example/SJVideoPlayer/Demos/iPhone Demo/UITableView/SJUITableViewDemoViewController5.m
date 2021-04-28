//
//  SJUITableViewDemoViewController2.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/5/10.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJUITableViewDemoViewController5.h"
#import <SJUIKit/SJBaseTableViewHeaderFooterView.h>
#import <Masonry/Masonry.h>
#import "SJSourceURLs.h"


@interface SJUITableViewSectionFooterView : SJBaseTableViewHeaderFooterView
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UIView *playerSuperview;
@property (nonatomic, strong) UIImageView *playImageView;

@property (nonatomic, copy, nullable) void(^playerSuperviewWasTapped)(SJUITableViewSectionFooterView *headerView);
@end

@implementation SJUITableViewSectionFooterView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if ( self ) {
        self.contentView.backgroundColor = UIColor.lightGrayColor;
        
        _avatarImageView = [UIImageView.alloc initWithFrame:CGRectZero];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.image = [UIImage imageNamed:@"2"];
        _avatarImageView.clipsToBounds = YES;
        [self.contentView addSubview:_avatarImageView];
        [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.offset(12);
            make.height.offset(40);
        }];
        
        _usernameLabel = [UILabel.alloc initWithFrame:CGRectZero];
        _usernameLabel.text = @"请点击黑色区域进行播放";
        [self.contentView addSubview:_usernameLabel];
        [_usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImageView.mas_right).offset(8);
            make.centerY.equalTo(self.avatarImageView);
        }];
        
        _playerSuperview = [UIView.alloc initWithFrame:CGRectZero];
        _playerSuperview.backgroundColor = UIColor.blackColor;
        [self.contentView addSubview:_playerSuperview];
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

@interface SJUITableViewDemoViewController5 ()

@end

@implementation SJUITableViewDemoViewController5
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SJUITableViewSectionFooterView registerWithTableView:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 300;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    SJUITableViewSectionFooterView *view = [SJUITableViewSectionFooterView reusableViewWithTableView:tableView];
    __weak typeof(self) _self = self;
    view.playerSuperviewWasTapped = ^(SJUITableViewSectionFooterView *headerView) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        if ( !self.player ) self.player = SJVideoPlayer.player;
        
        self.player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0 playModel:[SJPlayModel playModelWithTableView:self.tableView inFooterForSection:section superviewSelector:NSSelectorFromString(@"playerSuperview")]];
    };
    return view;
}
- (BOOL)shouldAutorotate {
    return NO;
}
@end
