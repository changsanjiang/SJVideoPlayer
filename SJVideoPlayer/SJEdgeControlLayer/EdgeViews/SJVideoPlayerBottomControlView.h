//
//  SJVideoPlayerBottomControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJVideoPlayerBottomViewTag) {
    SJVideoPlayerBottomViewTag_Play,
    SJVideoPlayerBottomViewTag_Pause,
    SJVideoPlayerBottomViewTag_Full,
};

@protocol SJVideoPlayerBottomControlViewDelegate;

@interface SJVideoPlayerBottomControlView : UIView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerBottomControlViewDelegate> delegate;

@property (nonatomic) BOOL hiddenFullscreenBtn;

@property (nonatomic) float bufferProgress;

@property (nonatomic) float progress;

@property (nonatomic) BOOL isFitOnScreen;

@property (nonatomic) BOOL isFullscreen;

@property (nonatomic) BOOL isLoading;

@property (nonatomic) BOOL playState;

- (void)setCurrentTimeStr:(NSString *)currentTimeStr;
- (void)setCurrentTimeStr:(NSString *)currentTimeStr totalTimeStr:(NSString *)totalTimeStr;

@end

@protocol SJVideoPlayerBottomControlViewDelegate <NSObject>
			
@optional
- (void)bottomView:(SJVideoPlayerBottomControlView *)view clickedBtnTag:(SJVideoPlayerBottomViewTag)tag;

- (void)sliderWillBeginDraggingForBottomView:(SJVideoPlayerBottomControlView *)view;

- (void)bottomView:(SJVideoPlayerBottomControlView *)view sliderDidDrag:(CGFloat)value;

- (void)sliderDidEndDraggingForBottomView:(SJVideoPlayerBottomControlView *)view;
@end

NS_ASSUME_NONNULL_END
