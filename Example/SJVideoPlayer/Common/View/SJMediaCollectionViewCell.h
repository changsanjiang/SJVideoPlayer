//
//  SJMediaCollectionViewCell.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJBaseCollectionViewCell.h"
@protocol SJMediaCollectionViewCellDataSource, SJMediaCollectionViewCellDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SJMediaCollectionViewCell : SJBaseCollectionViewCell
+ (void)registerWithNib:(nullable UINib *)nib collectionView:(UICollectionView *)collectionView;
@property (nonatomic, weak, nullable) id<SJMediaCollectionViewCellDataSource> dataSource;
@property (nonatomic, weak, nullable) id<SJMediaCollectionViewCellDelegate> delegate;

- (void)refreshLayout;
@end

@protocol SJMediaCollectionViewCellDataSource
@property (nonatomic, readonly) NSInteger coverTag;
@property (nonatomic, copy, readonly, nullable) NSString *cover;
@property (nonatomic, copy, readonly, nullable) NSAttributedString *mediaTitle;
@property (nonatomic, copy, readonly, nullable) NSString *avatar;
@property (nonatomic, copy, readonly, nullable) NSAttributedString *username;
@property (nonatomic, strong, readonly, nullable) UIColor *backgroundColor;
@end

@protocol SJMediaCollectionViewCellDelegate
- (void)tappedOnTheCoverAtCollectionViewCell:(SJMediaCollectionViewCell *)cell;
@end
NS_ASSUME_NONNULL_END
