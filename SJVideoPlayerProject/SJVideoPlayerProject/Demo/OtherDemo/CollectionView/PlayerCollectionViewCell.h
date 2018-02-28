//
//  PlayerCollectionViewCell.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/11.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PlayerCollectionViewCellDelegate;

@interface PlayerCollectionViewCell : UICollectionViewCell

+ (CGSize)itemSize;

@property (nonatomic, weak, readwrite, nullable) id<PlayerCollectionViewCellDelegate> delegate;

@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;

@end

@protocol PlayerCollectionViewCellDelegate <NSObject>

@optional
- (void)clickedPlayOnColCell:(PlayerCollectionViewCell *)cell;

@end

NS_ASSUME_NONNULL_END
