//
//  SimplifiedSampleTableViewCell.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/7/10.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SimplifiedSampleTableViewCellDelegate;

@interface SimplifiedSampleTableViewCell : UITableViewCell

+ (CGFloat)height;

@property (nonatomic, weak, readwrite, nullable) id<SimplifiedSampleTableViewCellDelegate> delegate;
@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;
@property (nonatomic, strong, readonly) UIImageView *playImageView;
@end

@protocol SimplifiedSampleTableViewCellDelegate <NSObject>
			
@optional
- (void)clickedPlayButtonOnTheTabCell:(SimplifiedSampleTableViewCell *)cell;

@end
NS_ASSUME_NONNULL_END
