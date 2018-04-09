//
//  LightweightTableViewCell.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SJVideoModel;
@protocol LightweightTableViewCellDelegate, NSAttributedStringTappedDelegate;

@interface LightweightTableViewCell : UITableViewCell

+ (void)sync_makeContentWithVideo:(SJVideoModel *)model tappedDelegate:(id<NSAttributedStringTappedDelegate>)tappedDelegate;
+ (CGFloat)heightWithVideo:(SJVideoModel *)video;


@property (nonatomic, strong, nullable) SJVideoModel *model;
@property (nonatomic, weak, nullable) id<LightweightTableViewCellDelegate> delegate;

@end


@protocol LightweightTableViewCellDelegate <NSObject>
@optional
- (void)clickedPlayOnTabCell:(LightweightTableViewCell *)cell playerParentView:(UIView *)playerParentView;
@end
NS_ASSUME_NONNULL_END

