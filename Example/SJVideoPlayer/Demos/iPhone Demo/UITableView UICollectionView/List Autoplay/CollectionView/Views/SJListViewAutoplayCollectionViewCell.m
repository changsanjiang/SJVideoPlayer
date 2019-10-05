//
//  SJListViewAutoplayCollectionViewCell.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/8/16.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJListViewAutoplayCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>
#import <SDWebImage/SDWebImageTransition.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJListViewAutoplayCollectionViewCell ()
@property (nonatomic, strong, readonly) UIImageView *playerSuperview;
@property (nonatomic, strong, readonly) SJListViewAutoplayMediaInfoView *mediaInfoView;
@end

@implementation SJListViewAutoplayCollectionViewCell
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIImageView appearance].sd_imageTransition = [SDWebImageTransition fadeTransition];
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)setDataSource:(nullable id<SJListViewAutoplayCollectionViewCellDataSource>)dataSource {
    _dataSource = dataSource;
    _mediaInfoView.dataSource = dataSource;
}

- (void)refreshData {
    _playerSuperview.tag = _dataSource.tag;
    [_playerSuperview sd_setImageWithURL:[NSURL URLWithString:_dataSource.cover]];
    [_mediaInfoView reloadData];
}

- (void)_setupView {
    [self.contentView addSubview:self.playerSuperview];
    [self.contentView addSubview:self.mediaInfoView];
    
    [_playerSuperview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_mediaInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

@synthesize playerSuperview = _playerSuperview;
- (UIImageView *)playerSuperview {
    if ( _playerSuperview == nil ) {
        _playerSuperview = [[UIImageView alloc] initWithFrame:CGRectZero];
        _playerSuperview.userInteractionEnabled = YES;
        _playerSuperview.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _playerSuperview;
}

@synthesize mediaInfoView = _mediaInfoView;
- (SJListViewAutoplayMediaInfoView *)mediaInfoView {
    if ( _mediaInfoView == nil ) {
        _mediaInfoView = [[SJListViewAutoplayMediaInfoView alloc] initWithFrame:CGRectZero];
    }
    return _mediaInfoView;
}
@end
NS_ASSUME_NONNULL_END
