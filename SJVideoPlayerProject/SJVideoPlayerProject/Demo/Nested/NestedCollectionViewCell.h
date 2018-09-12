//
//  NestedCollectionViewCell.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/9/12.
//  Copyright © 2018 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface NestedCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, copy, nullable) void(^clickedPlayButtonExeBlock)(NestedCollectionViewCell *cell, NSIndexPath *clickedIndexPath, UIView *playerSuperView);
@end
NS_ASSUME_NONNULL_END
