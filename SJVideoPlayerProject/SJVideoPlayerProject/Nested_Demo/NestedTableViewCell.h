//
//  NestedTableViewCell.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/11.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PlayerCollectionViewCell;

@protocol NestedTableViewCellDelegate;

@interface NestedTableViewCell : UITableViewCell

+ (CGFloat)height;

@property (nonatomic, weak, readwrite, nullable) id<NestedTableViewCellDelegate> delegate;

@end

@protocol NestedTableViewCellDelegate <NSObject>

@optional
- (void)clickedPlayWithNestedTabCell:(NestedTableViewCell *)tabCell
                                 col:(UICollectionView *)collectionView
                             colCell:(PlayerCollectionViewCell *)colCell;

@end

NS_ASSUME_NONNULL_END
