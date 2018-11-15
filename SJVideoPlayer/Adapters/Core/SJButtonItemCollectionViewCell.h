//
//  SJButtonItemCollectionViewCell.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/20.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJButtonItemContentView : UIView
@property (nonatomic, strong, readonly) UILabel *sj_titleLabel;
@property (nonatomic, strong, readonly) UIImageView *sj_imageView;
@end

@interface SJButtonItemCollectionViewCell : UICollectionViewCell {
    @public
    UIView *_customViewContainerView;
}
+ (void)registerWithCollectionView:(UICollectionView *)collectionView;
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy, nullable) void(^clickedCellExeBlock)(SJButtonItemCollectionViewCell *cell);
@property (nonatomic, strong, readonly) SJButtonItemContentView *itemContentView;
@property (nonatomic, strong, readonly) UIView *customViewContainerView;
@property (nonatomic, strong, readonly) UIButton *backgroundButton;
- (void)removeSubviewsFromCustomViewContainerView;
@end
NS_ASSUME_NONNULL_END
