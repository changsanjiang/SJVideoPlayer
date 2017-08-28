//
//  VideoPlayerTableViewCell.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/28.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideoPlayerTableViewCellDelegate;


@interface VideoPlayerTableViewCell : UITableViewCell

@property (nonatomic, strong, readonly) UIImageView *videoImageView;

@property (nonatomic, weak, readwrite) id <VideoPlayerTableViewCellDelegate> delegate;

@end

@protocol VideoPlayerTableViewCellDelegate <NSObject>

- (void)clickedPlayBtnOnTheCell:(VideoPlayerTableViewCell *)cell;

@end
