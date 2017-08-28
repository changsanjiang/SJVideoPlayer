//
//  VideoPlayerCollectionViewCell.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/28.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h> 

@protocol VideoPlayerCollectionViewCellDelegate;


@interface VideoPlayerCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *videoImageView;

@property (nonatomic, weak, readwrite) id <VideoPlayerCollectionViewCellDelegate> delegate;

@end

@protocol VideoPlayerCollectionViewCellDelegate <NSObject>

- (void)clickedPlayBtnOnTheCell:(VideoPlayerCollectionViewCell *)cell onViewTag:(NSInteger)tag;

@end
