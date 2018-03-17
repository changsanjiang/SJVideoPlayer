//
//  DownloadTableViewCell.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/16.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class  SJVideo;

@protocol DownloadTableViewCellDelegate;

@interface DownloadTableViewCell : UITableViewCell

@property (nonatomic, weak, readwrite, nullable) id<DownloadTableViewCellDelegate> delegate;

@property (nonatomic, strong) SJVideo *model;

- (void)updateProgress;
- (void)updateStatus;
@end

@protocol DownloadTableViewCellDelegate <NSObject>
			
@optional
- (void)clickedDownloadBtnOnTabCell:(DownloadTableViewCell *)cell;
- (void)clickedPauseBtnOnTabCell:(DownloadTableViewCell *)cell;
- (void)clickedCancelBtnOnTabCell:(DownloadTableViewCell *)cell;
- (void)tabCell:(DownloadTableViewCell *)cell clickedPlayBtnAtCoverImageView:(UIImageView *)coverImageView;
@end
NS_ASSUME_NONNULL_END
