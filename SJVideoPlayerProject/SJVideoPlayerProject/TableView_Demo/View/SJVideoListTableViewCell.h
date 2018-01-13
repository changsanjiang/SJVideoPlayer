//
//  SJVideoListTableViewCell.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoModel, SJVideoHelper;

@protocol SJVideoListTableViewCellDelegate;

@interface SJVideoListTableViewCell : UITableViewCell

@property (nonatomic, weak) id<SJVideoListTableViewCellDelegate> delegate;

// cell height
+ (CGFloat)heightWithContentHeight:(CGFloat)contentHeight;

// helpers
+ (SJVideoHelper *)helperWithCreateTime:(NSTimeInterval)createTime;
+ (SJVideoHelper *)helperWithNickname:(NSString *)nickname;
+ (SJVideoHelper *)helperWithContent:(NSString *)content;

// data source
@property (nonatomic, strong) SJVideoModel *model;

@end

@protocol SJVideoListTableViewCellDelegate <NSObject>

@optional
- (void)clickedPlayOnTabCell:(SJVideoListTableViewCell *)cell playerParentView:(UIView *)playerParentView;

@end
