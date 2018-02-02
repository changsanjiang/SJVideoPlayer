//
//  SJVideoPlayer.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayer.h"
#import <SJVideoPlayerAssetCarrier/SJVideoPlayerAssetCarrier.h>
#import "SJVideoPlayerPresentView.h"
#import <Masonry/Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import <SJOrentationObserver/SJOrentationObserver.h>
#import "SJPlayerGestureControl.h"
#import <SJVolBrigControl/SJVolBrigControl.h>
#import "UIView+SJVideoPlayerAdd.h"
#import <objc/message.h>
#import "SJTimerControl.h"
#import <SJObserverHelper/NSObject+SJObserverHelper.h>


NS_ASSUME_NONNULL_BEGIN
@interface _SJVideoPlayerControlDisplayRecorder : NSObject
- (instancetype)initWithVideoPlayer:(SJVideoPlayer *)videoPlayer;
- (void)considerDisplay;
- (void)needDisplay;
- (void)needHidden;
@end
NS_ASSUME_NONNULL_END


#pragma mark -

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayer () {
    UIView *_view;
    SJVideoPlayerPresentView *_presentView;
    UIView *_controlContentView;
    SJOrentationObserver *_orentationObserver;
    SJPlayerGestureControl *_gestureControl;
    SJVolBrigControl *_volBrigControl;
    _SJVideoPlayerControlDisplayRecorder *_displayRecorder;
}

@property (nonatomic, assign, readwrite) SJVideoPlayerPlayState state;
@property (nonatomic, strong, readwrite, nullable) NSError *error;
@property (nonatomic, strong, readwrite, nullable) SJVideoPlayerAssetCarrier *asset;

@property (nonatomic, strong, readonly) UIView *controlContentView;
@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;
@property (nonatomic, strong, readonly) SJOrentationObserver *orentationObserver;
@property (nonatomic, strong, readonly) SJPlayerGestureControl *gestureControl;
@property (nonatomic, strong, readonly) SJVolBrigControl *volBrigControl;
@property (nonatomic, strong, readonly) _SJVideoPlayerControlDisplayRecorder *displayRecorder;

- (void)clear;

@end
NS_ASSUME_NONNULL_END

@implementation SJVideoPlayer

+ (instancetype)player {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    self.autoPlay = YES;
    return self;
}

#pragma mark -

- (void)setURLAsset:(SJVideoPlayerURLAsset *)URLAsset {
    _URLAsset = URLAsset;
    self.asset = [URLAsset valueForKey:kSJVideoPlayerAssetKey];
    self.presentView.asset = self.asset;
    [self _itemPrepareToPlay];
}

- (void)setControlViewDelegate:(id<SJVideoPlayerControlViewDelegate>)controlViewDelegate {
    if ( controlViewDelegate == _controlViewDelegate ) return;
    [_controlViewDelegate.controlView removeFromSuperview];
    
    _controlViewDelegate = controlViewDelegate;
    
    [self.controlContentView addSubview:_controlViewDelegate.controlView];
    [_controlViewDelegate.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

#pragma mark -
- (void)_itemPrepareToPlay {
    __weak typeof(self) _self = self;
    self.asset.playerItemStateChanged = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, AVPlayerItemStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch ( status ) {
            case AVPlayerItemStatusUnknown:  break;
            case  AVPlayerItemStatusFailed: {
                [self _itemPlayFailed];
            }
                break;
            case AVPlayerItemStatusReadyToPlay: {
                [self _itemReadyToPlay];
            }
                break;
        }
    };
    
    self.state = SJVideoPlayerPlayState_Prepare;
}

- (void)_itemPlayFailed {
    self.error = self.asset.playerItem.error;
    
    self.state = SJVideoPlayerPlayState_PlayFailed;
}

- (void)_itemReadyToPlay {
    if ( !self.autoPlay ) return;
    
    [self play];
    [self.displayRecorder needDisplay];
}

#pragma mark -
- (UIView *)view {
    if ( _view ) return _view;
    _view = [SJUIViewFactory viewWithBackgroundColor:[UIColor blackColor]];
    [_view addSubview:self.presentView];
    [self.presentView addSubview:self.controlContentView];
    
    [self.presentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [self.controlContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [self orentationObserver];
    [self gestureControl];
    return _view;
}

- (SJVideoPlayerPresentView *)presentView {
    if ( _presentView ) return _presentView;
    _presentView = [SJVideoPlayerPresentView new];
    return _presentView;
}

- (UIView *)controlContentView {
    if ( _controlContentView ) return _controlContentView;
    _controlContentView = [UIControl new];
    _controlContentView.clipsToBounds = YES;
    return _controlContentView;
}

#pragma mark -
- (SJOrentationObserver *)orentationObserver {
    if ( _orentationObserver ) return _orentationObserver;
    _orentationObserver = [[SJOrentationObserver alloc] initWithTarget:self.presentView container:self.view];
    
    __weak typeof(self) _self = self;
    
    _orentationObserver.rotationCondition = ^BOOL(SJOrentationObserver * _Nonnull observer) {
        return YES;
    };
    
    _orentationObserver.orientationWillChange = ^(SJOrentationObserver * _Nonnull observer, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.displayRecorder needHidden];
    };
    
    return _orentationObserver;
}
- (SJPlayerGestureControl *)gestureControl {
    if ( _gestureControl ) return _gestureControl;
    _gestureControl = [[SJPlayerGestureControl alloc] initWithTargetView:self.controlContentView];
    __weak typeof(self) _self = self;
    _gestureControl.triggerCondition = ^BOOL(SJPlayerGestureControl * _Nonnull control, SJPlayerGestureType type, UIGestureRecognizer * _Nonnull gesture) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        if ( SJVideoPlayerPlayState_Unknown == self.state ||
             SJVideoPlayerPlayState_Prepare == self.state ||
             SJVideoPlayerPlayState_PlayFailed == self.state ) return NO;
        return YES;
    };
    
    _gestureControl.singleTapped = ^(SJPlayerGestureControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.displayRecorder considerDisplay];
    };
    
    _gestureControl.doubleTapped = ^(SJPlayerGestureControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( SJVideoPlayerPlayState_Paused == self.state ) [self play];
        else if ( SJVideoPlayerPlayState_PlayEnd == self.state ) [self replay];
        else [self pause];
    };
    
    _gestureControl.beganPan = ^(SJPlayerGestureControl * _Nonnull control, SJPanDirection direction, SJPanLocation location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch (direction) {
            case SJPanDirection_H: {
                
            }
                break;
            case SJPanDirection_V: {
                switch (location) {
                    case SJPanLocation_Right: break;
                    case SJPanLocation_Left: {
                        self.volBrigControl.brightnessView.transform = self.presentView.transform;
                        [[UIApplication sharedApplication].keyWindow addSubview:self.volBrigControl.brightnessView];
                        [self.volBrigControl.brightnessView sj_fadeIn];
                        [self.volBrigControl.brightnessView mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.size.mas_offset(CGSizeMake(155, 155));
                            make.center.equalTo([UIApplication sharedApplication].keyWindow);
                        }];
                    }
                        break;
                    case SJPanLocation_Unknown: break;
                }
            }
                break;
            case SJPanDirection_Unknown:
                break;
        }
    };
    
    _gestureControl.changedPan = ^(SJPlayerGestureControl * _Nonnull control, SJPanDirection direction, SJPanLocation location, CGPoint translate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch (direction) {
            case SJPanDirection_H: {
                
            }
                break;
            case SJPanDirection_V: {
                switch (location) {
                    case SJPanLocation_Left: {
                        CGFloat value = self.volBrigControl.brightness - translate.y * 0.006;
                        if ( value < 1.0 / 16 ) value = 1.0 / 16;
                        self.volBrigControl.brightness = value;
                    }
                        break;
                    case SJPanLocation_Right: {
                        CGFloat value = translate.y * 0.008;
                        self.volBrigControl.volume -= value;
                    }
                        break;
                    case SJPanLocation_Unknown: break;
                }
            }
                break;
            default:
                break;
        }
    };
    
    _gestureControl.endedPan = ^(SJPlayerGestureControl * _Nonnull control, SJPanDirection direction, SJPanLocation location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch ( direction ) {
            case SJPanDirection_H:{
                
            }
                break;
            case SJPanDirection_V:{
                if ( location == SJPanLocation_Left ) [self.volBrigControl.brightnessView sj_fadeOut];
            }
                break;
            case SJPanDirection_Unknown: break;
        }
    };
    
    _gestureControl.pinched = ^(SJPlayerGestureControl * _Nonnull control, float scale) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( scale > 1 ) {
            self.presentView.videoGravity = AVLayerVideoGravityResizeAspectFill;
        }
        else {
            self.presentView.videoGravity = AVLayerVideoGravityResizeAspect;
        }
    };
    return _gestureControl;
}
- (SJVolBrigControl *)volBrigControl {
    if ( _volBrigControl ) return _volBrigControl;
    _volBrigControl = [[SJVolBrigControl alloc] init];
    return _volBrigControl;
}
- (_SJVideoPlayerControlDisplayRecorder *)displayRecorder {
    if ( _displayRecorder ) return _displayRecorder;
    _displayRecorder = [[_SJVideoPlayerControlDisplayRecorder alloc] initWithVideoPlayer:self];
    return _displayRecorder;
}

#pragma mark -
- (void)setState:(SJVideoPlayerPlayState)state {
    _state = state;
    switch ( state ) {
        case SJVideoPlayerPlayState_Unknown: {
            NSLog(@"状态: 未知");
        }
            break;
        case SJVideoPlayerPlayState_Playing: {
            NSLog(@"状态: 播放");
        }
            break;
        case SJVideoPlayerPlayState_PlayFailed: {
            NSLog(@"状态: 失败");
        }
            break;
        case SJVideoPlayerPlayState_Prepare: {
            NSLog(@"状态: 准备");
        }
            break;
        case SJVideoPlayerPlayState_Paused: {
            NSLog(@"状态: 暂停");
        }
            break;
        case SJVideoPlayerPlayState_Buffing: {
            NSLog(@"状态: 缓冲");
        }
            break;
        case SJVideoPlayerPlayState_PlayEnd: {
            NSLog(@"状态: 完毕");
        }
            break;
        default:
            break;
    }
}

- (void)clear {
    self.asset = nil;
}
@end


#pragma mark - 控制

@implementation SJVideoPlayer (Control)

- (void)setAutoPlay:(BOOL)autoPlay {
    objc_setAssociatedObject(self, @selector(isAutoPlay), @(autoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAutoPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)play {
    if ( !self.asset ) return NO;
    [self.asset.player play];
    self.state = SJVideoPlayerPlayState_Playing;
    return YES;
}

- (BOOL)pause {
    if ( !self.asset ) return NO;
    [self.asset.player pause];
    self.state = SJVideoPlayerPlayState_Paused;
    return YES;
}

- (void)stop {
    if ( !self.asset ) return;
    
    [self clear];
    self.state = SJVideoPlayerPlayState_Unknown;
}

- (void)replay {
    if ( !self.asset ) return;
    [self pause];
    __weak typeof(self) _self = self;
    [self jumpedToTime:0 completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self play];
    }];
}

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    if ( isnan(time) ) { return;}
    CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    __weak typeof(self) _self = self;
    [self.asset seekToTime:seekTime completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completionHandler ) completionHandler(finished);
    }];
}
@end


#pragma mark -

NS_ASSUME_NONNULL_BEGIN
@interface _SJVideoPlayerControlDisplayRecorder ()
@property (nonatomic) BOOL displayStatus;
@property (nonatomic, weak, readonly) SJVideoPlayer *videoPlayer;
@property (nonatomic, strong, readonly) SJTimerControl *timerControl;
@property (nonatomic, assign, readonly) BOOL imped;
@end
NS_ASSUME_NONNULL_END

@implementation _SJVideoPlayerControlDisplayRecorder
@synthesize timerControl = _timerControl;
@synthesize imped = _imped;

- (instancetype)initWithVideoPlayer:(SJVideoPlayer *)videoPlayer {
    self = [super init];
    if ( !self ) return nil;
    _videoPlayer = videoPlayer;
    [_videoPlayer sj_addObserver:self forKeyPath:@"state"];
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if      ( SJVideoPlayerPlayState_Paused == self.videoPlayer.state ) {
        [self.timerControl clear];
        [self _callDelegateMethodWithStatus:_displayStatus = YES];
    }
    else if ( SJVideoPlayerPlayState_Playing == self.videoPlayer.state &&
              self.displayStatus) {
        [self.timerControl start];
    }
}

- (void)considerDisplay {
    if ( self.displayStatus ) [self needHidden];
    else [self needDisplay];
}

- (void)needDisplay {
    [self.timerControl start];
    _displayStatus = YES;
    [self _callDelegateMethodWithStatus:YES];
}

- (void)needHidden {
    [self.timerControl clear];
    _displayStatus = NO;
    [self _callDelegateMethodWithStatus:NO];
}

- (SJTimerControl *)timerControl {
    if ( _timerControl ) return _timerControl;
    _timerControl = [[SJTimerControl alloc] init];
    __weak typeof(self) _self = self;
    _timerControl.exeBlock = ^(SJTimerControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.displayStatus ) [self needHidden];
        else [control clear];
    };
    return _timerControl;
}

#pragma mark -
- (void)_callDelegateMethodWithStatus:(BOOL)status {
    if ( self.imped ) [self.videoPlayer.controlViewDelegate videoPlayer:self.videoPlayer needChangeControlLayerDisplayStatus:status];
}

- (BOOL)imped {
    if ( _imped ) return _imped;
    _imped = [self.videoPlayer.controlViewDelegate respondsToSelector:@selector(videoPlayer:needChangeControlLayerDisplayStatus:)];
    return _imped;
}
@end
