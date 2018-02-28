//
//  TableHeaderCollectionView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/28.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "TableHeaderCollectionView.h"
#import <Masonry.h>
#import <SJUIFactory.h>
#import <UIView+SJUIFactory.h>
#import "TableHeaderCollectionViewCell.h"

static NSString * const TableHeaderCollectionViewCellID = @"TableHeaderCollectionViewCell";

@interface TableHeaderCollectionView ()<UICollectionViewDelegate, UICollectionViewDataSource, TableHeaderCollectionViewCellDelegate>

@property (nonatomic, strong, readonly) UIPageControl *pageControl;

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@end

@implementation TableHeaderCollectionView

@synthesize pageControl = _pageControl;
@synthesize collectionView = _collectionView;

+ (CGFloat)height {
    return [TableHeaderCollectionViewCell itemSize].height;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    return self;
}

- (void)_setupViews {
    [self addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [self addSubview:self.pageControl];
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(-16);
        make.bottom.offset(0);
    }];
}

- (UIPageControl *)pageControl {
    if ( _pageControl ) return _pageControl;
    _pageControl = [UIPageControl new];
    _pageControl.numberOfPages = [self collectionView:self.collectionView numberOfItemsInSection:0];
    return _pageControl;
}

- (UICollectionView *)collectionView {
    if ( _collectionView ) return _collectionView;
    _collectionView = [SJUICollectionViewFactory collectionViewWithItemSize:[TableHeaderCollectionViewCell itemSize] backgroundColor:[UIColor whiteColor] scrollDirection:UICollectionViewScrollDirectionHorizontal];
    [_collectionView registerClass:[TableHeaderCollectionViewCell class] forCellWithReuseIdentifier:TableHeaderCollectionViewCellID];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TableHeaderCollectionViewCell *cell = (TableHeaderCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TableHeaderCollectionViewCellID forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

- (void)clickedPlayOnColCell:(TableHeaderCollectionViewCell *)cell {
    if ( self.clickedPlayBtnExeBlock ) self.clickedPlayBtnExeBlock(self, self.collectionView, [self.collectionView indexPathForCell:cell], cell.backgroundImageView);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.pageControl.currentPage = scrollView.contentOffset.x / self.csj_w;
}

@end
