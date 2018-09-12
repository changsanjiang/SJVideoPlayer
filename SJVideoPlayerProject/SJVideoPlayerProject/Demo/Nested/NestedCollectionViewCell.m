//
//  NestedCollectionViewCell.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/9/12.
//  Copyright © 2018 SanJiang. All rights reserved.
//

#import "NestedCollectionViewCell.h"
#import <Masonry.h>
#import <SJUIFactory/SJUIFactory.h>

NS_ASSUME_NONNULL_BEGIN

@interface __PlayerCollectionViewCell: UICollectionViewCell
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, copy, nullable) void(^clickedPlayButtonExeBlock)(__PlayerCollectionViewCell *cell);
@end

@implementation __PlayerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self setupView];
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.backgroundImageView];
    [_backgroundImageView addSubview:self.playButton];
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.size.offset(25);
    }];
}

- (void)clickedPlay {
    if ( _clickedPlayButtonExeBlock ) _clickedPlayButtonExeBlock(self);
}

- (UIImageView *)backgroundImageView {
    if ( _backgroundImageView ) return _backgroundImageView;
    _backgroundImageView = [SJUIImageViewFactory imageViewWithImageName:@"placeholder" viewMode:UIViewContentModeScaleAspectFill];
    _backgroundImageView.userInteractionEnabled = YES;
    [_backgroundImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedPlay)]];
    _backgroundImageView.tag = 101;
    return _backgroundImageView;
}
- (UIButton *)playButton {
    if ( _playButton ) return _playButton;
    _playButton = [SJUIButtonFactory buttonWithImageName:@"play" target:self sel:@selector(clickedPlay) tag:0];
    return _playButton;
}
@end


static NSString *const __PlayerCollectionViewCellID = @"__PlayerCollectionViewCell";
@interface NestedCollectionViewCell()<UICollectionViewDataSource, UICollectionViewDelegate>
@end

@implementation NestedCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    return self;
}

- (void)_setupViews {
    [self.contentView addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

@synthesize collectionView = _collectionView;
- (UICollectionView *)collectionView {
    if ( _collectionView ) return _collectionView;
    _collectionView = [SJUICollectionViewFactory collectionViewWithItemSize:CGSizeMake(180, 180*9/16.0) backgroundColor:[UIColor whiteColor] scrollDirection:UICollectionViewScrollDirectionHorizontal minimumLineSpacing:8 minimumInteritemSpacing:8];
    [_collectionView registerClass:NSClassFromString(__PlayerCollectionViewCellID) forCellWithReuseIdentifier:__PlayerCollectionViewCellID];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.tag = 101;
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 99;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __PlayerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:__PlayerCollectionViewCellID forIndexPath:indexPath];
    __weak typeof(self) _self = self;
    cell.clickedPlayButtonExeBlock = ^(__PlayerCollectionViewCell * _Nonnull cell) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.clickedPlayButtonExeBlock ) self.clickedPlayButtonExeBlock(self, indexPath, cell.backgroundImageView);
    };
    return cell;
}
@end
NS_ASSUME_NONNULL_END
