//
//  SJMediaItemsTableViewCell.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJMediaItemsTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJMediaItemsTableViewCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SJMediaCollectionViewCellDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@end

@implementation SJMediaItemsTableViewCell
+ (void)registerWithNib:(nullable UINib *)nib tableView:(UITableView *)tableView {
    [tableView registerNib:nib forCellReuseIdentifier:[self description]];
}

- (void)tappedOnTheCoverAtCollectionViewCell:(SJMediaCollectionViewCell *)cell {
    if ( [self.delegate respondsToSelector:@selector(mediaItemsTableViewCell:tappedOnTheCoverAtIndexPath:)] ) {
        [self.delegate mediaItemsTableViewCell:self
                   tappedOnTheCoverAtIndexPath:[_collectionView indexPathForCell:cell]];
    }
}

#pragma mark -

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _flowLayout.minimumLineSpacing = 0;
    _flowLayout.minimumInteritemSpacing = 8;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [SJMediaCollectionViewCell registerWithNib:[UINib nibWithNibName:@"SJMediaCollectionViewCell" bundle:nil] collectionView:_collectionView];
}

- (void)setDataSource:(nullable id<SJMediaItemsTableViewCellDataSource>)dataSource {
    if ( dataSource != _dataSource ) {
        _dataSource = dataSource;
        
        _collectionView.tag = dataSource.collectionViewTag;
        
        if ( _collectionView.visibleCells.count != 0 ) {
            [_collectionView.visibleCells enumerateObjectsUsingBlock:^(SJMediaCollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj refreshLayout];
            }];
        }
        else {
            [_collectionView reloadData];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.medias.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [SJMediaCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SJMediaCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = _dataSource.medias[indexPath.item];
    cell.delegate = self;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _dataSource.medias[indexPath.item].size;
}

@end
NS_ASSUME_NONNULL_END
