//
//  SJVideoPlayerControl.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerControl.h"

#import "SJVideoPlayerControlView.h"

#import <SJSlider/SJSlider.h>

#import <MediaPlayer/MPVolumeView.h>

#import <AVFoundation/AVFoundation.h>

#import "SJVideoPlayerTipsView.h"

/*!
 *  AVPlayerItem's status property
 */
#define STATUS_KEYPATH @"status"

/*!
 *  Refresh interval for timed observations of AVPlayer
 */
#define REFRESH_INTERVAL (0.5)


typedef NS_ENUM(NSUInteger, SJPanDirection) {
    SJPanDirection_Unknown,
    SJPanDirection_V,
    SJPanDirection_H,
};


typedef NS_ENUM(NSUInteger, SJVerticalPanLocation) {
    SJVerticalPanLocation_Unknown,
    SJVerticalPanLocation_Left,
    SJVerticalPanLocation_Right,
};


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

@property (nonatomic, strong, readonly) UISlider *systemVolume;

@property (nonatomic, strong, readonly) SJVideoPlayerControlView *controlView;

@property (nonatomic, strong, readwrite) AVAsset *asset;

@property (nonatomic, strong, readwrite) AVPlayer *player;

@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;

@property (nonatomic, strong, readwrite) id timeObserver;

@property (nonatomic, strong, readwrite) id itemEndObserver;

@property (nonatomic, assign, readwrite) CGFloat lastPlaybackRate;

@property (nonatomic, strong, readwrite) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong, readwrite) UITapGestureRecognizer *doubleTap;

@property (nonatomic, strong, readwrite) UIPanGestureRecognizer *panGR;

@property (nonatomic, assign, readwrite) SJPanDirection panDirection;

@property (nonatomic, assign, readwrite) SJVerticalPanLocation panLocation;

@property (nonatomic, strong, readonly) SJVideoPlayerTipsView *volumeView;

@property (nonatomic, strong, readonly) SJVideoPlayerTipsView *brightnessView;

@end

@implementation SJVideoPlayerControl

@synthesize systemVolume = _systemVolume;
@synthesize controlView = _controlView;
@synthesize volumeView = _volumeView;
@synthesize brightnessView = _brightnessView;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self controlView];
    [self systemVolume];
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
    
    self.itemEndObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:name
                                                      object:self.playerItem
                                                       queue:queue
                                                  usingBlock:callback];
}

// MARK: Getter

- (UISlider *)systemVolume {
    if ( _systemVolume ) return _systemVolume;
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    [_controlView addSubview:volumeView];
    volumeView.frame = CGRectMake(-1000, -100, 100, 100);
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _systemVolume = (UISlider *)view;
            break;
        }
    }
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error:&setCategoryError];
    if (!success) { /* handle the error in setCategoryError */ }
    return _systemVolume;
}

- (UIView *)view {
    return self.controlView;
}

- (SJVideoPlayerTipsView *)brightnessView {
    if ( _brightnessView ) return _brightnessView;
    _brightnessView = [SJVideoPlayerTipsView new];
    _brightnessView.bounds = CGRectMake(0, 0, 155, 155);
    _brightnessView.center = [UIApplication sharedApplication].keyWindow.center;
    _brightnessView.titleLabel.text = @"亮度";
    _brightnessView.imageView.image = [UIImage imageNamed:@"sj_video_player_brightness"];
    return _brightnessView;
}

- (SJVideoPlayerTipsView *)volumeView {
    if ( _volumeView ) return _volumeView;
    _volumeView = [SJVideoPlayerTipsView new];
    _volumeView.bounds = CGRectMake(0, 0, 155, 155);
    _volumeView.center = [UIApplication sharedApplication].keyWindow.center;
    _volumeView.titleLabel.text = @"音量";
    _volumeView.imageView.image = [UIImage imageNamed:@"sj_video_player_volume"];
    return _volumeView;
}

- (SJVideoPlayerControlView *)controlView {
    if ( _controlView ) return _controlView;
    _controlView = [SJVideoPlayerControlView new];
    _controlView.delegate = self;
    _controlView.sliderControl.delegate = self;
    _controlView.hiddenPlayBtn = YES;
    _controlView.hiddenReplayBtn = YES;
    _controlView.hiddenLockBtn = YES;
    
    // MARK: GestureRecognizer

    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    self.doubleTap.numberOfTapsRequired = 2;
    
    self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    [self.doubleTap requireGestureRecognizerToFail:self.panGR];
    
    [_controlView addGestureRecognizer:self.singleTap];
    [_controlView addGestureRecognizer:self.doubleTap];
    [_controlView addGestureRecognizer:self.panGR];
    
    return _controlView;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    _controlView.hiddenControl = !_controlView.hiddenControl;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    NSLog(@"double tap");
    if ( self.lastPlaybackRate > 0.f )
        [self pause];
    else
        [self play];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint velocityPoint = [pan velocityInView:pan.view];
    
    CGPoint offset = [pan translationInView:pan.view];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(velocityPoint.x);
            CGFloat y = fabs(velocityPoint.y);
            if (x > y) { // 水平移动
                NSLog(@"水平移动");
                _panDirection = SJPanDirection_H;
                [self sliderWillBeginDragging:_controlView.sliderControl];
            }
            else if (x < y){ // 垂直移动
                NSLog(@"垂直移动");
                _panDirection = SJPanDirection_V;
                
                CGPoint locationPoint = [pan locationInView:pan.view];
                if (locationPoint.x > _controlView.bounds.size.width / 2)
                    _panLocation = SJVerticalPanLocation_Right;
                else
                    _panLocation = SJVerticalPanLocation_Left;
                
                [[UIApplication sharedApplication].keyWindow addSubview:self.volumeView];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case SJPanDirection_H:{
                    _controlView.sliderControl.value += offset.x * 0.003;
                    [self sliderDidDrag:_controlView.sliderControl];
                }
                    break;
                case SJPanDirection_V:{
                    // 垂直移动方法只要y方向的值
                    switch (_panLocation) {
                        case SJVerticalPanLocation_Left: {
                            
                        }
                            break;
                        case SJVerticalPanLocation_Right: {
                            _systemVolume.value -= offset.y * 0.006;
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case SJPanDirection_H:{
                    [self sliderDidEndDragging:_controlView.sliderControl];
                    break;
                }
                case SJPanDirection_V:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    
    [pan setTranslation:CGPointZero inView:pan.view];
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
        case SJVideoPlayControlViewTag_Preview:
            break;
        case SJVideoPlayControlViewTag_Lock:
            [self lock];
            break;
        case SJVideoPlayControlViewTag_Unlock:
            [self unlock];
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
    [self play];
}

- (void)back {
    if ( ![self.delegate respondsToSelector:@selector(clickedBackBtnEvent:)] ) return;
    [self.delegate clickedBackBtnEvent:self];
}

- (void)full {
    if ( ![self.delegate respondsToSelector:@selector(clickedFullScreenBtnEvent:)] ) return;
    [self.delegate clickedFullScreenBtnEvent:self];
}

- (void)stop {
    [self.player setRate:0.0f];
    self.lastPlaybackRate = self.player.rate;
}

- (void)lock {
    _controlView.hiddenLockBtn = !_controlView.hiddenLockBtn;
    _controlView.hiddenUnlockBtn = !_controlView.hiddenLockBtn;
    if ( ![self.delegate respondsToSelector:@selector(clickedLockBtnEvent:)] ) return;
    [self.delegate clickedLockBtnEvent:self];
}

- (void)unlock {
    _controlView.hiddenLockBtn = !_controlView.hiddenLockBtn;
    _controlView.hiddenUnlockBtn = !_controlView.hiddenLockBtn;
    if ( ![self.delegate respondsToSelector:@selector(clickedUnlockBtnEvent:)] ) return;
    [self.delegate clickedUnlockBtnEvent:self];
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
