//
//  SJButtonItemCollectionViewCell.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/20.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJButtonItemCollectionViewCell : UICollectionViewCell
+ (void)registerWithCollectionView:(UICollectionView *)collectionView;
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong, readonly) UIButton *button;
@end
NS_ASSUME_NONNULL_END
