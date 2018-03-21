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

typedef void(^SJTextAppearance)(CGFloat maxWidth, UIFont *font, UIColor *textColor);

@interface LightweightTableViewCell : UITableViewCell

+ (CGFloat)heightWithContentHeight:(CGFloat)contentHeight;

+ (void)sync_makeVideoContent:(SJTextAppearance)block;

+ (void)sync_makeNickname:(SJTextAppearance)block;

+ (void)sync_makeCreateTime:(SJTextAppearance)block;

@property (nonatomic, strong, nullable) SJVideoModel *model;
@property (nonatomic, weak, nullable) id<LightweightTableViewCellDelegate> delegate;

@end


@protocol LightweightTableViewCellDelegate <NSObject>
@optional
- (void)clickedPlayOnTabCell:(LightweightTableViewCell *)cell playerParentView:(UIView *)playerParentView;
@end
NS_ASSUME_NONNULL_END

