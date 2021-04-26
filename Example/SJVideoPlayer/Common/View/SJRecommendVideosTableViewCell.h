//
//  SJRecommendVideosTableViewCell.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJBaseTableViewCell.h"
#import "SJVideoCollectionViewCell.h"

@protocol SJRecommendVideosTableViewCellDelegate, SJRecommendVideosTableViewCellDataSource, SJExtendedMediaCollectionViewCellDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface SJRecommendVideosTableViewCell : SJBaseTableViewCell
+ (void)registerWithNib:(nullable UINib *)nib tableView:(UITableView *)tableView;
@property (nonatomic, weak, nullable) id<SJRecommendVideosTableViewCellDataSource> dataSource;
@property (nonatomic, weak, nullable) id<SJRecommendVideosTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@protocol SJRecommendVideosTableViewCellDataSource <NSObject>
@property (nonatomic, strong, readonly, nullable) NSArray<id<SJExtendedMediaCollectionViewCellDataSource>> *medias;
@end

@protocol SJExtendedMediaCollectionViewCellDataSource <SJVideoCollectionViewCellDataSource>
@property (nonatomic) CGSize size;
@end

@protocol SJRecommendVideosTableViewCellDelegate <NSObject>
- (void)cell:(SJRecommendVideosTableViewCell *)cell coverItemWasTappedInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
