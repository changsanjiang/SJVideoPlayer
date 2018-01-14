//
//  NestedTableViewCell.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/11.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "NestedTableViewCell.h"
#import <Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import "PlayerCollectionViewCell.h"

static NSString *const PlayerCollectionViewCellID = @"PlayerCollectionViewCell";

@interface NestedTableViewCell ()<UICollectionViewDelegate, UICollectionViewDataSource, PlayerCollectionViewCellDelegate>

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@end

@implementation NestedTableViewCell

@synthesize collectionView = _collectionView;

+ (CGFloat)height {
    return [PlayerCollectionViewCell itemSize].height + 20;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( !self ) return nil;
    [self _nestedSetupViews];
    return self;
}
- (void)_nestedSetupViews {
    [self.contentView addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    _collectionView.contentInset = UIEdgeInsetsMake(8, 14, 8, 14);
}

- (UICollectionView *)collectionView {
    if ( _collectionView ) return _collectionView;
    _collectionView = [SJUICollectionViewFactory collectionViewWithItemSize:[PlayerCollectionViewCell itemSize] backgroundColor:[UIColor whiteColor] scrollDirection:UICollectionViewScrollDirectionHorizontal];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:NSClassFromString(PlayerCollectionViewCellID) forCellWithReuseIdentifier:PlayerCollectionViewCellID];
    
#warning should be set it tag. 应该设置它的`tag`. 请不要设置为0.
    _collectionView.tag = 101;
    
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCollectionViewCell *cell = (PlayerCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:PlayerCollectionViewCellID forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

- (void)clickedPlayOnColCell:(PlayerCollectionViewCell *)colCell {
    if ( [_delegate respondsToSelector:@selector(clickedPlayWithNestedTabCell:playerParentView:indexPath:collectionView:)] ) {
        
        [_delegate clickedPlayWithNestedTabCell:self
                               playerParentView:colCell.backgroundImageView
                                      indexPath:[self.collectionView indexPathForCell:colCell]
                                 collectionView:self.collectionView];
    }
}
@end
