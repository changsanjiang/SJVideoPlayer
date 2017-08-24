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



@interface SJVideoPlayerBackstageStatusRegistrar : NSObject

- (void)registrar:(SJVideoPlayerControlView *)controlView;

@property (nonatomic, assign, readwrite) BOOL hiddenLockBtn;

@property (nonatomic, assign, readwrite) BOOL hiddenPlayBtn;

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

@property (nonatomic, strong, readonly) SJVideoPlayerBackstageStatusRegistrar *backstageRegistrar;


@property (nonatomic, assign, readwrite) NSTimeInterval playedTime;

@end

@implementation SJVideoPlayerControl

@synthesize systemVolume = _systemVolume;
@synthesize controlView = _controlView;
@synthesize volumeView = _volumeView;
@synthesize brightnessView = _brightnessView;
@synthesize backstageRegistrar = _backstageRegistrar;

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
    return self;
}

- (void)dealloc {
    [self _SJVideoPlayerControlRemoveNotifications];
}

- (void)setAsset:(AVAsset *)asset playerItem:(AVPlayerItem *)playerItem player:(AVPlayer *)player {
    [self _sjResetPlayer];
    
    _asset = asset;
    _playerItem = playerItem;
    _player = player;
    
    [_playerItem addObserver:self forKeyPath:STATUS_KEYPATH options:0 context:&SJPlayerItemStatusContext];
    
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲区空了，需要等待数据
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
}

// MARK: Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( context == &SJPlayerItemStatusContext ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH];
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                
                [self _setEnabledGestureRecognizer:YES];
                [self addPlayerItemTimeObserver];
                [self addItemEndObserverForPlayerItem];
                [self generatePreviewImgs];
                
                CMTime duration = self.playerItem.duration;
                
                [self.controlView setCurrentTime:CMTimeGetSeconds(kCMTimeZero) duration:CMTimeGetSeconds(duration)];
                
                self.controlView.hiddenLoadFailedBtn = YES;
                
                [self clickedPlay];
                
            } else {
                NSLog(@"Failed to load Video: %@", self.playerItem.error);
                NSLog(@"Failed to load Video: %@", self.playerItem.error);
                NSLog(@"Failed to load Video: %@", self.playerItem.error);
                [SJVideoPlayer sharedPlayer].error = self.playerItem.error;
                self.controlView.hiddenLoadFailedBtn = NO;
            }
        });
    }
    
    if ( [keyPath isEqualToString:@"loadedTimeRanges"] ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( 0 == CMTimeGetSeconds(_playerItem.duration) ) return;
            _controlView.sliderControl.bufferProgress = [self loadTimeSeconds] / CMTimeGetSeconds(_playerItem.duration);
        });
    }
    
    if ( [keyPath isEqualToString:@"playbackBufferEmpty"] ) {
        if ( _playerItem.playbackBufferEmpty ) { NSLog(@"缓冲为空. 停止播放"); [self clickedPause]; return;}
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"开始缓冲了");
            NSLog(@"缓冲小于 5 秒, 退出继续等待缓冲");
            if ( [self loadTimeSeconds] < (self.playedTime + 5) ) return ;
            NSLog(@"缓冲差不多了, 开始播放");
            if ( !_controlView.isUserClickedPause ) [self clickedPlay];
        });
    }
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
                if ( 0 == imagesM.count ) return ;
                self.controlView.previewImages = imagesM;
                self.controlView.hiddenPreviewBtn = NO;
            });

        }
    }];
}

- (void)_sjResetPlayer {
    NSLog(@"reset Player");
    
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    
    [self.player removeTimeObserver:_timeObserver];
    _timeObserver = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    _itemEndObserver = nil;
    
    
    [self _setEnabledGestureRecognizer:NO];

}

- (void)_setEnabledGestureRecognizer:(BOOL)bol {
    self.singleTap.enabled = bol;
    self.doubleTap.enabled = bol;
//    self.panGR.enabled = bol;
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
    _controlView.hiddenPlayBtn = YES;
    _controlView.hiddenReplayBtn = YES;
    _controlView.hiddenLockBtn = YES;
    _controlView.hiddenLockContainerView = YES;
    _controlView.draggingTimeLabel.alpha = 0.001;
    _controlView.draggingProgressView.alpha = 0.001;
    _controlView.hiddenLoadFailedBtn = YES;
    _controlView.hiddenPreviewBtn = YES;

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
        [self clickedPause];
    else
        [self clickedPlay];
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
                [self sliderWillBeginDragging:_controlView.sliderControl];
            }
            else if (x < y){
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

@end



@implementation SJVideoPlayerControl (SJVideoPlayerControlViewDelegateMethods)

- (void)controlView:(SJVideoPlayerControlView *)controlView selectedPreviewModel:(SJVideoPreviewModel *)model {
    [self jumpedToCMTime:model.localTime completionHandler:^(BOOL finished) {
        if ( self.lastPlaybackRate > 0.f) [self clickedPlay];
    }];
}

- (void)controlView:(SJVideoPlayerControlView *)controlView clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    switch (tag) {
        case SJVideoPlayControlViewTag_Play:
            [self clickedPlay];
            break;
        case SJVideoPlayControlViewTag_Pause:
            [self clickedPause];
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
        case SJVideoPlayControlViewTag_Preview:
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
    }
}

- (void)clickedPlay {
    if ( 0 != self.player.rate ) return;
    [self.player play];
    self.controlView.hiddenReplayBtn = YES;
    self.controlView.hiddenPlayBtn = YES;
    self.controlView.hiddenPauseBtn = NO;
    self.lastPlaybackRate = self.player.rate;
}

- (void)clickedPause {
    [self.player pause];
    self.controlView.hiddenPlayBtn = NO;
    self.controlView.hiddenPauseBtn = YES;
    self.lastPlaybackRate = self.player.rate;
}

- (void)clickedReplay {
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
    if ( ![self.delegate respondsToSelector:@selector(clickedUnlockBtnEvent:)] ) return;
    [self.delegate clickedUnlockBtnEvent:self];
}

- (void)clickedLoadFailed {
    /// 重新加载
    _controlView.hiddenLoadFailedBtn = YES;
    [SJVideoPlayer sharedPlayer].assetURL = [SJVideoPlayer sharedPlayer].assetURL;
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
    _controlView.draggingProgressView.value = _controlView.sliderControl.value;
    [UIView animateWithDuration:0.25 animations:^{
        _controlView.draggingProgressView.alpha = 1.0;
        _controlView.draggingTimeLabel.alpha = 1.0;
    }];
}

- (void)sliderDidDrag:(SJSlider *)slider {
    [_playerItem cancelPendingSeeks];
    [self jumpedToTime:slider.value * CMTimeGetSeconds(_playerItem.duration) completionHandler:nil];
    _controlView.draggingProgressView.value = slider.value;
    _controlView.draggingTimeLabel.text = [_controlView formatSeconds:slider.value * CMTimeGetSeconds(_playerItem.duration)];
}

- (void)sliderDidEndDragging:(SJSlider *)slider {
    [self addPlayerItemTimeObserver];
    if ( self.lastPlaybackRate > 0.f) [self clickedPlay];
    [UIView animateWithDuration:1 animations:^{
        _controlView.draggingProgressView.alpha = 0.001;
        _controlView.draggingTimeLabel.alpha = 0.001;
    }];
}

@end




// MARK: 通知处理

#import "SJVideoPlayerStringConstant.h"

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
    _controlView.hiddenControl = YES;
    _controlView.hiddenLockBtn = NO;
    _controlView.hiddenUnlockBtn = YES;
    
    _singleTap.enabled = NO;
    _doubleTap.enabled = NO;
    _panGR.enabled = NO;
}

/// 解锁
- (void)playerUnlockedScreenNotification {
    NSLog(@"解锁");
    _controlView.hiddenControl = NO;
    _controlView.hiddenLockBtn = YES;
    _controlView.hiddenUnlockBtn = NO;
    
    _singleTap.enabled = YES;
    _doubleTap.enabled = YES;
    _panGR.enabled = YES;
}

/// 全屏
- (void)playerFullScreenNotitication {
    NSLog(@"全屏");
    _controlView.hiddenControl = NO;
    _controlView.hiddenLockContainerView = NO;
}

/// 小屏
- (void)playerSmallScreenNotification {
    NSLog(@"小屏");
    _controlView.hiddenControl = NO;
    _controlView.hiddenLockContainerView = YES;
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

@end



@implementation SJVideoPlayerBackstageStatusRegistrar

- (void)registrar:(SJVideoPlayerControlView *)controlView {
    self.hiddenLockBtn = controlView.hiddenLockBtn;
    self.hiddenPlayBtn = controlView.hiddenPlayBtn;
}

@end
