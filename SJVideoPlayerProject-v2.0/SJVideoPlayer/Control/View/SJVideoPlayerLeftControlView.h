//
//  SJVideoPlayerLeftControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SJVideoPlayerLeftControlViewDelegate;

@interface SJVideoPlayerLeftControlView : SJVideoPlayerBaseView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerLeftControlViewDelegate> delegate;
@property (nonatomic, strong, readonly) UIButton *lockBtn;
@property (nonatomic, strong, readonly) UIButton *unlockBtn;

@end

@protocol SJVideoPlayerLeftControlViewDelegate <NSObject>
			
@optional
- (void)leftControlView:(SJVideoPlayerLeftControlView *)view clickedBtnTag:(SJVideoPlayControlViewTag)tag;

@end

NS_ASSUME_NONNULL_END
