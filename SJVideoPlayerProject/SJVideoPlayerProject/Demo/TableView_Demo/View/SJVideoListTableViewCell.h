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

typedef void(^SJTextAppearance)(CGFloat maxWidth, UIFont *font, UIColor *textColor);

@interface SJVideoListTableViewCell : UITableViewCell

+ (CGFloat)heightWithContentHeight:(CGFloat)contentHeight;

+ (void)sync_makeVideoContent:(SJTextAppearance)block;

+ (void)sync_makeNickname:(SJTextAppearance)block;

+ (void)sync_makeCreateTime:(SJTextAppearance)block;

@property (nonatomic, strong, nullable) SJVideoModel *model;
@property (nonatomic, weak, nullable) id<SJVideoListTableViewCellDelegate> delegate;

@end


@protocol SJVideoListTableViewCellDelegate <NSObject>
@optional
- (void)clickedPlayOnTabCell:(SJVideoListTableViewCell *)cell playerParentView:(UIView *)playerParentView;
@end
NS_ASSUME_NONNULL_END
