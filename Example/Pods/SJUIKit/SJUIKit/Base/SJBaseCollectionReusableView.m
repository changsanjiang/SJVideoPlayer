//
//  SJBaseCollectionReusableView.m
//  LWZBaseViews_Example
//
//  Created by BlueDancer on 2018/12/13.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "SJBaseCollectionReusableView.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJBaseCollectionReusableView
+ (NSString *)reuseIdentifier {
    return [self description];
}

+ (void)registerWithCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:[self class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[self reuseIdentifier]];
}
+ (__kindof UICollectionReusableView *)reusableViewWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [self reuseIdentifier];
    SJBaseCollectionReusableView *view = nil;
    @try {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    } @catch (NSException *exception) {
        [collectionView registerClass:[self class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseIdentifier];
        view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    }
    return view;
}
@end
NS_ASSUME_NONNULL_END
