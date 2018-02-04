//
//  SJVideoPlayerControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoPlayer;

NS_ASSUME_NONNULL_BEGIN

@protocol SJVideoPlayerControlViewDelegate;

@interface SJVideoPlayerControlView : UIView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerControlViewDelegate> delegate;
@property (nonatomic, weak, readwrite, nullable) SJVideoPlayer *videoPlayer;

@end

@protocol SJVideoPlayerControlViewDelegate <NSObject>

@required
- (void)clickedBackBtnOnControlView:(SJVideoPlayerControlView *)controlView;

@end

NS_ASSUME_NONNULL_END
