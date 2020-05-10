//
//  SJRecommendVideosTableViewCell.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/26.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJRecommendVideosTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJRecommendVideosTableViewCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SJVideoCollectionViewCellDelegate>
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@end

@implementation SJRecommendVideosTableViewCell
+ (void)registerWithNib:(nullable UINib *)nib tableView:(UITableView *)tableView {
    [tableView registerNib:nib forCellReuseIdentifier:[self description]];
}

- (void)coverItemWasTapped:(SJVideoCollectionViewCell *)cell {
    if ( [self.delegate respondsToSelector:@selector(cell:coverItemWasTappedInCollectionView:atIndexPath:)] ) {
        [self.delegate cell:self coverItemWasTappedInCollectionView:_collectionView atIndexPath:[_collectionView indexPathForCell:cell]];
    }
}

#pragma mark -

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _flowLayout.minimumLineSpacing = 8;
    _flowLayout.minimumInteritemSpacing = 0;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [SJVideoCollectionViewCell registerWithCollectionView:_collectionView];
}

- (void)setDataSource:(nullable id<SJRecommendVideosTableViewCellDataSource>)dataSource {
    if ( dataSource != _dataSource ) {
        _dataSource = dataSource;
        [_collectionView reloadData];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.medias.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [SJVideoCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SJVideoCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = _dataSource.medias[indexPath.item];
    cell.delegate = self;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _dataSource.medias[indexPath.item].size;
}

@end
NS_ASSUME_NONNULL_END
