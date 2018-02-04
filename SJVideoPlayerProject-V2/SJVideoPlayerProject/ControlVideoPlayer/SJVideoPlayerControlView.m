//
//  SJVideoPlayerControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerControlView.h"
#import "SJVideoPlayerBottomControlView.h"
#import <Masonry/Masonry.h>
#import "SJVideoPlayer.h"
#import <SJObserverHelper/NSObject+SJObserverHelper.h>
#import "SJVideoPlayerSettings.h"
#import "SJVideoPlayer+ControlAdd.h"
#import "SJVideoPlayerDraggingProgressView.h"
#import "UIView+SJVideoPlayerSetting.h"
#import <SJSlider/SJSlider.h>
#import "SJVideoPlayerLeftControlView.h"

@interface SJVideoPlayerControlView ()<SJVideoPlayerControlDelegate, SJVideoPlayerControlDataSource,  SJVideoPlayerLeftControlViewDelegate, SJVideoPlayerBottomControlViewDelegate>

@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong, readonly) SJVideoPlayerDraggingProgressView *draggingProgressView;
@property (nonatomic, strong, readonly) SJVideoPlayerLeftControlView *leftControlView;
@property (nonatomic, strong, readonly) SJVideoPlayerBottomControlView *bottomControlView;
@property (nonatomic, strong, readonly) SJSlider *bottomSlider;

@end

@implementation SJVideoPlayerControlView

@synthesize draggingProgressView = _draggingProgressView;
@synthesize leftControlView = _leftControlView;
@synthesize bottomControlView = _bottomControlView;
@synthesize bottomSlider = _bottomSlider;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _controlViewSetupView];
    [self _controlViewLoadSetting];
    return self;
}

- (void)setVideoPlayer:(SJVideoPlayer *)videoPlayer {
    if ( _videoPlayer == videoPlayer ) return;
    _videoPlayer = videoPlayer;
    _videoPlayer.controlViewDelegate = self;
    _videoPlayer.controlViewDataSource = self;
    [_videoPlayer sj_addObserver:self forKeyPath:@"state"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"state"] ) {
        switch ( _videoPlayer.state ) {
            case SJVideoPlayerPlayState_Prepare: {
            }
                break;
            case SJVideoPlayerPlayState_Paused: {
                self.bottomControlView.playState = NO;
            }
                break;
            case SJVideoPlayerPlayState_Playing: {
                self.bottomControlView.playState = YES;
            }
                break;
            default:
                break;
        }
    }
}


#pragma mark - setup views
- (void)_controlViewSetupView {
    [self addSubview:self.leftControlView];
    [self addSubview:self.bottomControlView];
    [self addSubview:self.draggingProgressView];
    
    [self addSubview:self.bottomSlider];
    
    [_leftControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(0);
        make.centerY.offset(0);
    }];
    
    _leftControlView.transform = CGAffineTransformMakeTranslation(-_leftControlView.intrinsicContentSize.width, 0);
    
    [_bottomControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
    }];
    
    _bottomControlView.transform = CGAffineTransformMakeTranslation(0, _bottomControlView.intrinsicContentSize.height);
    
    [_draggingProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    _draggingProgressView.alpha = 0.001;
    
    
    [_bottomSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(2);
    }];
    
    _bottomSlider.alpha = 0.001;
}

#pragma mark - 拖拽视图
- (SJVideoPlayerDraggingProgressView *)draggingProgressView {
    if ( _draggingProgressView ) return _draggingProgressView;
    _draggingProgressView = [SJVideoPlayerDraggingProgressView new];
    [_draggingProgressView setPreviewImage:[UIImage imageNamed:@"placeholder"]];
    return _draggingProgressView;
}

#pragma mark - 左侧视图
- (SJVideoPlayerLeftControlView *)leftControlView {
    if ( _leftControlView ) return _leftControlView;
    _leftControlView = [SJVideoPlayerLeftControlView new];
    _leftControlView.delegate = self;
    return _leftControlView;
}

- (void)leftControlView:(SJVideoPlayerLeftControlView *)view clickedBtnTag:(SJVideoPlayerLeftViewTag)tag {
    switch ( tag ) {
        case SJVideoPlayerLeftViewTag_Lock: {
            self.videoPlayer.locked = NO;  // 点击锁定按钮, 解锁
        }
            break;
        case SJVideoPlayerLeftViewTag_Unlock: {
            self.videoPlayer.locked = YES; // 点击解锁按钮, 锁定
        }
            break;
    }
}


#pragma mark - 底部视图
- (SJVideoPlayerBottomControlView *)bottomControlView {
    if ( _bottomControlView ) return _bottomControlView;
    _bottomControlView = [SJVideoPlayerBottomControlView new];
    _bottomControlView.delegate = self;
    return _bottomControlView;
}

- (void)bottomView:(SJVideoPlayerBottomControlView *)view clickedBtnTag:(SJVideoPlayerBottomViewTag)tag {
    switch ( tag ) {
        case SJVideoPlayerBottomViewTag_Play: {
            [self.videoPlayer play];
        }
            break;
        case SJVideoPlayerBottomViewTag_Pause: {
            [self.videoPlayer pause];
        }
            break;
        case SJVideoPlayerBottomViewTag_Full: {
            [self.videoPlayer rotation];
        }
            break;
    }
}

- (SJSlider *)bottomSlider {
    if ( _bottomSlider ) return _bottomSlider;
    _bottomSlider = [SJSlider new];
    _bottomSlider.pan.enabled = NO;
    _bottomSlider.trackHeight = 2;
    return _bottomSlider;
}

#pragma mark - 播放器代理方法

- (UIView *)controlView {
    return self;
}

- (BOOL)controlLayerDisplayCondition {
    if ( self.bottomControlView.isDragging ) return NO;
    return self.initialized; // 在初始化期间不显示控制层
}

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer controlLayerNeedChangeDisplayState:(BOOL)displayState locked:(BOOL)isLocked {
    
    self.leftControlView.lockState = isLocked;
    
    [UIView animateWithDuration:0.3 animations:^{
        if ( isLocked ) {
            _leftControlView.transform = CGAffineTransformIdentity;
            _bottomControlView.transform = CGAffineTransformMakeTranslation(0, _bottomControlView.intrinsicContentSize.height);
        }
        else {
            if ( displayState ) {
                _bottomControlView.transform = CGAffineTransformIdentity;
                _leftControlView.transform = CGAffineTransformIdentity;
            }
            else {
                _bottomControlView.transform = CGAffineTransformMakeTranslation(0, _bottomControlView.intrinsicContentSize.height);
                _leftControlView.transform = CGAffineTransformMakeTranslation(-_leftControlView.intrinsicContentSize.width, 0);
            }
        }
        
        if ( displayState ) {
            self.bottomSlider.alpha = 0.001;
        }
        else {
            self.bottomSlider.alpha = 1;
        }
    }];
}

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer currentTimeStr:(NSString *)currentTimeStr totalTimeStr:(NSString *)totalTimeStr {
    [self.bottomControlView setCurrentTimeStr:currentTimeStr totalTimeStr:totalTimeStr];
    self.bottomControlView.progress = videoPlayer.currentTime / videoPlayer.totalTime;
    self.bottomSlider.value = self.bottomControlView.progress;
}

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer loadedTimeProgress:(float)progress {
    self.bottomControlView.bufferProgress = progress;
}

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull {
    if ( isFull && !videoPlayer.URLAsset.isM3u8 ) {
        self.draggingProgressView.style = SJVideoPlayerDraggingProgressViewStylePreviewProgress;
    }
    else {
        self.draggingProgressView.style = SJVideoPlayerDraggingProgressViewStyleArrowProgress;
    }
    
    // update layout
    self.bottomControlView.fullscreen = isFull;
}

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer lockStateDidChange:(BOOL)isLocked {
    self.leftControlView.lockState = isLocked;
}

#pragma mark gesture
- (void)horizontalGestureWillBeginDragging:(SJVideoPlayer *)videoPlayer {
    [UIView animateWithDuration:0.25 animations:^{
       self.draggingProgressView.alpha = 1;
    }];
    
    [self.draggingProgressView setCurrentTimeStr:videoPlayer.currentTimeStr totalTimeStr:videoPlayer.totalTimeStr];
    [self videoPlayer:videoPlayer controlLayerNeedChangeDisplayState:NO locked:self.videoPlayer.locked];
}

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer horizontalGestureDidDrag:(CGFloat)translation {
    self.draggingProgressView.progress += translation;
    [self.draggingProgressView setCurrentTimeStr:[videoPlayer timeStringWithSeconds:self.draggingProgressView.progress * videoPlayer.totalTime]];
    if ( videoPlayer.isFullScreen && !videoPlayer.URLAsset.isM3u8 ) {
        NSTimeInterval secs = self.draggingProgressView.progress * videoPlayer.totalTime;
        __weak typeof(self) _self = self;
        [videoPlayer screenshotWithTime:secs size:CGSizeMake(self.draggingProgressView.frame.size.width * 2, self.draggingProgressView.frame.size.height * 2) completion:^(SJVideoPlayer * _Nonnull videoPlayer, UIImage * _Nullable image, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.draggingProgressView setPreviewImage:image];
        }];
    }
}

- (void)horizontalGestureDidEndDragging:(SJVideoPlayer *)videoPlayer {
    [UIView animateWithDuration:0.25 animations:^{
       self.draggingProgressView.alpha = 0.001;
    }];
    
    [self.videoPlayer jumpedToTime:self.draggingProgressView.progress * videoPlayer.totalTime completionHandler:^(BOOL finished) {
        [videoPlayer play];
    }];
}


#pragma mark - load default setting
- (void)_controlViewLoadSetting {
    
    // load default setting
    __weak typeof(self) _self = self;
    
    // load default setting
//    [SJVideoPlayer loadDefaultSettingAndCompletion:^{
//        __strong typeof(_self) self = _self;
//        if ( !self ) return;
//        self.initialized = YES;
//        [self videoPlayer:self.videoPlayer controlLayerNeedChangeDisplayState:YES];
//    }];
    
    // or update
    [SJVideoPlayer update:^(SJVideoPlayerSettings * _Nonnull commonSettings) {
        // update common settings
        commonSettings.more_trackColor = [UIColor whiteColor];
        commonSettings.progress_trackColor = [UIColor colorWithWhite:0.4 alpha:1];
        commonSettings.progress_bufferColor = [UIColor whiteColor];
    } completion:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.initialized = YES; // 初始化已完成, 在初始化期间不显示控制层.
        [self videoPlayer:self.videoPlayer controlLayerNeedChangeDisplayState:YES locked:self.videoPlayer.locked]; // 显示控制层
    }];
    
    
    self.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJVideoPlayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.bottomSlider.traceImageView.backgroundColor = setting.progress_traceColor;
        self.bottomSlider.trackImageView.backgroundColor = setting.progress_trackColor;
    }];
}
@end
