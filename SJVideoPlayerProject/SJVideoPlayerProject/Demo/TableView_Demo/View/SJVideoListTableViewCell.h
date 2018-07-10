//
//  SJVideoListTableViewCell.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SJVideoModel;
@protocol SJVideoListTableViewCellDelegate, NSAttributedStringTappedDelegate;

@interface SJVideoListTableViewCell : UITableViewCell

+ (void)sync_makeContentWithVideo:(SJVideoModel *)model tappedDelegate:(id<NSAttributedStringTappedDelegate>)tappedDelegate;
+ (CGFloat)heightWithVideo:(SJVideoModel *)video;

@property (nonatomic, strong, nullable) SJVideoModel *model;
@property (nonatomic, weak, nullable) id<SJVideoListTableViewCellDelegate> delegate;
@property (nonatomic, strong, readonly) UIImageView *coverImageView;

@end


@protocol SJVideoListTableViewCellDelegate <NSObject>
@optional
- (void)clickedPlayOnTabCell:(SJVideoListTableViewCell *)cell playerParentView:(UIView *)playerParentView;
@end
NS_ASSUME_NONNULL_END
