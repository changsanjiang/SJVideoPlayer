//
//  SJVideoPlayerControl.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerControl.h"

#import <AVFoundation/AVPlayer.h>

#import "SJVideoPlayerControlView.h"

#import <AVFoundation/AVPlayerItem.h>

#import <SJSlider/SJSlider.h>

#import <AVFoundation/AVAsset.h>

#import <AVFoundation/AVAssetImageGenerator.h>

#import <AVFoundation/AVTime.h>

/*!
 *  AVPlayerItem's status property
 */
#define STATUS_KEYPATH @"status"

/*!
 *  Refresh interval for timed observations of AVPlayer
 */
#define REFRESH_INTERVAL (0.5)


static const NSString *SJPlayerItemStatusContext;






@interface SJVideoPlayerControl (SJSliderDelegateMethods)<SJSliderDelegate>

@end


@interface SJVideoPlayerControl (SJVideoPlayerControlViewDelegateMethods)<SJVideoPlayerControlViewDelegate>

- (void)play;

- (void)pause;

- (void)replay;

- (void)back;

- (void)full;

- (void)stop;

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL finished))completionHandler;

- (void)jumpedToCMTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler;

@end


@interface SJVideoPlayerControl ()

@property (nonatomic, strong, readonly) SJVideoPlayerControlView *controlView;

@property (nonatomic, strong, readwrite) AVAsset *asset;

@property (nonatomic, strong, readwrite) AVPlayer *player;

@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;

@property (nonatomic, strong, readwrite) id timeObserver;

@property (nonatomic, strong, readwrite) id itemEndObserver;

@property (nonatomic, assign, readwrite) CGFloat lastPlaybackRate;

@end

@implementation SJVideoPlayerControl

@synthesize controlView = _controlView;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self controlView];
    return self;
}

- (void)setAsset:(AVAsset *)asset playerItem:(AVPlayerItem *)playerItem player:(AVPlayer *)player {
    [self _sjResetPlayer];
    
    _asset = asset;
    _playerItem = playerItem;
    _player = player;
    
    [_playerItem addObserver:self forKeyPath:STATUS_KEYPATH options:0 context:&SJPlayerItemStatusContext];
    
    [self generatePreviewImgs];
}


- (void)generatePreviewImgs {
    
    NSMutableArray<NSValue *> *timesM = [NSMutableArray new];
    
    NSInteger second = _asset.duration.value / _asset.duration.timescale;
    short interval = 3;
    __block NSInteger count = second / interval;
    
    for ( int i = 0 ; i < count ; i ++ ) {
        CMTime time = CMTimeMake(i * interval, 1);
        NSValue *tV = [NSValue valueWithCMTime:time];
        if ( tV ) [timesM addObject:tV];
    }
    
    __weak typeof(self) _self = self;
    NSMutableArray <SJVideoPreviewModel *> *imagesM = [NSMutableArray new];
    [[AVAssetImageGenerator assetImageGeneratorWithAsset:_asset] generateCGImagesAsynchronouslyForTimes:timesM completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if ( result == AVAssetImageGeneratorSucceeded ) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            SJVideoPreviewModel *model = [SJVideoPreviewModel previewModelWithImage:image localTime:actualTime];
            if ( model ) [imagesM addObject:model];
        }
        else {
            NSLog(@"ERROR : %@", error);
            NSLog(@"ERROR : %@", error);
            NSLog(@"ERROR : %@", error);
        }
                
        if ( --count == 0 ) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.controlView.previewImages = imagesM;
            });

        }
    }];
}

- (void)_sjResetPlayer {
    NSLog(@"reset Player");
    
    [self.player removeTimeObserver:_timeObserver];
    _timeObserver = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    _itemEndObserver = nil;
    

}

// MARK: Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( context == &SJPlayerItemStatusContext ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH];
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                
                [self addPlayerItemTimeObserver];
                [self addItemEndObserverForPlayerItem];
                
                CMTime duration = self.playerItem.duration;
                
                [self.controlView setCurrentTime:CMTimeGetSeconds(kCMTimeZero) duration:CMTimeGetSeconds(duration)];
                
                [self play];
                
            } else {
                NSLog(@"Failed to load Video: %@", self.playerItem.error);
                NSLog(@"Failed to load Video: %@", self.playerItem.error);
                NSLog(@"Failed to load Video: %@", self.playerItem.error);
            }
        });
    }
}

- (void)addPlayerItemTimeObserver {
    CMTime interval = CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC);
    dispatch_queue_t queue = dispatch_get_main_queue();
    // Create callback block for time observer
    __weak typeof(self) _self = self;
    void (^callback)(CMTime time) = ^(CMTime time) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(self.playerItem.duration);
        [self.controlView setCurrentTime:currentTime duration:duration];
    };
    
    // Add observer and store pointer for future use
    self.timeObserver =
    [self.player addPeriodicTimeObserverForInterval:interval
                                              queue:queue
                                         usingBlock:callback];
}

- (void)addItemEndObserverForPlayerItem {
    
    NSString *name = AVPlayerItemDidPlayToEndTimeNotification;
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    __weak typeof(self) _self = self;
    void (^callback)(NSNotification *note) = ^(NSNotification *notification) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.player seekToTime:kCMTimeZero
              completionHandler:^(BOOL finished) {
                  self.controlView.hiddenReplayBtn = NO;
              }];
        [self pause];
    };
    
    self.itemEndObserver =                                                  // 4
    [[NSNotificationCenter defaultCenter] addObserverForName:name
                                                      object:self.playerItem
                                                       queue:queue
                                                  usingBlock:callback];
}

// MARK: Getter

- (UIView *)view {
    return self.controlView;
}

- (SJVideoPlayerControlView *)controlView {
    if ( _controlView ) return _controlView;
    _controlView = [SJVideoPlayerControlView new];
    _controlView.delegate = self;
    _controlView.sliderControl.delegate = self;
    _controlView.hiddenPlayBtn = YES;
    _controlView.hiddenReplayBtn = YES;
    return _controlView;
}

@end



@implementation SJVideoPlayerControl (SJVideoPlayerControlViewDelegateMethods)

- (void)controlView:(SJVideoPlayerControlView *)controlView selectedPreviewModel:(SJVideoPreviewModel *)model {
    [self jumpedToCMTime:model.localTime completionHandler:^(BOOL finished) {
        if ( self.lastPlaybackRate > 0.f) [self play];
    }];
}

- (void)controlView:(SJVideoPlayerControlView *)controlView clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    switch (tag) {
        case SJVideoPlayControlViewTag_Play:
            [self play];
            break;
        case SJVideoPlayControlViewTag_Pause:
            [self pause];
            break;
        case SJVideoPlayControlViewTag_Replay:
            [self replay];
            break;
        case SJVideoPlayControlViewTag_Back:
            [self back];
            break;
        case SJVideoPlayControlViewTag_Full:
            [self full];
            break;
            
        default:
            break;
    }
}

- (void)play {
    [self.player play];
    self.controlView.hiddenReplayBtn = YES;
    self.controlView.hiddenPlayBtn = YES;
    self.controlView.hiddenPauseBtn = NO;
    self.lastPlaybackRate = self.player.rate;
}

- (void)pause {
    [self.player pause];
    self.controlView.hiddenPlayBtn = NO;
    self.controlView.hiddenPauseBtn = YES;
    self.lastPlaybackRate = self.player.rate;
}

- (void)replay {
    NSLog(@"%zd - %s", __LINE__, __func__);
    [self play];
}

- (void)back {
    NSLog(@"%zd - %s", __LINE__, __func__);
}

- (void)full {
    NSLog(@"%zd - %s", __LINE__, __func__);
}

- (void)stop {
    [self.player setRate:0.0f];
    self.lastPlaybackRate = self.player.rate;
}


- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL finished))completionHandler {
    CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    [self jumpedToCMTime:seekTime completionHandler:completionHandler];
}

- (void)jumpedToCMTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler {
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        if ( completionHandler ) completionHandler(finished);
    }];
}

@end




@implementation SJVideoPlayerControl (SJSliderDelegateMethods)

- (void)sliderWillBeginDragging:(SJSlider *)slider {
    [self.player removeTimeObserver:self.timeObserver];
}

- (void)sliderDidDrag:(SJSlider *)slider {
    [self.playerItem cancelPendingSeeks];
    [self jumpedToTime:slider.value * CMTimeGetSeconds(_playerItem.duration) completionHandler:nil];
}

- (void)sliderDidEndDragging:(SJSlider *)slider {
    [self addPlayerItemTimeObserver];
    if ( self.lastPlaybackRate > 0.f) [self play];
}

@end
