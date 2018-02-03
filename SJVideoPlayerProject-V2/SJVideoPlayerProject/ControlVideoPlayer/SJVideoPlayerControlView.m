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

@interface SJVideoPlayerControlView ()<SJVideoPlayerControlDelegate, SJVideoPlayerControlDataSource, SJVideoPlayerBottomControlViewDelegate>

@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong, readonly) SJVideoPlayerBottomControlView *bottomControlView;

@end

@implementation SJVideoPlayerControlView

@synthesize bottomControlView = _bottomControlView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _controlViewSetupView];
    
    __weak typeof(self) _self = self;
    [SJVideoPlayer setting:^(SJVideoPlayerSettings * _Nonnull commonSettings) {} completion:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.initialized = YES;
        [self videoPlayer:self.videoPlayer controlLayerNeedChangeDisplayState:YES];
    }];
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


#pragma mark -
- (void)_controlViewSetupView {
    [self addSubview:self.bottomControlView];
    [_bottomControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(49);
    }];
    
    _bottomControlView.transform = CGAffineTransformMakeTranslation(0, 49);
}



#pragma mark bottom control view
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
        default:
            break;
    }
}

#pragma mark -

- (UIView *)controlView {
    return self;
}

- (BOOL)controlLayerDisplayCondition {
    if ( self.bottomControlView.isDragging ) return NO;
    return self.initialized;
}

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer controlLayerNeedChangeDisplayState:(BOOL)displayState {
    [UIView animateWithDuration:0.3 animations:^{
        if ( displayState ) {
            _bottomControlView.transform = CGAffineTransformIdentity;
        }
        else {
            _bottomControlView.transform = CGAffineTransformMakeTranslation(0, 49);
        }
    }];
}

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer currentTimeStr:(NSString *)currentTimeStr totalTimeStr:(NSString *)totalTimeStr {
    [self.bottomControlView setCurrentTimeStr:currentTimeStr totalTimeStr:totalTimeStr];
}

@end
