//
//  SJVideoPlayerControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import "SJVideoPlayer+SJControlAdd.h"

@class SJVideoPlayer;

NS_ASSUME_NONNULL_BEGIN

@protocol SJVideoPlayerControlViewDelegate;

@interface SJVideoPlayerControlView : UIView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerControlViewDelegate> delegate;

@property (nonatomic, weak, readwrite, nullable) SJVideoPlayer *videoPlayer;

@property (nonatomic, assign, readwrite) BOOL generatePreviewImages; // 是否自动生成预览视图, 默认是 YES. 如果为NO, 则预览按钮将不会显示.

@end

@protocol SJVideoPlayerControlViewDelegate <NSObject>

@required
- (void)clickedBackBtnOnControlView:(SJVideoPlayerControlView *)controlView;

@end

NS_ASSUME_NONNULL_END
