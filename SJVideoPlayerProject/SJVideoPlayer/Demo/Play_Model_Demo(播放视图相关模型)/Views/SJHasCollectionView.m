//
//  SJHasCollectionView.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJHasCollectionView.h"
#import <Masonry/Masonry.h>
#import "SJCollectionViewCell.h"

@interface SJHasCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation SJHasCollectionView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.width * 9 / 16.0 + 8);
    CGFloat space = 8;
    layout.minimumLineSpacing = space;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.tag = 100;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, space);
    [SJCollectionViewCell registerWithCollectionView:_collectionView];
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.offset(0);
        make.trailing.offset(space);
    }];
    
    _pageControl = [UIPageControl new];
    _pageControl.numberOfPages = 5;
    _pageControl.currentPage = 0;
    
    [self addSubview:_pageControl];
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(0);
        make.centerX.offset(0);
    }];
    
    return self;
}

- (void)sj_playerNeedPlayNewAssetAtIndexPath:(NSIndexPath *)indexPath {
    SJCollectionViewCell *cell = (id)[_collectionView cellForItemAtIndexPath:indexPath];
    if ( self.clickedPlayButtonExeBlock ) self.clickedPlayButtonExeBlock(self, cell.view, indexPath);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UICollectionViewCell *first = _collectionView.visibleCells.firstObject;
    UICollectionViewCell * last = _collectionView.visibleCells.lastObject;
    CGRect first_rect = [first.superview convertRect:first.frame toView:self];
    CGRect last_rect  = [last.superview convertRect:last.frame toView:self];
    CGFloat mid = self.bounds.size.width * .5;
    NSIndexPath *indexPath = ABS(CGRectGetMaxX(first_rect) - mid) < ABS(CGRectGetMinX(last_rect) - mid) ? [_collectionView indexPathForCell:first] : [_collectionView indexPathForCell:last];
    _pageControl.currentPage = indexPath.item;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [SJCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SJCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) _self = self;
    cell.view.clickedPlayButtonExeBlock = ^(SJPlayView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self sj_playerNeedPlayNewAssetAtIndexPath:indexPath];
    };
}
@end
