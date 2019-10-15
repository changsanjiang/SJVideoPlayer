//
//  SJBaseCollectionViewCell.h
//  LWZBaseViews_Example
//
//  Created by BlueDancer on 2018/12/10.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseCollectionViewCell : UICollectionViewCell
+ (void)registerWithCollectionView:(UICollectionView *)collectionView;
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
