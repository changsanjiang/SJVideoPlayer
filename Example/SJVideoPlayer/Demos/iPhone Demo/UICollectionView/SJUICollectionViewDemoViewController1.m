//
//  SJUICollectionViewDemoViewController1.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/5/10.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJUICollectionViewDemoViewController1.h"
#import <Masonry/Masonry.h>
#import "SJVideoCellViewModel.h"

@interface SJUICollectionViewDemoViewController1 ()<SJVideoCollectionViewCellDelegate>
@property (nonatomic, strong) NSMutableArray<SJVideoCellViewModel *> *models;
@end

@implementation SJUICollectionViewDemoViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

- (void)coverItemWasTapped:(SJVideoCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    SJVideoCellViewModel *vm = _models[indexPath.row];
    
    if ( !_player ) {
        _player = [SJVideoPlayer player];
    }
    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:vm.url playModel:[SJPlayModel playModelWithCollectionView:_collectionView indexPath:indexPath superviewSelector:NSSelectorFromString(@"coverImageView")]];
    _player.URLAsset.title = vm.mediaTitle.string;
}

#pragma mark -

- (void)_setupViews {
    self.title = NSStringFromClass(self.class);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    // 创建测试数据
    __auto_type items = [SJVideoModel testItemsWithCount:3];
    for ( SJVideoModel *item in items ) {
        [self.models addObject:[SJVideoCellViewModel.alloc initWithItem:item]];
    }
    [_collectionView reloadData];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [SJVideoCollectionViewCell cellWithCollectionView:_collectionView indexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.bounds.size.width, _models[indexPath.item].height);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SJVideoCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.dataSource = self.models[indexPath.item];
    cell.delegate = self;
}

@synthesize collectionView = _collectionView;
- (UICollectionView *)collectionView {
    if ( _collectionView == nil ) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.whiteColor;
        [SJVideoCollectionViewCell registerWithCollectionView:_collectionView];
    }
    return _collectionView;
}

@synthesize models = _models;
- (NSMutableArray<SJVideoCellViewModel *> *)models {
    if ( _models == nil ) {
        _models = [NSMutableArray new];
    }
    return _models;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player vc_viewDidDisappear];
}
 
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
- (BOOL)shouldAutorotate {
    return NO;
}
@end
