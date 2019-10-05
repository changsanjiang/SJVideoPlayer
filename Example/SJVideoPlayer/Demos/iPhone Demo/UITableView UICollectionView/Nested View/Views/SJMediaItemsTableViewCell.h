//
//  SJMediaItemsTableViewCell.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJBaseTableViewCell.h"
#import "SJMediaCollectionViewCell.h"
@protocol SJMediaItemsTableViewCellDelegate, SJMediaItemsTableViewCellDataSource, SJExtendedMediaCollectionViewCellDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface SJMediaItemsTableViewCell : SJBaseTableViewCell
+ (void)registerWithNib:(nullable UINib *)nib tableView:(UITableView *)tableView;
@property (nonatomic, weak, nullable) id<SJMediaItemsTableViewCellDataSource> dataSource;
@property (nonatomic, weak, nullable) id<SJMediaItemsTableViewCellDelegate> delegate;
@end

@protocol SJMediaItemsTableViewCellDataSource <NSObject>
@property (nonatomic, readonly) NSInteger collectionViewTag;
@property (nonatomic, strong, readonly, nullable) NSArray<id<SJExtendedMediaCollectionViewCellDataSource>> *medias;
@end

@protocol SJExtendedMediaCollectionViewCellDataSource <SJMediaCollectionViewCellDataSource>
@property (nonatomic) CGSize size;
@end

@protocol SJMediaItemsTableViewCellDelegate <NSObject>
- (void)mediaItemsTableViewCell:(SJMediaItemsTableViewCell *)cell tappedOnTheCoverAtIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
