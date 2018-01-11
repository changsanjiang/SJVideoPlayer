//
//  PlayerTableViewCell.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/6.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PlayerTableViewCellDelegate;

@interface PlayerTableViewCell : UITableViewCell

@property (nonatomic, weak, readwrite, nullable) id<PlayerTableViewCellDelegate> delegate;

@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;

@end

@protocol PlayerTableViewCellDelegate <NSObject>
			
@optional
- (void)clickedPlayOnTabCell:(PlayerTableViewCell *)cell;

@end

NS_ASSUME_NONNULL_END
