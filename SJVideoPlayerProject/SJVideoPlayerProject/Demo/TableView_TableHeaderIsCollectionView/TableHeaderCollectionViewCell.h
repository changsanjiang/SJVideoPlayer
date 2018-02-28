//
//  TableHeaderCollectionViewCell.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/28.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TableHeaderCollectionViewCellDelegate;

@interface TableHeaderCollectionViewCell : UICollectionViewCell

+ (CGSize)itemSize;

@property (nonatomic, weak, readwrite, nullable) id<TableHeaderCollectionViewCellDelegate> delegate;

@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;

@end

@protocol TableHeaderCollectionViewCellDelegate <NSObject>

@optional
- (void)clickedPlayOnColCell:(TableHeaderCollectionViewCell *)cell;

@end

NS_ASSUME_NONNULL_END

