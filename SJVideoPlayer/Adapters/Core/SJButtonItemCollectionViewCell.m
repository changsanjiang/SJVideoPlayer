//
//  SJButtonItemCollectionViewCell.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/20.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJButtonItemCollectionViewCell.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif


NS_ASSUME_NONNULL_BEGIN
@implementation SJButtonItemCollectionViewCell
static NSString *SJButtonItemCollectionViewCellID = @"SJButtonItemCollectionViewCell";
+ (void)registerWithCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:SJButtonItemCollectionViewCellID];
}

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:SJButtonItemCollectionViewCellID forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)_setupView {
    [self.contentView addSubview:self.backgroundButton];
    [self.contentView addSubview:self.itemContentView];
    [_backgroundButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];

    [_itemContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (void)clickedBackgroundBtn:(UIButton *)btn {
    if ( _clickedCellExeBlock ) _clickedCellExeBlock(self);
}

@synthesize backgroundButton = _backgroundButton;
- (UIButton *)backgroundButton {
    if ( _backgroundButton ) return _backgroundButton;
    _backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backgroundButton addTarget:self action:@selector(clickedBackgroundBtn:) forControlEvents:UIControlEventTouchUpInside];
    return _backgroundButton;
}

@synthesize itemContentView = _itemContentView;
- (SJButtonItemContentView *)itemContentView {
    if ( _itemContentView ) return _itemContentView;
    _itemContentView = [SJButtonItemContentView new];
    _itemContentView.clipsToBounds = YES;
    _itemContentView.userInteractionEnabled = NO;
    return _itemContentView;
}
 
- (UIView *)customViewContainerView {
    if ( _customViewContainerView ) return _customViewContainerView;
    _customViewContainerView = [UIView new];
    [self.contentView addSubview:_customViewContainerView];
    [_customViewContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    return _customViewContainerView;
}

- (void)removeSubviewsFromCustomViewContainerView {
    [_customViewContainerView.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}
@end


@implementation SJButtonItemContentView
@synthesize sj_titleLabel = _sj_titleLabel;
@synthesize sj_imageView = _sj_imageView;

- (UILabel *)sj_titleLabel {
    if ( _sj_titleLabel ) return _sj_titleLabel;
    _sj_titleLabel = [[UILabel alloc] init];
    _sj_titleLabel.numberOfLines = 0;
    [self addSubview:_sj_titleLabel];
    [_sj_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    return _sj_titleLabel;
}

- (UIImageView *)sj_imageView {
    if ( _sj_imageView ) return _sj_imageView;
    _sj_imageView = [[UIImageView alloc] init];
    _sj_imageView.contentMode = UIViewContentModeCenter;
    
    [self addSubview:_sj_imageView];
    [_sj_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    return _sj_imageView;
}
@end
NS_ASSUME_NONNULL_END
