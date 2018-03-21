//
//  SJVideoListTableViewCell.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoModel;

@protocol SJVideoListTableViewCellDelegate, NSAttributedStringTappedDelegate;

@interface SJVideoListTableViewCell : UITableViewCell

@property (nonatomic, weak) id<SJVideoListTableViewCellDelegate> delegate;

// cell height
+ (CGFloat)heightWithContentHeight:(CGFloat)contentHeight;

+ (void)sync_makeVideoContent:(void(^)(CGFloat contentMaxWidth, UIFont *font, UIColor *textColor))block;

+ (void)sync_makeNickName:(void (^)(CGFloat contentMaxWidth, UIFont *font, UIColor *textColor))block;

+ (void)sync_makeCreateTime:(void (^)(CGFloat contentMaxWidth, UIFont *font, UIColor *textColor))block;

// data source
@property (nonatomic, strong) SJVideoModel *model;

@end

@protocol SJVideoListTableViewCellDelegate <NSObject>

@optional
- (void)clickedPlayOnTabCell:(SJVideoListTableViewCell *)cell playerParentView:(UIView *)playerParentView;

@end
