//
//  SJBaseCollectionReusableView.h
//  LWZBaseViews_Example
//
//  Created by BlueDancer on 2018/12/13.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseCollectionReusableView : UICollectionReusableView
+ (void)registerWithCollectionView:(UICollectionView *)collectionView;
+ (__kindof UICollectionReusableView *)reusableViewWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
