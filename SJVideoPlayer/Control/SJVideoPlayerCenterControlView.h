//
//  SJVideoPlayerCenterControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SJVideoPlayerCenterControlViewDelegate;

@interface SJVideoPlayerCenterControlView : SJVideoPlayerBaseView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerCenterControlViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIButton *failedBtn;
@property (nonatomic, strong, readonly) UIButton *replayBtn;

@end

@protocol SJVideoPlayerCenterControlViewDelegate <NSObject>
			
@optional
- (void)centerControlView:(SJVideoPlayerCenterControlView *)view clickedBtnTag:(SJVideoPlayControlViewTag)tag;

@end

NS_ASSUME_NONNULL_END
