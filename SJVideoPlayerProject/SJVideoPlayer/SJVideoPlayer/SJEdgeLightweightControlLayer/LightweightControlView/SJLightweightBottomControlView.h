//
//  SJLightweightBottomControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, SJLightweightBottomControlViewTag) {
    SJLightweightBottomControlViewTag_Play,
    SJLightweightBottomControlViewTag_Pause,
    SJLightweightBottomControlViewTag_Full,
};

@protocol SJLightweightBottomControlViewDelegate;

@interface SJLightweightBottomControlView : UIView

@property (nonatomic, weak, readwrite, nullable) id<SJLightweightBottomControlViewDelegate> delegate;

@property (nonatomic) BOOL hiddenFullscreenBtn;

@property (nonatomic) float bufferProgress;

@property (nonatomic) float progress;

@property (nonatomic) BOOL isFullscreen;

@property (nonatomic) BOOL isFitOnScreen;

/// 显示播放按钮还是显示暂停按钮
/// - YES显示暂停
/// - NO显示播放
@property (nonatomic, getter=isStopped) BOOL stopped;

- (void)setCurrentTimeStr:(NSString *)currentTimeStr;
- (void)setCurrentTimeStr:(NSString *)currentTimeStr totalTimeStr:(NSString *)totalTimeStr;

@end

@protocol SJLightweightBottomControlViewDelegate <NSObject>
			
@optional
- (void)bottomControlView:(SJLightweightBottomControlView *)bottomControlView clickedViewTag:(SJLightweightBottomControlViewTag)tag;

- (void)sliderWillBeginDraggingForBottomView:(SJLightweightBottomControlView *)view;

- (void)bottomView:(SJLightweightBottomControlView *)view sliderDidDrag:(CGFloat)value;

- (void)sliderDidEndDraggingForBottomView:(SJLightweightBottomControlView *)view;

@end
NS_ASSUME_NONNULL_END
