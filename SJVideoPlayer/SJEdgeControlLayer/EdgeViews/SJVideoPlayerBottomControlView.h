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

@property (nonatomic) BOOL playState;

@property (nonatomic) BOOL fullscreen;

@property (nonatomic) BOOL hiddenFullscreenBtn;

@property (nonatomic) float progress;

@property (nonatomic) float bufferProgress;

- (void)setCurrentTimeStr:(NSString *)currentTimeStr;
- (void)setCurrentTimeStr:(NSString *)currentTimeStr totalTimeStr:(NSString *)totalTimeStr;

@property (nonatomic) BOOL isLoading;

@end

@protocol SJVideoPlayerBottomControlViewDelegate <NSObject>
			
@optional
- (void)bottomView:(SJVideoPlayerBottomControlView *)view clickedBtnTag:(SJVideoPlayerBottomViewTag)tag;

- (void)sliderWillBeginDraggingForBottomView:(SJVideoPlayerBottomControlView *)view;

- (void)bottomView:(SJVideoPlayerBottomControlView *)view sliderDidDrag:(CGFloat)value;

- (void)sliderDidEndDraggingForBottomView:(SJVideoPlayerBottomControlView *)view;
@end

NS_ASSUME_NONNULL_END
