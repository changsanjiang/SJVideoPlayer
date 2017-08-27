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

#import "SJVideoPlayer.h"

#import "SJVideoPlayerStringConstant.h"

#import "NSTimer+SJExtention.h"

#import "SJVideoPlayer.h"


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



@interface SJVideoPlayerBackstageStatusRegistrar : NSObject

- (void)registrar:(SJVideoPlayerControlView *)controlView;

@property (nonatomic, assign, readwrite) BOOL hiddenLockBtn;

@property (nonatomic, assign, readwrite) BOOL hiddenPlayBtn;

@property (nonatomic, assign, readwrite) BOOL isLock;

@property (nonatomic, assign, readwrite) BOOL isHiddenControl;

/*!
 *  player play status
 */
@property (nonatomic, assign, readwrite) BOOL isPlaying;

@property (nonatomic, assign, readwrite) BOOL isPlayEnded;

@end





// MARK: 通知处理

@interface SJVideoPlayerControl (DBNotifications)

- (void)_SJVideoPlayerControlInstallNotifications;

- (void)_SJVideoPlayerControlRemoveNotifications;

@end



@interface SJVideoPlayerControl (SJSliderDelegateMethods)<SJSliderDelegate>

@end


@interface SJVideoPlayerControl (SJVideoPlayerControlViewDelegateMethods)<SJVideoPlayerControlViewDelegate>

- (void)clickedPlay;

- (void)clickedPause;

- (void)clickedReplay;

- (void)clickedBack;

- (void)clickedFull;

- (void)clickedStop;

- (void)clickedLoadFailed;

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

@property (nonatomic, strong, readonly) SJVideoPlayerBackstageStatusRegistrar *backstageRegistrar;

@property (nonatomic, assign, readwrite) NSTimeInterval playedTime;

@property (nonatomic, assign, readwrite) BOOL isUserClickedPause;

@property (nonatomic, strong, readwrite) AVAssetImageGenerator *imageGenerator;

@property (nonatomic, assign, readwrite) BOOL isHiddenControl;
@property (nonatomic, assign, readwrite) NSInteger hiddenControlPoint;
@property (nonatomic, strong, readonly) NSTimer *pointTimer;

@end

@implementation SJVideoPlayerControl

@synthesize systemVolume = _systemVolume;
@synthesize controlView = _controlView;
@synthesize volumeView = _volumeView;
@synthesize brightnessView = _brightnessView;
@synthesize backstageRegistrar = _backstageRegistrar;
@synthesize pointTimer = _pointTimer;
@synthesize rate = _rate;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self controlView];
    [self systemVolume];
    [[UIApplication sharedApplication].keyWindow addSubview:self.volumeView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.brightnessView];
    self.volumeView.alpha = 0.001;
    self.brightnessView.alpha = 0.001;
    [self _SJVideoPlayerControlInstallNotifications];
    [self pointTimer];
    [self addOtherObservers];
    return self;
}

- (void)dealloc {
    [self removeOtherObservers];
    [self _SJVideoPlayerControlRemoveNotifications];
}


- (void)addOtherObservers {
    [self.controlView addObserver:self forKeyPath:@"hiddenControl" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"hiddenControlPoint" options:NSKeyValueObservingOptionNew context:nil];
    [self.controlView addObserver:self forKeyPath:@"hiddenPreview" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeOtherObservers {
    [self.controlView removeObserver:self forKeyPath:@"hiddenControl"];
    [self.controlView removeObserver:self forKeyPath:@"hiddenPreview"];
    [self addObserver:self forKeyPath:@"hiddenControlPoint" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setAsset:(AVAsset *)asset playerItem:(AVPlayerItem *)playerItem player:(AVPlayer *)player {
    [self sjReset];
    
    self.asset = asset;
    self.playerItem = playerItem;
    self.player = player;
}

// MARK: Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ( [keyPath isEqualToString:@"hiddenControl"] ) {
        if ( _controlView.hiddenControl ) {
            _controlView.hiddenPreview = YES;
            [_pointTimer invalidate];
            _pointTimer = nil;
            _controlView.hiddenLockContainerView = !self.backstageRegistrar.isLock;
        }
        else {
            _hiddenControlPoint = 0;
            [self.pointTimer fire];
            _controlView.hiddenLockContainerView = NO;
        }
        _controlView.hiddenBottomProgressView = !_controlView.hiddenControl;
        return;
    }
    
    if ( [keyPath isEqualToString:@"hiddenControlPoint"] ) {
        if ( _hiddenControlPoint >= SJHiddenControlInterval ) {
            _controlView.hiddenControl = YES;
            [_pointTimer invalidate];
            _pointTimer = nil;
            _hiddenControlPoint = 0;
        }
        return;
    }
    
    if ( [keyPath isEqualToString:@"hiddenPreview"] ) {
        if ( !_controlView.hiddenPreview ) {
            [_pointTimer invalidate];
            _pointTimer = nil;
            _hiddenControlPoint = 0;
        }
        else {
            if ( !_controlView.hiddenControl ) [self.pointTimer fire];
        }
        return;
    }
    
    if ( [keyPath isEqualToString:@"status"] ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                
                [self _setEnabledGestureRecognizer:YES];
                [self addPlayerItemTimeObserver];
                [self addItemEndObserverForPlayerItem];
                [self generatePreviewImgs];
                
                CMTime duration = self.playerItem.duration;
                
                [self.controlView setCurrentTime:CMTimeGetSeconds(kCMTimeZero) duration:CMTimeGetSeconds(duration)];
                
                self.controlView.hiddenLoadFailedBtn = YES;
                
                [self clickedPlay];
                
                [self.pointTimer fire];
                
            } else {
                NSLog(@"Failed to load Video: %@", self.playerItem.error);
                NSLog(@"Failed to load Video: %@", self.playerItem.error);
                NSLog(@"Failed to load Video: %@", self.playerItem.error);
                
                // MARK: SJPlayerPlayFailedErrorNotification
                [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerPlayFailedErrorNotification object:self.playerItem.error];

                self.controlView.hiddenLoadFailedBtn = NO;
            }
        });
        return;
    }
    
    if ( [keyPath isEqualToString:@"loadedTimeRanges"] ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( 0 == CMTimeGetSeconds(_playerItem.duration) ) return;
            _controlView.sliderControl.bufferProgress = [self loadTimeSeconds] / CMTimeGetSeconds(_playerItem.duration);
        });
        return;
    }
    
    if ( [keyPath isEqualToString:@"playbackBufferEmpty"] ) {
        if ( !_playerItem.playbackBufferEmpty ) return;
        [self _buffering];
        return;
    }
}

- (void)_buffering {
    if ( 0 == self.lastPlaybackRate ) [self clickedPause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self play];
        if ( !_playerItem.isPlaybackLikelyToKeepUp ) [self _buffering];
    });
}

- (NSTimeInterval)loadTimeSeconds {
    CMTimeRange loadTimeRange = [_playerItem.loadedTimeRanges.firstObject CMTimeRangeValue];
    CMTime startTime = loadTimeRange.start;
    CMTime rangeDuration  = loadTimeRange.duration;
    return CMTimeGetSeconds(startTime) + CMTimeGetSeconds(rangeDuration);
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
    _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_asset];
    [_imageGenerator generateCGImagesAsynchronouslyForTimes:timesM completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if ( result == AVAssetImageGeneratorSucceeded ) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            SJVideoPreviewModel *model = [SJVideoPreviewModel previewModelWithImage:image localTime:actualTime];
            if ( model ) [imagesM addObject:model];
        }
        else if ( result == AVAssetImageGeneratorFailed ) {
            NSLog(@"ERROR : %@", error);
        }
                
        if ( --count == 0 ) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( 0 == imagesM.count ) return ;
                self.controlView.previewImages = imagesM;
                self.controlView.hiddenPreviewBtn = NO;
            });

        }
    }];
}

// MARK: Setter

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if ( _playerItem == playerItem ) return;
    
    [_playerItem removeObserver:self forKeyPath:@"status"];
    
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    
    _playerItem = playerItem;
    
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setRate:(float)rate {
    if ( rate < 0.5 ) rate = .5;
    if ( rate > 2 ) rate = 2;
    _rate = rate;
    _player.rate = rate;
    [self clickedPlay];
}

// MARK: Operations

- (void)play {
    [self clickedPlay];
}

- (void)pause {
    [self clickedPause];
}

- (void)sjReset {
    
    if ( _timeObserver ) {[_player removeTimeObserver:_timeObserver]; _timeObserver = nil;}
    
    if ( _itemEndObserver ) {[[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem]; _itemEndObserver = nil;}
    
    [self _setEnabledGestureRecognizer:NO];
    
    if ( _player.rate != 0 )[_player pause];
    
    [_imageGenerator cancelAllCGImageGeneration];
    
    self.playerItem = nil;
    _backstageRegistrar = nil;
    _rate = 1;
}

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    [self jumpedToCMTime:seekTime completionHandler:completionHandler];
}

- (void)_setEnabledGestureRecognizer:(BOOL)bol {
    self.singleTap.enabled = bol;
    self.doubleTap.enabled = bol;
    self.panGR.enabled = bol;
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
        self.playedTime = currentTime;
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
        [self clickedPause];
        self.backstageRegistrar.isPlayEnded = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerDidPlayToEndTimeNotification object:nil];
    };
    
    self.itemEndObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:name
                                                      object:self.playerItem
                                                       queue:queue
                                                  usingBlock:callback];
}

// MARK: Setter

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
    _brightnessView.normalShowImage = [UIImage imageNamed:@"sj_video_player_brightness"];
    return _brightnessView;
}

- (SJVideoPlayerTipsView *)volumeView {
    if ( _volumeView ) return _volumeView;
    _volumeView = [SJVideoPlayerTipsView new];
    _volumeView.bounds = CGRectMake(0, 0, 155, 155);
    _volumeView.center = [UIApplication sharedApplication].keyWindow.center;
    _volumeView.titleLabel.text = @"音量";
    _volumeView.minShowImage = [UIImage imageNamed:@"sj_video_player_un_volume"];
    _volumeView.minShowTitleLabel.text = @"静音";
    _volumeView.normalShowImage = [UIImage imageNamed:@"sj_video_player_volume"];
    return _volumeView;
}

- (SJVideoPlayerBackstageStatusRegistrar *)backstageRegistrar {
    if ( _backstageRegistrar ) return _backstageRegistrar;
    _backstageRegistrar = [SJVideoPlayerBackstageStatusRegistrar new];
    return _backstageRegistrar;
}

- (SJVideoPlayerControlView *)controlView {
    if ( _controlView ) return _controlView;
    _controlView = [SJVideoPlayerControlView new];
    _controlView.delegate = self;
    _controlView.sliderControl.delegate = self;
    [_controlView getMoreSettingsSlider:^(SJSlider *volumeSlider, SJSlider *brightnessSlider, SJSlider *rateSlider) {
        brightnessSlider.delegate = self;
        volumeSlider.delegate = self;
        rateSlider.delegate = self;
    }];
    _controlView.hiddenPlayBtn = YES;
    _controlView.hiddenReplayBtn = YES;
    _controlView.hiddenLockBtn = YES;
    _controlView.hiddenDraggingProgress = YES;
    _controlView.hiddenLoadFailedBtn = YES;
    _controlView.hiddenPreviewBtn = YES;
    _controlView.hiddenPreview = YES;
    
    // MARK: GestureRecognizer

    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.singleTap.delaysTouchesBegan = YES;
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    self.doubleTap.delaysTouchesBegan = YES;
    self.doubleTap.numberOfTapsRequired = 2;
    
    self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGR.delaysTouchesBegan = YES;
    
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    [self.doubleTap requireGestureRecognizerToFail:self.panGR];
    
    [_controlView addGestureRecognizer:self.singleTap];
    [_controlView addGestureRecognizer:self.doubleTap];
    [_controlView addGestureRecognizer:self.panGR];
    
    return _controlView;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    if ( !_controlView.hiddenMoreSettingsView ) {
        _controlView.hiddenMoreSettingsView = YES;
        return;
    }
    _controlView.hiddenControl = !_controlView.hiddenControl;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    if ( self.lastPlaybackRate > 0.f ) {
        [self controlView:_controlView clickedBtnTag:SJVideoPlayControlViewTag_Pause];
        _controlView.hiddenControl = NO;
    }
    else {
        if ( self.backstageRegistrar.isPlayEnded ) [self play];
        [self controlView:_controlView clickedBtnTag:SJVideoPlayControlViewTag_Play];
        _controlView.hiddenControl = YES;
    }
    
}

static UIView *target = nil;

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
            if (x > y) {
                /// 水平移动
                _panDirection = SJPanDirection_H;
                _controlView.hiddenControl = YES;
                [self sliderWillBeginDragging:_controlView.sliderControl];
            }
            else if (x < y) {
                /// 垂直移动
                _panDirection = SJPanDirection_V;
                
                CGPoint locationPoint = [pan locationInView:pan.view];
                if (locationPoint.x > _controlView.bounds.size.width / 2) {
                    _panLocation = SJVerticalPanLocation_Right;
                    _volumeView.value = self.systemVolume.value;
                    target = _volumeView;
                }
                else {
                    _panLocation = SJVerticalPanLocation_Left;
                    _brightnessView.value = [UIScreen mainScreen].brightness;
                    target = _brightnessView;
                }
                
                [[UIApplication sharedApplication].keyWindow bringSubviewToFront:target];
                target.transform = _controlView.superview.transform;
                [UIView animateWithDuration:0.25 animations:^{
                    target.alpha = 1;
                }];

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
                            CGFloat value = [UIScreen mainScreen].brightness - offset.y * 0.006;
                            if ( value < 1.0 / 16 ) value = 1.0 / 16;
                            [UIScreen mainScreen].brightness = value;
                            _brightnessView.value = value;
                            _controlView.brightnessSlider.value = _brightnessView.value;
                        }
                            break;
                        case SJVerticalPanLocation_Right: {
                            _systemVolume.value -= offset.y * 0.006;
                            _controlView.volumeSlider.value = _systemVolume.value;
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
                    [UIView animateWithDuration:0.5 animations:^{
                        target.alpha = 0.001;
                    }];
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

// MARK: Timer

- (NSTimer *)pointTimer {
    if ( _pointTimer ) return _pointTimer;
    __weak typeof(self) _self = self;
    _pointTimer = [NSTimer sj_scheduledTimerWithTimeInterval:1 exeBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !_controlView.sliderControl.isDragging ) self.hiddenControlPoint += 1;
        else self.hiddenControlPoint = 0;
    } repeats:YES];
    return _pointTimer;
}

@end



@implementation SJVideoPlayerControl (SJVideoPlayerControlViewDelegateMethods)

- (void)controlView:(SJVideoPlayerControlView *)controlView selectedPreviewModel:(SJVideoPreviewModel *)model {
    [self jumpedToCMTime:model.localTime completionHandler:^(BOOL finished) {
        if ( self.lastPlaybackRate > 0.f) [self clickedPlay];
    }];
}

- (void)controlView:(SJVideoPlayerControlView *)controlView clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    switch (tag) {
        case SJVideoPlayControlViewTag_Play: {
            self.isUserClickedPause = NO;
            [self clickedPlay];
        }
            break;
        case SJVideoPlayControlViewTag_Pause: {
            [[SJVideoPlayer sharedPlayer] showTitle:@"已暂停" duration:0.8];
            self.isUserClickedPause = YES;
            [self clickedPause];
        }
            break;
        case SJVideoPlayControlViewTag_Replay:
            [self clickedReplay];
            break;
        case SJVideoPlayControlViewTag_Back:
            [self clickedBack];
            break;
        case SJVideoPlayControlViewTag_Full:
            [self clickedFull];
            break;
        case SJVideoPlayControlViewTag_Preview: {
            _controlView.hiddenControl = NO;
            _controlView.hiddenPreview = !_controlView.hiddenPreview;
        }
            break;
        case SJVideoPlayControlViewTag_Lock:
            [self clickedLock];
            break;
        case SJVideoPlayControlViewTag_Unlock:
            [self clickedUnlock];
            break;
        case SJVideoPlayControlViewTag_LoadFailed:
            [self clickedLoadFailed];
            break;
        case SJVideoPlayControlViewTag_More:
            [self clickedMore];
            break;
    }
}

- (void)clickedPlay {
    if ( self.backstageRegistrar.isPlaying ) return;
    if ( 1 >= CMTimeGetSeconds(_playerItem.currentTime) || self.backstageRegistrar.isPlayEnded ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerBeginPlayingNotification object:nil];
        self.backstageRegistrar.isPlayEnded = NO;
    }
    [self.player play];
    self.controlView.hiddenReplayBtn = YES;
    self.controlView.hiddenPlayBtn = YES;
    self.controlView.hiddenPauseBtn = NO;
    self.lastPlaybackRate = self.player.rate = self.rate;
    self.backstageRegistrar.isPlaying = YES;
}

- (void)clickedPause {
    if ( !self.backstageRegistrar.isPlaying ) return;
    [self.player pause];
    self.controlView.hiddenPlayBtn = NO;
    self.controlView.hiddenPauseBtn = YES;
    self.lastPlaybackRate = self.player.rate;
    self.backstageRegistrar.isPlaying = NO;
}

- (void)clickedReplay {
    [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerBeginPlayingNotification object:nil];
    [self clickedPlay];
}

- (void)clickedBack {
    if ( ![self.delegate respondsToSelector:@selector(clickedBackBtnEvent:)] ) return;
    [self.delegate clickedBackBtnEvent:self];
}

- (void)clickedFull {
    if ( ![self.delegate respondsToSelector:@selector(clickedFullScreenBtnEvent:)] ) return;
    [self.delegate clickedFullScreenBtnEvent:self];
}

- (void)clickedStop {
    [self.player setRate:0.0f];
    self.lastPlaybackRate = self.player.rate;
}

- (void)clickedLock {
    if ( ![self.delegate respondsToSelector:@selector(clickedLockBtnEvent:)] ) return;
    [self.delegate clickedLockBtnEvent:self];
}

- (void)clickedUnlock {
    _controlView.hiddenMoreSettingsView = YES;
    if ( ![self.delegate respondsToSelector:@selector(clickedUnlockBtnEvent:)] ) return;
    [self.delegate clickedUnlockBtnEvent:self];
}

- (void)clickedLoadFailed {
    /// 重新加载
    _controlView.hiddenLoadFailedBtn = YES;
    [SJVideoPlayer sharedPlayer].assetURL = [SJVideoPlayer sharedPlayer].assetURL;
}

- (void)clickedMore {
    _controlView.hiddenControl = YES;
    _controlView.hiddenMoreSettingsView = NO;
    _controlView.volumeSlider.value = _systemVolume.value;
    _controlView.brightnessSlider.value = [UIScreen mainScreen].brightness;
    _controlView.rateSlider.value = self.rate;
}

- (void)jumpedToCMTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler {
    if ( self.playerItem.status != AVPlayerStatusReadyToPlay ) return;
    CMTime sub = CMTimeSubtract(_playerItem.currentTime, time);
    // 小于1秒 不给跳.
    if ( labs(sub.value / sub.timescale) < 1 ) {if ( completionHandler ) completionHandler(YES); return;}
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        if ( completionHandler ) completionHandler(finished);
    }];
}

@end




@implementation SJVideoPlayerControl (SJSliderDelegateMethods)

- (void)sliderWillBeginDragging:(SJSlider *)slider {
    switch (slider.tag) {
        case SJVideoPlaySliderTag_Control: {
            if ( _timeObserver ) {[self.player removeTimeObserver:_timeObserver]; _timeObserver = nil;}
            _controlView.draggingProgressView.value = _controlView.sliderControl.value;
            _controlView.hiddenDraggingProgress = NO;
        }
            break;
        case SJVideoPlaySliderTag_Rate: {
            if ( !_controlView.hiddenReplayBtn ) [self clickedPlay];
        }
            break;
        default:
            break;
    }
    
    
}

- (void)sliderDidDrag:(SJSlider *)slider {
    switch (slider.tag) {
        case SJVideoPlaySliderTag_Control: {
            [_playerItem cancelPendingSeeks];
            [self jumpedToTime:slider.value * CMTimeGetSeconds(_playerItem.duration) completionHandler:nil];
            _controlView.draggingProgressView.value = slider.value;
            _controlView.draggingTimeLabel.text = [_controlView formatSeconds:slider.value * CMTimeGetSeconds(_playerItem.duration)];
        }
            break;
        case SJVideoPlaySliderTag_Volume: {
            _systemVolume.value = slider.value;
        }
            break;
        case SJVideoPlaySliderTag_Brightness: {
            if ( slider.value < 0.1 ) { slider.value = 0.1;}
            [UIScreen mainScreen].brightness = slider.value;
        }
            break;
        case SJVideoPlaySliderTag_Rate: {
            self.rate = slider.value;
        }
            break;
    }
}

- (void)sliderDidEndDragging:(SJSlider *)slider {
    switch (slider.tag) {
        case SJVideoPlaySliderTag_Control: {
            [self addPlayerItemTimeObserver];
            if ( self.lastPlaybackRate > 0.f) [self clickedPlay];
            if ( self.backstageRegistrar.isPlayEnded ) [self clickedPlay];
            _controlView.hiddenDraggingProgress = YES;
        }
            break;
        case SJVideoPlaySliderTag_Rate: {
            if ( slider.value < 1.08 && slider.value > 0.92 ) {
                slider.value = 1;
                self.rate = slider.value;
            }
        }
        default:
            break;
    }
}

@end




// MARK: 通知处理

@implementation SJVideoPlayerControl (DBNotifications)

// MARK: 通知安装

- (void)_SJVideoPlayerControlInstallNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    /// 锁定
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLockedScreenNotification) name:SJPlayerLockedScreenNotification object:nil];
    
    /// 解锁
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerUnlockedScreenNotification) name:SJPlayerUnlockedScreenNotification object:nil];
    
    /// 全屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFullScreenNotitication) name:SJPlayerFullScreenNotitication object:nil];
    
    /// 小屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerSmallScreenNotification) name:SJPlayerSmallScreenNotification object:nil];

    // 耳机
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];

    // 后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    
    // 前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsPlayerNotification:) name:SJSettingsPlayerNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreSettingsNotification:) name:SJMoreSettingsNotification object:nil];
}

- (void)_SJVideoPlayerControlRemoveNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)volumeChanged {
    _volumeView.value = _systemVolume.value;
}

/// 锁定
- (void)playerLockedScreenNotification {
    NSLog(@"锁定");
    self.backstageRegistrar.isLock = YES;
    _controlView.hiddenControl = YES;
    _controlView.hiddenUnlockBtn = !(_controlView.hiddenLockBtn = NO);
    [self _setEnabledGestureRecognizer:NO];
}

/// 解锁
- (void)playerUnlockedScreenNotification {
    NSLog(@"解锁");
    self.backstageRegistrar.isLock = NO;
    _controlView.hiddenControl = NO;
    _controlView.hiddenUnlockBtn = !(_controlView.hiddenLockBtn = YES);
    [self _setEnabledGestureRecognizer:YES];
}

/// 全屏
- (void)playerFullScreenNotitication {
    NSLog(@"全屏");
    _controlView.hiddenControl = NO;
}

/// 小屏
- (void)playerSmallScreenNotification {
    NSLog(@"小屏");
    _controlView.hiddenControl = NO;
}

/// 耳机
- (void)audioSessionRouteChangeNotification:(NSNotification*)notifi {
    NSDictionary *interuptionDict = notifi.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // 耳机拔掉
            // 拔掉耳机继续播放
            [self clickedPlay];
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

// 后台
- (void)applicationWillResignActiveNotification {
    [self.backstageRegistrar registrar:_controlView];
    [self clickedPause];
    if ( _backstageRegistrar.hiddenLockBtn ) [self clickedUnlock];
}

// 前台
- (void)applicationDidBecomeActiveNotification {
    if ( _backstageRegistrar.hiddenLockBtn ) [self clickedLock];
    if ( _backstageRegistrar.hiddenPlayBtn ) [self clickedPlay];
}

- (void)settingsPlayerNotification:(NSNotification *)notifi {
    SJVideoPlayerSettings *settings = notifi.object;
    if ( settings.volumeImage ) self.volumeView.normalShowImage = settings.volumeImage;
    if ( settings.muteImage ) self.volumeView.minShowImage = settings.muteImage;
    if ( settings.brightnessImage ) self.brightnessView.normalShowImage = settings.brightnessImage;
}

- (void)moreSettingsNotification:(NSNotification *)notifi {
    NSArray<SJVideoPlayerMoreSetting *> *moreSettings = notifi.object;
    __weak typeof(self) _self = self;
    [moreSettings enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSetting * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( obj.clickedExeBlock ) {
            void(^clickedExeBlock)(SJVideoPlayerMoreSetting *model) = [obj.clickedExeBlock copy];
            obj.clickedExeBlock = ^(SJVideoPlayerMoreSetting * _Nonnull model) {
                clickedExeBlock(model);
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                self.controlView.hiddenMoreSettingsView = YES;
            };
        }
    }];
}

@end



@implementation SJVideoPlayerBackstageStatusRegistrar

- (void)registrar:(SJVideoPlayerControlView *)controlView {
    self.hiddenLockBtn = controlView.hiddenLockBtn;
    self.hiddenPlayBtn = controlView.hiddenPlayBtn;
}

@end
