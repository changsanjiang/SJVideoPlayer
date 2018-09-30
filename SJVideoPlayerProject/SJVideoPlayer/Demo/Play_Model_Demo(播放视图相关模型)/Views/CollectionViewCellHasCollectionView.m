//
//  CollectionViewCellHasCollectionView.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "CollectionViewCellHasCollectionView.h"

@implementation CollectionViewCellHasCollectionView
static NSString *const CollectionViewCellHasCollectionViewID = @"CollectionViewCellHasCollectionView";
+ (void)registerWithCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:CollectionViewCellHasCollectionViewID];
}

+ (CollectionViewCellHasCollectionView *)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(nonnull NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellHasCollectionViewID forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    self.contentView.backgroundColor = [UIColor blackColor];
    _view = [SJHasCollectionView new];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _view.frame = self.contentView.bounds;
    [self.contentView addSubview:_view];
    return self;
}
@end
