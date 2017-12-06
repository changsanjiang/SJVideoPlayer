//
//  SJVideoPlayerControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerBaseView.h"
#import "SJVideoPlayerControlViewEnumHeader.h"
#import "SJVideoPlayerTopControlView.h"
#import "SJVideoPlayerLeftControlView.h"
#import "SJVideoPlayerBottomControlView.h"
#import "SJVideoPlayerCenterControlView.h"
#import "SJVideoPlayerPreviewView.h"
#import "SJVideoPlayerTipsView.h"
#import "SJVideoPlayerDraggingProgressView.h"


NS_ASSUME_NONNULL_BEGIN

@class SJVideoPreviewModel, SJVideoPlayerAssetCarrier;

@protocol SJVideoPlayerControlViewDelegate;

@interface SJVideoPlayerControlView : SJVideoPlayerBaseView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerControlViewDelegate> delegate;
@property (nonatomic, weak, readwrite, nullable) SJVideoPlayerAssetCarrier *asset;

@property (nonatomic, strong, readonly) SJVideoPlayerTopControlView *topControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerPreviewView *previewView;
@property (nonatomic, strong, readonly) SJVideoPlayerLeftControlView *leftControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerCenterControlView *centerControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerBottomControlView *bottomControlView;
@property (nonatomic, strong, readonly) SJSlider *bottomProgressSlider;
@property (nonatomic, strong, readonly) SJVideoPlayerDraggingProgressView *draggingProgressView;

@property (nonatomic, strong, readonly) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGR;

@end

@protocol SJVideoPlayerControlViewDelegate <NSObject>
			
@optional
- (void)controlView:(SJVideoPlayerControlView *)controlView clickedBtnTag:(SJVideoPlayControlViewTag)tag;
- (void)controlView:(SJVideoPlayerControlView *)controlView didSelectPreviewItem:(SJVideoPreviewModel *)item;
- (void)controlView:(SJVideoPlayerControlView *)controlView handleSingleTap:(UITapGestureRecognizer *)tap;
- (void)controlView:(SJVideoPlayerControlView *)controlView handleDoubleTap:(UITapGestureRecognizer *)tap;
- (void)controlView:(SJVideoPlayerControlView *)controlView handlePan:(UIPanGestureRecognizer *)pan;

@end

NS_ASSUME_NONNULL_END
