//
//  SJRecommendVideosCollectionViewCell.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/5/10.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJVideoCollectionViewCell.h"
#import "SJRecommendVideosTableViewCell.h"

@protocol SJRecommendVideosCollectionViewCellDelegate, SJRecommendVideosCollectionViewCellDataSource, SJExtendedMediaCollectionViewCellDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface SJRecommendVideosCollectionViewCell : SJBaseCollectionViewCell
@property (nonatomic, weak, nullable) id<SJRecommendVideosCollectionViewCellDataSource> dataSource;
@property (nonatomic, weak, nullable) id<SJRecommendVideosCollectionViewCellDelegate> delegate;
@end

@protocol SJRecommendVideosCollectionViewCellDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) NSArray<id<SJExtendedMediaCollectionViewCellDataSource>> *medias;
@end

@protocol SJRecommendVideosCollectionViewCellDelegate <NSObject>
- (void)cell:(SJRecommendVideosCollectionViewCell *)cell coverItemWasTappedInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
