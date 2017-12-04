//
//  SJVideoPlayerBottomControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerBaseView.h"
#import <SJSlider/SJSlider.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SJVideoPlayerBottomControlViewDelegate;

@interface SJVideoPlayerBottomControlView : SJVideoPlayerBaseView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerBottomControlViewDelegate> delegate;
@property (nonatomic, strong, readonly) UIButton *playBtn;
@property (nonatomic, strong, readonly) UIButton *pauseBtn;
@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;
@property (nonatomic, strong, readonly) UILabel *separateLabel;
@property (nonatomic, strong, readonly) UILabel *durationTimeLabel;
@property (nonatomic, strong, readonly) SJSlider *progressSlider;
@property (nonatomic, strong, readonly) UIButton *fullBtn;

@end

@protocol SJVideoPlayerBottomControlViewDelegate <NSObject>
			
@optional
- (void)bottomControlView:(SJVideoPlayerBottomControlView *)view clickedBtnTag:(SJVideoPlayControlViewTag)tag;

@end

NS_ASSUME_NONNULL_END
