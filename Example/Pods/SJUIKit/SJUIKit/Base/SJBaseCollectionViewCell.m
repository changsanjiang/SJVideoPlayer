//
//  SJBaseCollectionViewCell.m
//  LWZBaseViews_Example
//
//  Created by BlueDancer on 2018/12/10.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "SJBaseCollectionViewCell.h"

@implementation SJBaseCollectionViewCell
+ (NSString *)reuseIdentifier {
    return [self description];
}

+ (void)registerWithCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:self.reuseIdentifier];
}

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    SJBaseCollectionViewCell *cell = nil;
    NSString *reuseIdentifier = [self reuseIdentifier];

    @try {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    } @catch (NSException *__unused exception) {
        [self registerWithCollectionView:collectionView];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    }
    return cell;
}
@end
