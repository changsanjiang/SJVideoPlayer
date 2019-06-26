//
//  SJMediaCollectionViewCell.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJMediaCollectionViewCell.h"
#import <SJUIKit/SJCornerMask.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJMediaCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *mediaTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@end

@implementation SJMediaCollectionViewCell

+ (void)registerWithNib:(nullable UINib *)nib collectionView:(UICollectionView *)collectionView {
    [collectionView registerNib:nib forCellWithReuseIdentifier:[self description]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    _coverImageView.backgroundColor = UIColor.clearColor;
    _coverImageView.sd_imageTransition = [SDWebImageTransition fadeTransition];
    _coverImageView.userInteractionEnabled = YES;
    
    SJCornerMaskSetRound(_avatarImageView, 2, UIColor.brownColor);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [_coverImageView addGestureRecognizer:tap];
    
    self.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    self.layer.borderWidth = 0.5;
}

- (void)handleTapGesture:(id)sender {
    if ( [(id)_delegate respondsToSelector:@selector(tappedOnTheCoverAtCollectionViewCell:)] ) {
        [_delegate tappedOnTheCoverAtCollectionViewCell:self];
    }
}

- (void)setDataSource:(nullable id<SJMediaCollectionViewCellDataSource>)dataSource {
    if ( dataSource != _dataSource ) {
        _dataSource = dataSource;
        [self refreshLayout];
    }
}

- (void)refreshLayout {
    _coverImageView.tag = _dataSource.coverTag;
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:_dataSource.cover] placeholderImage:[UIImage imageNamed:@"p1"]];
    _mediaTitleLabel.attributedText = _dataSource.mediaTitle;
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:_dataSource.avatar] placeholderImage:[UIImage imageNamed:@"p2"]];
    _usernameLabel.attributedText = _dataSource.username;
    self.contentView.backgroundColor = _dataSource.backgroundColor;

}

@end
NS_ASSUME_NONNULL_END
