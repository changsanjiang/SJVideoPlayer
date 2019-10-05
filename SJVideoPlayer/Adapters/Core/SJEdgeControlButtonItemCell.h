//
//  SJEdgeControlButtonItemCell.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/20.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SJEdgeControlButtonItem;

NS_ASSUME_NONNULL_BEGIN
@interface SJEdgeControlButtonItemCell : UICollectionViewCell
+ (NSString *)reuseIdentifier;
+ (void)registerWithCollectionView:(UICollectionView *)collectionView;
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView
                          forIndexPath:(NSIndexPath *)indexPath
                           willSetItem:(SJEdgeControlButtonItem *)item;
@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *item;
- (void)setItem:(SJEdgeControlButtonItem * _Nullable)item NS_REQUIRES_SUPER;
@end
NS_ASSUME_NONNULL_END
