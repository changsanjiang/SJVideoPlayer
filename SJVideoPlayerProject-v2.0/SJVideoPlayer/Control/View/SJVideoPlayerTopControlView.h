//
//  SJVideoPlayerTopControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SJVideoPlayerTopControlViewDelegate;

@interface SJVideoPlayerTopControlView : SJVideoPlayerBaseView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerTopControlViewDelegate> delegate;
@property (nonatomic, strong, readonly) UIButton *backBtn;
@property (nonatomic, strong, readonly) UIButton *previewBtn;
@property (nonatomic, strong, readonly) UIButton *moreBtn;

@end

@protocol SJVideoPlayerTopControlViewDelegate <NSObject>
			
@optional
- (void)topControlView:(SJVideoPlayerTopControlView *)view clickedBtnTag:(SJVideoPlayControlViewTag)tag;

@end

NS_ASSUME_NONNULL_END
