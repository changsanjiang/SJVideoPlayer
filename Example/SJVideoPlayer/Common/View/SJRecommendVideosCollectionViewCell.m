//
//  SJRecommendVideosCollectionViewCell.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/5/10.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJRecommendVideosCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJRecommendVideosCollectionViewCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SJVideoCollectionViewCellDelegate>
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation SJRecommendVideosCollectionViewCell
+ (void)registerWithCollectionView:(UICollectionView *)collectionView {
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(self) bundle:nil] forCellWithReuseIdentifier:[self description]];
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

- (void)setDataSource:(nullable id<SJRecommendVideosCollectionViewCellDataSource>)dataSource {
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
