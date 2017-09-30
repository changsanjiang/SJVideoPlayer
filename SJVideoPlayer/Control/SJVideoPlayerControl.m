//
//  SJVideoPlayerControl.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerControl.h"
#import <objc/message.h>
#import <Masonry/Masonry.h>
#import <SJSlider/SJSlider.h>
#import <MediaPlayer/MPVolumeView.h>
#import <AVFoundation/AVFoundation.h>
#import "SJVideoPlayerStringConstant.h"
#import "SJVideoPlayerControlView.h"
#import "SJVideoPlayerTipsView.h"
#import "NSTimer+SJExtension.h"
#import "SJVideoPreviewModel.h"
#import "SJVideoPlayerMoreSetting.h"
#import "SJVideoPlayerSettings.h"
#import <SJPrompt/SJPrompt.h>

#define SJGetFileWithName(name)    [@"SJVideoPlayer.bundle" stringByAppendingPathComponent:name]

/*!
 *  Refresh interval for timed observations of AVPlayer
 */
#define REFRESH_INTERVAL (0.5)

/*!
 *  0.0 - 1.0
 */
#define SJPreImgGenerateInterval (0.05)

typedef NS_ENUM(NSUInteger, SJVideoPlayerPlayState) {
    SJVideoPlayerPlayState_Unknown,
    SJVideoPlayerPlayState_Prepare,
    SJVideoPlayerPlayState_Playing,
    SJVideoPlayerPlayState_Buffing,
    SJVideoPlayerPlayState_Pause,
    SJVideoPlayerPlayState_PlayEnd,
    SJVideoPlayerPlayState_PlayFailed,
};


@interface SJVideoPlayerStatusRegistrar : NSObject

// 进入后台 统计信息 >>>>>
- (void)registrar:(SJVideoPlayerControlView *)controlView;

@property (nonatomic, assign, readonly) BOOL hiddenLockBtn;

@property (nonatomic, assign, readonly) BOOL hiddenPlayBtn;
// <<<<<<<<<<<

@property (nonatomic, assign, readwrite) BOOL isLock;

@property (nonatomic, assign, readwrite) BOOL scrollIn;

@property (nonatomic, assign, readwrite) BOOL playingOnCell;

@property (nonatomic, assign, readwrite) BOOL fullScreen;

@property (nonatomic, assign, readwrite) BOOL generatedImages;

@property (nonatomic, assign, readwrite) SJVideoPlayerPlayState playState;

@property (nonatomic, assign, readwrite) BOOL userClickedPause;

@end

@implementation SJVideoPlayerStatusRegistrar

- (void)registrar:(SJVideoPlayerControlView *)controlView {
    _hiddenLockBtn = controlView.hiddenLockBtn;
    _hiddenPlayBtn = controlView.hiddenPlayBtn;
}

- (void)setScrollIn:(BOOL)scrollIn {
    if ( _scrollIn == scrollIn ) return;
    _scrollIn = scrollIn;
    if ( _scrollIn ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerScrollInNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerScrollOutNotification object:nil];
    }
}

@end


#pragma mark -

@interface SJVideoPlayerControl (DBNotifications)

- (void)_installNotifications;

- (void)_removeNotifications;

- (void)_smallScreenPlaying;

- (void)_playerUnlocked;

@end


#pragma mark -

@interface SJVideoPlayerControl (DBObservers)
- (void)_addPlayerItemTimeObserver;
@end


#pragma mark -

@interface SJVideoPlayerControl (PlayingOnTheCell)
- (void)_scrollViewDidScroll;
@end


#pragma mark -

@interface SJVideoPlayerControl (SJSliderDelegateMethods)<SJSliderDelegate>@end


#pragma mark -

@interface SJVideoPlayerControl (SJVideoPlayerControlViewDelegateMethods)<SJVideoPlayerControlViewDelegate>

- (void)_clickedPlay;

- (void)_clickedPause;

- (void)_clickedReplay;

- (void)_clickedBack;

- (void)_clickedFull;

- (void)_clickedStop;

- (void)_clickedLoadFailed;

- (void)jumpedToCMTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler;

@end


#pragma mark -

@interface SJVideoPlayerControl ()

@property (nonatomic, strong, readonly) UISlider *systemVolume;

@property (nonatomic, strong, readonly) SJVideoPlayerTipsView *volumeView;

@property (nonatomic, strong, readonly) SJVideoPlayerTipsView *brightnessView;

@property (nonatomic, strong, readonly) SJVideoPlayerControlView *controlView;

@property (nonatomic, weak, readwrite) AVAsset *asset;

@property (nonatomic, weak, readwrite) AVPlayer *player;
@property (nonatomic, assign, readwrite) CGFloat lastPlaybackRate;

@property (nonatomic, weak, readwrite) AVPlayerItem *playerItem;
@property (nonatomic, strong, readwrite) id timeObserver;
@property (nonatomic, strong, readwrite) id itemEndObserver;

@property (nonatomic, strong, readwrite) SJVideoPlayerStatusRegistrar *backstageRegistrar;

@property (nonatomic, strong, readwrite) AVAssetImageGenerator *imageGenerator;

@property (nonatomic, assign, readwrite) NSInteger hiddenControlPoint;
@property (nonatomic, strong, readonly) NSTimer *pointTimer;
- (void)_resetTimer;

@property (nonatomic, weak, readwrite) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) NSIndexPath *indexPath;

@property (nonatomic, strong, readonly) dispatch_queue_t SJPlayerQueue;

@end


#pragma mark -

@interface SJVideoPlayerControl (GestureRecognizer)

- (void)_addGestureToControlView;

@property (nonatomic, strong, readonly) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGR;

@end


#pragma mark -

@interface SJVideoPlayerControl (ControlViewState)

- (void)_controlViewUnknownStatus;

- (void)_controlViewPrepareToPlayStatus;

- (void)_controlViewPlayingStatus;

- (void)_controlViewPauseStatus;

- (void)_controlViewPlayEndStatus;

- (void)_controlViewPlayFailed;

- (void)_controlViewSmallScreen;

- (void)_controlViewFullScreen;

- (void)_controlViewLockScreen;

- (void)_controlViewUnlockScreen;

- (void)_controlViewHidenMoreSettingsView;

- (void)_controlViewShowTwoMoreSettingsView;

- (void)_controlViewHiddenTwoMoreSettingsView;
/// 显示或隐藏控制层
- (void)_controlViewHiddenControl;
- (void)_controlViewControlLayerStateChanged;
/// 显示或隐藏预览视图
- (void)_controlViewPreviewShowedOrHidden;

@end

#pragma mark -

@implementation SJVideoPlayerControl

@synthesize systemVolume = _systemVolume;
@synthesize controlView = _controlView;
@synthesize volumeView = _volumeView;
@synthesize brightnessView = _brightnessView;
@synthesize backstageRegistrar = _backstageRegistrar;
@synthesize pointTimer = _pointTimer;
@synthesize rate = _rate;
@synthesize SJPlayerQueue = _SJPlayerQueue;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self _addGestureToControlView];
    self.backstageRegistrar.playState = SJVideoPlayerPlayState_Unknown;
    self.volumeView.alpha = 0.001;
    self.brightnessView.alpha = 0.001;
    [self _installNotifications];
    [self _addOtherObservers];
    [self pointTimer];
    [self systemVolume];
    return self;
}

- (void)dealloc {
    if ( _scrollView ) [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self _removeNotifications];
    [self _removeOtherObservers];
}

- (void)_addOtherObservers {
    [self.controlView addObserver:self forKeyPath:@"hiddenControl" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"hiddenControlPoint" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"asset" options:NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"playerItem" options:NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"player" options:NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"backstageRegistrar" options:NSKeyValueObservingOptionOld context:nil];
}

- (void)_removeOtherObservers {
    [self.controlView removeObserver:self forKeyPath:@"hiddenControl"];
    [self addObserver:self forKeyPath:@"hiddenControlPoint" options:NSKeyValueObservingOptionNew context:nil];
    [self removeObserver:self forKeyPath:@"asset"];
    [self removeObserver:self forKeyPath:@"playerItem"];
    [self removeObserver:self forKeyPath:@"player"];
    [self removeObserver:self forKeyPath:@"backstageRegistrar"];
}

- (void)setAssetCarrier:(SJVideoPlayerAssetCarrier *)assetCarrier {
    if ( _assetCarrier == assetCarrier ) return;
    _assetCarrier = assetCarrier;
    self.asset = assetCarrier.asset;
    self.playerItem = assetCarrier.playerItem;
    self.player = assetCarrier.player;
    self.backstageRegistrar = [SJVideoPlayerStatusRegistrar new];
    [self.backstageRegistrar addObserver:self forKeyPath:@"playState" options:NSKeyValueObservingOptionNew context:nil];
    self.backstageRegistrar.playState = SJVideoPlayerPlayState_Prepare;
}

// MARK: Setter

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    _playerItem = playerItem;
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_buffering {
    if ( 0 == self.lastPlaybackRate && self.backstageRegistrar.playState != SJVideoPlayerPlayState_Buffing ) {
        [self _clickedPause];
        self.backstageRegistrar.playState = SJVideoPlayerPlayState_Buffing;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ( !_playerItem.isPlaybackLikelyToKeepUp ) {
            [self _buffering];
            return ;
        }
        [self _clickedPlay];
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
    
    NSInteger seconds = (long)_asset.duration.value / _asset.duration.timescale;
    if ( 0 == seconds || isnan(seconds) ) return;
    if ( SJPreImgGenerateInterval > 1.0 ) return;
    __block short maxCount = (short)floorf(1.0 / SJPreImgGenerateInterval);
    short interval = (short)floor(seconds * SJPreImgGenerateInterval);
    for ( int i = 0 ; i < maxCount ; i ++ ) {
        CMTime time = CMTimeMake(i * interval, 1);
        NSValue *tV = [NSValue valueWithCMTime:time];
        if ( tV ) [timesM addObject:tV];
    }
    __weak typeof(self) _self = self;
    NSMutableArray <SJVideoPreviewModel *> *imagesM = [NSMutableArray new];
    _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_asset];
    _imageGenerator.appliesPreferredTrackTransform = YES;
    _imageGenerator.maximumSize = CGSizeMake(SJPreviewImgH * 3, SJPreviewImgH * 3);
    [_imageGenerator generateCGImagesAsynchronouslyForTimes:timesM completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if ( result == AVAssetImageGeneratorSucceeded ) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            SJVideoPreviewModel *model = [SJVideoPreviewModel previewModelWithImage:image localTime:actualTime];
            if ( model ) [imagesM addObject:model];
        }
        else if ( result == AVAssetImageGeneratorFailed ) {
            NSLog(@"ERROR : %@", error);
        }
        
        if ( --maxCount == 0 ) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( 0 == imagesM.count ) return ;
                self.controlView.previewImages = imagesM;
                if ( self.backstageRegistrar.fullScreen ) self.controlView.hiddenPreviewBtn = NO;
                self.backstageRegistrar.generatedImages = YES;
            });
            
        }
    }];
}

// MARK: Public

- (void)setScrollView:(UIScrollView *)scrollView indexPath:(NSIndexPath *)indexPath {
    self.scrollView = scrollView;
    self.indexPath = indexPath;
    self.controlView.hiddenBackBtn = YES;
    self.backstageRegistrar.playingOnCell = YES;
    if ( !self.backstageRegistrar.fullScreen ) self.panGR.enabled = NO;
}

- (void)setScrollView:(UIScrollView *)scrollView {
    if ( _scrollView == scrollView ) return;
    if ( scrollView != _scrollView ) [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    _scrollView = scrollView;
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setRate:(float)rate {
    if ( rate < 0.5 ) rate = .5;
    if ( rate > 2 ) rate = 2;
    _rate = rate;
    _player.rate = rate;
    [self _clickedPlay];
}

// MARK: Operations

- (void)play {
    [self _clickedPlay];
}

- (void)pause {
    [self _clickedPause];
}

- (void)sjReset {
    
    if ( _timeObserver ) {[_player removeTimeObserver:_timeObserver]; _timeObserver = nil;}
    
    if ( _itemEndObserver ) {[[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem]; _itemEndObserver = nil;}
    
    [self _setEnabledGestureRecognizer:NO];
    
    if ( _player.rate != 0 )[_player pause];
    
    [_imageGenerator cancelAllCGImageGeneration];
    
    [self _playerUnlocked];
    
    _rate = 1;
    
    [_controlView setCurrentTime:0 duration:0];
    
    self.backstageRegistrar.playState = SJVideoPlayerPlayState_Unknown;
    self.backstageRegistrar = nil;
    self.scrollView = nil;
    self.indexPath = nil;
    
    self.asset = nil;
    self.playerItem = nil;
    self.player = nil;
    
    [self.prompt hidden];
    
}

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    [self jumpedToCMTime:seekTime completionHandler:completionHandler];
}

- (void)_setEnabledGestureRecognizer:(BOOL)bol {
    self.doubleTap.enabled = bol;
    if ( self.backstageRegistrar.fullScreen ) self.panGR.enabled = bol;
    else {
        if ( self.backstageRegistrar.playingOnCell )
            self.panGR.enabled = NO;
        else
            self.panGR.enabled = bol;
    }
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
    _brightnessView.titleLabel.text = @"亮度";
    _brightnessView.normalShowImage = [UIImage imageNamed:SJGetFileWithName(@"sj_video_player_brightness")];
    return _brightnessView;
}

- (SJVideoPlayerTipsView *)volumeView {
    if ( _volumeView ) return _volumeView;
    _volumeView = [SJVideoPlayerTipsView new];
    _volumeView.titleLabel.text = @"音量";
    _volumeView.minShowImage = [UIImage imageNamed:SJGetFileWithName(@"sj_video_player_un_volume")];
    _volumeView.minShowTitleLabel.text = @"静音";
    _volumeView.normalShowImage = [UIImage imageNamed:SJGetFileWithName(@"sj_video_player_volume")];
    return _volumeView;
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
    [self _controlViewUnknownStatus];
    return _controlView;
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

- (void)_resetTimer {
    if ( nil == _pointTimer ) return;
    _hiddenControlPoint = 0;
    [_pointTimer invalidate];
    _pointTimer = nil;
}

// MARK: Lazy

- (dispatch_queue_t)SJPlayerQueue {
    if ( _SJPlayerQueue ) return _SJPlayerQueue;
    _SJPlayerQueue = dispatch_queue_create("SJPlayerThreadQueue", NULL);
    return _SJPlayerQueue;
}

- (void)_addOperation:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(self.SJPlayerQueue, ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block();
    });
}

@end

#pragma mark -

@implementation SJVideoPlayerControl (SJVideoPlayerControlViewDelegateMethods)

- (void)controlView:(SJVideoPlayerControlView *)controlView selectedPreviewModel:(SJVideoPreviewModel *)model {
    NSInteger seconds = CMTimeGetSeconds(model.localTime);
    
    [self.prompt showTitle:[NSString stringWithFormat:@"跳转至: %@", [_controlView formatSeconds:seconds]] duration:-1];
    
    [self jumpedToCMTime:model.localTime completionHandler:^(BOOL finished) {
        [self.prompt hidden];
        if ( !finished ) { return;}
        if ( self.lastPlaybackRate > 0.f) [self _clickedPlay];
    }];
    
}

- (void)controlView:(SJVideoPlayerControlView *)controlView clickedBtnTag:(SJVideoPlayControlViewTag)tag {
    switch (tag) {
        case SJVideoPlayControlViewTag_Play: {
            self.backstageRegistrar.userClickedPause = NO;
            [self _clickedPlay];
        }
            break;
        case SJVideoPlayControlViewTag_Pause: {
            [self.prompt showTitle:@"已暂停" duration:0.8];
            self.backstageRegistrar.userClickedPause = YES;
            [self _clickedPause];
        }
            break;
        case SJVideoPlayControlViewTag_Replay:
            [self _clickedReplay];
            break;
        case SJVideoPlayControlViewTag_Back:
            [self _clickedBack];
            break;
        case SJVideoPlayControlViewTag_Full:
            [self _clickedFull];
            break;
        case SJVideoPlayControlViewTag_Preview: {
            [self _controlViewPreviewShowedOrHidden];
        }
            break;
        case SJVideoPlayControlViewTag_Lock:
            [self clickedLock];
            break;
        case SJVideoPlayControlViewTag_Unlock:
            [self clickedUnlock];
            break;
        case SJVideoPlayControlViewTag_LoadFailed:
            [self _clickedLoadFailed];
            break;
        case SJVideoPlayControlViewTag_More:
            [self clickedMore];
            break;
    }
}

- (void)_clickedPlay {
    if ( self.backstageRegistrar.playState == SJVideoPlayerPlayState_Playing ) return;
    if ( 1 >= CMTimeGetSeconds(_playerItem.currentTime) || self.backstageRegistrar.playState == SJVideoPlayerPlayState_PlayEnd ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerBeginPlayingNotification object:nil];
        self.backstageRegistrar.playState = SJVideoPlayerPlayState_Playing;
    }
    [self.player play];
    self.lastPlaybackRate = self.player.rate = self.rate;
    self.backstageRegistrar.playState = SJVideoPlayerPlayState_Playing;
}

- (void)_clickedPause {
    if ( self.backstageRegistrar.playState == SJVideoPlayerPlayState_Pause ) return;
    [self.player pause];
    self.lastPlaybackRate = self.player.rate;
    self.backstageRegistrar.playState = SJVideoPlayerPlayState_Pause;
}

- (void)_clickedReplay {
    [self _clickedPlay];
}

- (void)_clickedBack {
    if ( ![self.delegate respondsToSelector:@selector(clickedBackBtnEvent:)] ) return;
    [self.delegate clickedBackBtnEvent:self];
}

- (void)_clickedFull {
    if ( ![self.delegate respondsToSelector:@selector(clickedFullScreenBtnEvent:)] ) return;
    [self.delegate clickedFullScreenBtnEvent:self];
}

- (void)_clickedStop {
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

- (void)_clickedLoadFailed {
    /// 重新加载
    _controlView.hiddenLoadFailedBtn = YES;
    if ( _clickedLoadFiledBtnCallBlock ) _clickedLoadFiledBtnCallBlock(self);
}

- (void)clickedMore {
    _controlView.hiddenControl = YES;
    _controlView.hiddenMoreSettingsView = NO;
    _controlView.volumeSlider.value = _systemVolume.value;
    _controlView.brightnessSlider.value = [UIScreen mainScreen].brightness;
    _controlView.rateSlider.value = self.rate;
}

- (void)jumpedToCMTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler {
    if ( self.playerItem.status != AVPlayerStatusReadyToPlay ) goto __SJQuit;
    // compare return. same = 0. time > currentTime = 1. time < current Time = -1
    if ( 0 == CMTimeCompare(time, _playerItem.currentTime) ) goto __SJQuit;
    if ( 1 == CMTimeCompare(time, _playerItem.duration) ) goto __SJQuit;
    // seek to time
    [self _seekToTime:time completionHandler:completionHandler];
    return;
    
__SJQuit:
    if ( completionHandler ) completionHandler(NO);
}

- (void)_seekToTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler {
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        if ( !finished ) return;
        if ( completionHandler ) completionHandler(finished);
    }];
}

@end


#pragma mark -

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
            if ( !_controlView.hiddenReplayBtn ) [self _clickedPlay];
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
            [self _addPlayerItemTimeObserver];
            if ( self.lastPlaybackRate > 0.f) [self _clickedPlay];
            if ( self.backstageRegistrar.playState == SJVideoPlayerPlayState_PlayEnd ) [self _clickedPlay];
            _controlView.hiddenDraggingProgress = YES;
        }
            break;
        case SJVideoPlaySliderTag_Rate: {
            if ( slider.value < 1.08 && slider.value > 0.92 ) {
                slider.value = 1;
                self.rate = slider.value;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerRateSliderDidEndDraggingNotification object:@(slider.value)];
        }
        default:
            break;
    }
}

@end



#pragma mark -

@implementation SJVideoPlayerControl (DBNotifications)

- (void)_installNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    /// 锁定
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLockedScreenNotification) name:SJPlayerLockedScreenNotification object:nil];
    
    /// 解锁
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playerUnlocked) name:SJPlayerUnlockedScreenNotification object:nil];
    
    /// 全屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFullScreenNotitication) name:SJPlayerFullScreenNotitication object:nil];
    
    /// 小屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_smallScreenPlaying) name:SJPlayerSmallScreenNotification object:nil];
    
    // 耳机
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    // 后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    
    // 前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsPlayerNotification:) name:SJSettingsPlayerNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreSettingsNotification:) name:SJMoreSettingsNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPrepareToPlayNotification) name:SJPlayerPrepareToPlayNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerBeginPlayingNotification) name:SJPlayerBeginPlayingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayFailedErrorNotification) name:SJPlayerPlayFailedErrorNotification object:nil];
}

- (void)_removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)volumeChanged {
    _volumeView.value = _systemVolume.value;
}

/// 锁定
- (void)playerLockedScreenNotification {
    NSLog(@"锁定");
    self.backstageRegistrar.isLock = YES;
    [self _controlViewLockScreen];
    [self _setEnabledGestureRecognizer:NO];
}

/// 解锁
- (void)_playerUnlocked {
    NSLog(@"解锁");
    self.backstageRegistrar.isLock = NO;
    [self _controlViewUnlockScreen];
    [self _setEnabledGestureRecognizer:YES];
}

/// 全屏
- (void)playerFullScreenNotitication {
    NSLog(@"全屏");
    self.backstageRegistrar.fullScreen = YES;
    [self _controlViewFullScreen];
    self.panGR.enabled = YES;
}

/// 小屏
- (void)_smallScreenPlaying {
    NSLog(@"小屏");
    self.backstageRegistrar.fullScreen = NO;
    [self _controlViewSmallScreen];
    if ( self.backstageRegistrar.playingOnCell ) self.panGR.enabled = NO;
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
            [self _clickedPlay];
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
    [self _clickedPause];
    if ( _backstageRegistrar.hiddenLockBtn ) [self clickedUnlock];
}

// 前台
- (void)applicationDidBecomeActiveNotification {
    if ( _backstageRegistrar.hiddenLockBtn ) [self clickedLock];
    if ( _backstageRegistrar.hiddenPlayBtn ) [self _clickedPlay];
}

- (void)settingsPlayerNotification:(NSNotification *)notifi {
    SJVideoPlayerSettings *settings = notifi.object;
    if ( settings.volumeImage ) self.volumeView.normalShowImage = settings.volumeImage;
    if ( settings.muteImage ) self.volumeView.minShowImage = settings.muteImage;
    if ( settings.brightnessImage ) self.brightnessView.normalShowImage = settings.brightnessImage;
}

- (void)moreSettingsNotification:(NSNotification *)notifi {
    NSArray<SJVideoPlayerMoreSetting *> *moreSettings = notifi.object;
    /// 获取所有相关的moreSettings
    NSMutableSet<SJVideoPlayerMoreSetting *> *moreSettingsM = [NSMutableSet new];
    [moreSettings enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSetting * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addSetting:obj container:moreSettingsM];
    }];
    
    [moreSettingsM enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSetting * _Nonnull obj, BOOL * _Nonnull stop) {
        [self dressSetting:obj];
    }];
    self.controlView.moreSettings = moreSettings;
}

- (void)addSetting:(SJVideoPlayerMoreSetting *)setting container:(NSMutableSet<SJVideoPlayerMoreSetting *> *)moreSttingsM {
    [moreSttingsM addObject:setting];
    if ( !setting.showTowSetting ) return;
    [setting.twoSettingItems enumerateObjectsUsingBlock:^(SJVideoPlayerMoreSettingTwoSetting * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addSetting:(SJVideoPlayerMoreSetting *)obj container:moreSttingsM];
    }];
}

- (void)dressSetting:(SJVideoPlayerMoreSetting *)setting {
    if ( !setting.clickedExeBlock ) return;
    
    void(^clickedExeBlock)(SJVideoPlayerMoreSetting *model) = [setting.clickedExeBlock copy];
    __weak typeof(self) _self = self;
    if ( setting.isShowTowSetting ) {
        setting.clickedExeBlock = ^(SJVideoPlayerMoreSetting * _Nonnull model) {
            clickedExeBlock(model);
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.controlView.twoLevelSettings = model;
            [self _controlViewShowTwoMoreSettingsView];
        };
        return;
    }
    
    setting.clickedExeBlock = ^(SJVideoPlayerMoreSetting * _Nonnull model) {
        clickedExeBlock(model);
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _controlViewHidenMoreSettingsView];
        if ( !model.isShowTowSetting ) [self _controlViewHiddenTwoMoreSettingsView];
    };
}

- (void)playerPrepareToPlayNotification {
    [_controlView startLoading];
}

- (void)playerBeginPlayingNotification {
    [_controlView stopLoading];
}

- (void)playerPlayFailedErrorNotification {
    [_controlView stopLoading];
}

@end



#pragma mark -

@implementation SJVideoPlayerControl (PlayingOnTheCell)

- (void)_scrollViewDidScroll {
    if ( [self.scrollView isKindOfClass:[UITableView class]] ) {
        UITableView *tableView = (UITableView *)self.scrollView;
        __block BOOL visable = NO;
        [tableView.indexPathsForVisibleRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( [obj compare:self.indexPath] == NSOrderedSame ) {
                visable = YES;
                *stop = YES;
            }
        }];
        if ( visable ) {
            /// 滑入时 恢复.
            self.backstageRegistrar.scrollIn = YES;
        }
        else {
            /// 滑出时 暂停, 并 停止 方向 监听
            self.backstageRegistrar.scrollIn = NO;
            
            [self _clickedPause];
        }
    }
    else if ( [self.scrollView isKindOfClass:[UICollectionView class]] ) {
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.indexPath];
        if ( [collectionView.visibleCells containsObject:cell]) {
            /// 滑入时 恢复.
            self.backstageRegistrar.scrollIn = YES;
        }
        else {
            /// 滑出时 暂停, 并 停止 方向 监听
            self.backstageRegistrar.scrollIn = NO;
            
            [self _clickedPause];
        }
    }
}

@end




#pragma mark -


@implementation SJVideoPlayerControl (DBObservers)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( object == self.scrollView ) {
        if ( [keyPath isEqualToString:@"contentOffset"] ) {
            [self _scrollViewDidScroll];
            return;
        }
    }
    
    if ( object == self.controlView ) {
        if ( [keyPath isEqualToString:@"hiddenControl"] ) {
            [self _controlViewControlLayerStateChanged];
            if ( !self.controlView.hiddenControl ) {
                self.hiddenControlPoint = 0;
                [self.pointTimer fire];
            }
            else [self _resetTimer];
            return;
        }
    }
    
    if ( object == self.backstageRegistrar ) {
        if ( [keyPath isEqualToString:@"playState"] ) {
            [self _playStateChanged];
        }
        
        return;
    }
    
    if ( object == self ) {
        if ( [keyPath isEqualToString:@"hiddenControlPoint"] ) {
            if ( _hiddenControlPoint >= SJHiddenControlInterval ) {
                [self _controlViewHiddenControl];
                [self _resetTimer];
            }
        }
        else if ( [keyPath isEqualToString:@"player"] ) {
            AVPlayer *player = change[NSKeyValueChangeOldKey];
            if ( _player == player ) return;
            [self _releaseOldPlayer:player];
        }
        
        else if ( [keyPath isEqualToString:@"playerItem"] ) {
            AVPlayerItem *playerItem = change[NSKeyValueChangeOldKey];
            if ( playerItem == _playerItem ) return;
            [self _releaseOldPlayerItem:playerItem];
        }
        else if ( [keyPath isEqualToString:@"asset"] ) {
            AVAsset *asset = change[NSKeyValueChangeOldKey];
            if ( _asset == asset ) return;
            [self _releaseOldAsset:asset];
        }
        else if ( [keyPath isEqualToString:@"backstageRegistrar"] ) {
            SJVideoPlayerStatusRegistrar *oldBackstageRegistrar = change[NSKeyValueChangeOldKey];
            if ( !oldBackstageRegistrar || [oldBackstageRegistrar isKindOfClass:[NSNull class]] ) return;
            [oldBackstageRegistrar removeObserver:self forKeyPath:@"playState"];
        }
        
        return;
    }
    
    if ( object == self.playerItem ) {
        if ( [keyPath isEqualToString:@"status"] ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                    
                    [self _addPlayerItemTimeObserver];
                    [self _addItemEndObserverForPlayerItem];
                    [self generatePreviewImgs];
                    
                    CMTime duration = self.playerItem.duration;
                    
                    [self.controlView setCurrentTime:CMTimeGetSeconds(kCMTimeZero) duration:CMTimeGetSeconds(duration)];
                    
                    self.controlView.hiddenLoadFailedBtn = YES;
                    
                    ///  开始播放时黑屏/花屏一下. 延时 1秒 播放.
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self _clickedPlay];
                        self.backstageRegistrar.playState = SJVideoPlayerPlayState_Playing;
                    });
                    
                    [self.pointTimer fire];
                    
                } else {
                    NSLog(@"Failed to load Video: %@", self.playerItem.error);
                    self.backstageRegistrar.playState = SJVideoPlayerPlayState_PlayFailed;
                }
            });
            return;
        }
        
        if ( [keyPath isEqualToString:@"loadedTimeRanges"] ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( 0 == CMTimeGetSeconds(_playerItem.duration) ) return;
                CGFloat value = [self loadTimeSeconds] / CMTimeGetSeconds(_playerItem.duration);
                if ( value > _controlView.sliderControl.bufferProgress ) _controlView.sliderControl.bufferProgress = value;
            });
            return;
        }
        
        if ( [keyPath isEqualToString:@"playbackBufferEmpty"] ) {
            if ( !_playerItem.playbackBufferEmpty ) return;
            [self _buffering];
            return;
        }
        return;
    }
}

- (void)_releaseOldAsset:(AVAsset *)oldAsset {
    [self _addOperation:^{
        if ( !oldAsset || [oldAsset isKindOfClass:[NSNull class]] ) return;
        [oldAsset cancelLoading];
    }];
}

- (void)_releaseOldPlayerItem:(AVPlayerItem *)oldPlayerItem {
    __weak typeof(self) _self = self;
    [self _addOperation:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !oldPlayerItem || [oldPlayerItem isKindOfClass:[NSNull class]] ) return;
        [oldPlayerItem removeObserver:self forKeyPath:@"status"];
        [oldPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [oldPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [oldPlayerItem cancelPendingSeeks];
    }];
}

- (void)_releaseOldPlayer:(AVPlayer *)oldPlayer {
    [self _addOperation:^{
        if ( !oldPlayer || [oldPlayer isKindOfClass:[NSNull class]] ) return;
        [oldPlayer replaceCurrentItemWithPlayerItem:nil];
    }];
}

- (void)_playStateChanged {
    switch (self.backstageRegistrar.playState) {
        case SJVideoPlayerPlayState_Unknown: {
            [self _controlViewUnknownStatus];
        }
            break;
        case SJVideoPlayerPlayState_Prepare: {
            [self _controlViewPrepareToPlayStatus];
        }
            break;
        case SJVideoPlayerPlayState_Buffing: {
            [_controlView startLoading];
        }
            break;
        case SJVideoPlayerPlayState_Playing: {
            [self _controlViewPlayingStatus];
            [_controlView stopLoading];
        }
            break;
        case SJVideoPlayerPlayState_Pause: {
            [self _controlViewPauseStatus];
        }
            break;
        case SJVideoPlayerPlayState_PlayEnd: {
            [self _controlViewPlayEndStatus];
        }
            break;
        case SJVideoPlayerPlayState_PlayFailed: {
            [self _controlViewPlayFailed];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerPlayFailedErrorNotification object:self.playerItem.error];
        }
            break;
    }
}

- (void)_addPlayerItemTimeObserver {
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

- (void)_addItemEndObserverForPlayerItem {
    
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
        [self _clickedPause];
        self.backstageRegistrar.playState = SJVideoPlayerPlayState_PlayEnd;
        [[NSNotificationCenter defaultCenter] postNotificationName:SJPlayerDidPlayToEndTimeNotification object:nil];
    };
    
    self.itemEndObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:name
                                                      object:self.playerItem
                                                       queue:queue
                                                  usingBlock:callback];
}

@end







#pragma mark - Gesture



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

@implementation SJVideoPlayerControl (GestureRecognizer)

- (void)_addGestureToControlView {
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    [self.doubleTap requireGestureRecognizerToFail:self.panGR];
    
    [self.controlView addGestureRecognizer:self.singleTap];
    [self.controlView addGestureRecognizer:self.doubleTap];
    [self.controlView addGestureRecognizer:self.panGR];
}

- (UITapGestureRecognizer *)singleTap {
    UITapGestureRecognizer *singleTap = objc_getAssociatedObject(self, _cmd);
    if ( singleTap ) return singleTap;
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.delaysTouchesBegan = YES;
    objc_setAssociatedObject(self, _cmd, singleTap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return singleTap;
}

- (UITapGestureRecognizer *)doubleTap {
    UITapGestureRecognizer *doubleTap = objc_getAssociatedObject(self, _cmd);
    if ( doubleTap ) return doubleTap;
    doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.delaysTouchesBegan = YES;
    doubleTap.numberOfTapsRequired = 2;
    objc_setAssociatedObject(self, _cmd, doubleTap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return doubleTap;
}

- (UIPanGestureRecognizer *)panGR {
    UIPanGestureRecognizer *panGR = objc_getAssociatedObject(self, _cmd);
    if ( panGR ) return panGR;
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGR.delaysTouchesBegan = YES;
    objc_setAssociatedObject(self, _cmd, panGR, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return panGR;
}

- (void)setPanDirection:(SJPanDirection)panDirection {
    objc_setAssociatedObject(self, @selector(panDirection), @(panDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJPanDirection)panDirection {
    return (SJPanDirection)[objc_getAssociatedObject(self , _cmd) integerValue];
}

- (void)setPanLocation:(SJVerticalPanLocation)panLocation {
    objc_setAssociatedObject(self, @selector(panLocation), @(panLocation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJVerticalPanLocation)panLocation {
    return (SJVerticalPanLocation)[objc_getAssociatedObject(self , _cmd) integerValue];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    if ( self.backstageRegistrar.isLock ) return;
    if ( !self.controlView.hiddenMoreSettingsView ) {
        self.controlView.hiddenMoreSettingsView = YES;
        return;
    }
    if ( !self.controlView.hiddenMoreSettingsTwoLevelView ) {
        self.controlView.hiddenMoreSettingsTwoLevelView = YES;
        return;
    }
    self.controlView.hiddenControl = !self.controlView.hiddenControl;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    if ( self.lastPlaybackRate > 0.f ) {
        [self controlView:self.controlView clickedBtnTag:SJVideoPlayControlViewTag_Pause];
    }
    else {
        if ( self.backstageRegistrar.playState == SJVideoPlayerPlayState_PlayEnd ) [self play];
        [self controlView:self.controlView clickedBtnTag:SJVideoPlayControlViewTag_Play];
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
                self.panDirection = SJPanDirection_H;
                self.controlView.hiddenControl = YES;
                [self sliderWillBeginDragging:self.controlView.sliderControl];
            }
            else if (x < y) {
                /// 垂直移动
                self.panDirection = SJPanDirection_V;
                
                CGPoint locationPoint = [pan locationInView:pan.view];
                if (locationPoint.x > self.controlView.bounds.size.width / 2) {
                    self.panLocation = SJVerticalPanLocation_Right;
                    self.volumeView.value = self.systemVolume.value;
                    target = self.volumeView;
                }
                else {
                    self.panLocation = SJVerticalPanLocation_Left;
                    self.brightnessView.value = [UIScreen mainScreen].brightness;
                    target = self.brightnessView;
                }
                [[UIApplication sharedApplication].keyWindow addSubview:target];
                [target mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_offset(CGSizeMake(155, 155));
                    make.center.equalTo([UIApplication sharedApplication].keyWindow);
                }];
                target.transform = self.controlView.superview.transform;
                [UIView animateWithDuration:0.25 animations:^{
                    target.alpha = 1;
                }];
                
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case SJPanDirection_H:{
                    self.controlView.sliderControl.value += offset.x * 0.003;
                    [self sliderDidDrag:self.controlView.sliderControl];
                }
                    break;
                case SJPanDirection_V:{
                    switch (self.panLocation) {
                        case SJVerticalPanLocation_Left: {
                            CGFloat value = [UIScreen mainScreen].brightness - offset.y * 0.006;
                            if ( value < 1.0 / 16 ) value = 1.0 / 16;
                            [UIScreen mainScreen].brightness = value;
                            self.brightnessView.value = value;
                            self.controlView.brightnessSlider.value = self.brightnessView.value;
                        }
                            break;
                        case SJVerticalPanLocation_Right: {
                            self.systemVolume.value -= offset.y * 0.006;
                            self.controlView.volumeSlider.value = self.systemVolume.value;
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
            switch (self.panDirection) {
                case SJPanDirection_H:{
                    [self sliderDidEndDragging:self.controlView.sliderControl];
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


#pragma mark -

@implementation SJVideoPlayerControl (ControlViewState)

- (void)_controlViewUnknownStatus {
    self.controlView.hidden = YES;
    self.controlView.sliderControl.value = 0;
    self.controlView.draggingProgressView.value = 0;
    self.controlView.draggingTimeLabel.text = @"00:00";
    self.controlView.hiddenPreviewBtn = YES;
    self.controlView.hiddenMoreBtn = YES;
    self.controlView.previewImages = nil;
    self.controlView.hiddenControl = YES;
    self.controlView.hiddenBackBtn = NO;
    self.controlView.hiddenMoreSettingsView = YES;
    self.controlView.hiddenReplayBtn = YES;
    self.controlView.hiddenLoadFailedBtn = YES;
    self.controlView.hiddenControl = YES;
    self.controlView.hiddenDraggingProgress = YES;
    self.controlView.hiddenPlayBtn = YES;
}

- (void)_controlViewPrepareToPlayStatus {
    self.controlView.hidden = NO;
    self.controlView.hiddenLockBtn = YES;
    self.controlView.hiddenPlayBtn = YES;
    self.controlView.hiddenPauseBtn = NO;
    self.controlView.hiddenReplayBtn = YES;
    self.controlView.hiddenDraggingProgress = YES;
    self.controlView.hiddenLoadFailedBtn = YES;
    self.controlView.hiddenPreviewBtn = YES;
    self.controlView.hiddenPreview = YES;
    self.controlView.hiddenMoreBtn = YES;
    self.controlView.hiddenControl = YES;
}

- (void)_controlViewPlayingStatus {
    
    self.controlView.hiddenPlayBtn = YES;
    self.controlView.hiddenPauseBtn = NO;
    self.controlView.hiddenReplayBtn = YES;
    self.controlView.hiddenDraggingProgress = YES;
    self.controlView.hiddenLoadFailedBtn = YES;
    
    // 锁定
    if ( self.backstageRegistrar.isLock ) {
        self.controlView.hiddenControl = YES;
    }
    else {
        self.controlView.hiddenControl = NO;
    }
    
    // 小屏
    if ( !self.backstageRegistrar.fullScreen ) {
        self.controlView.hiddenPreviewBtn = YES;
        self.controlView.hiddenPreview = YES;
        self.controlView.hiddenMoreBtn = YES;
    }
    // 全屏
    else {
        self.controlView.hiddenMoreBtn = NO;
        if ( self.backstageRegistrar.generatedImages ) self.controlView.hiddenPreviewBtn = NO;
        else { self.controlView.hiddenPreviewBtn = YES; self.controlView.hiddenPreview = YES;}
    }
}

- (void)_controlViewPauseStatus {
    self.controlView.hidden = NO;
    self.controlView.hiddenPlayBtn = NO;
    self.controlView.hiddenPauseBtn = YES;
}

- (void)_controlViewPlayEndStatus {
    self.controlView.hidden = NO;
    self.controlView.hiddenReplayBtn = NO;
}

- (void)_controlViewPlayFailed {
    self.controlView.hiddenLoadFailedBtn = NO;
}

- (void)_controlViewSmallScreen {
    self.controlView.hiddenControl = NO;
    self.controlView.hiddenPreview = YES;
    self.controlView.hiddenMoreSettingsView = YES;
    self.controlView.hiddenMoreSettingsTwoLevelView = YES;
    self.controlView.hiddenMoreBtn = YES;
    self.controlView.hiddenPreviewBtn = YES;
    if ( self.backstageRegistrar.playingOnCell ) self.controlView.hiddenBackBtn = YES;
}

- (void)_controlViewFullScreen {
    self.controlView.hiddenControl = NO;
    self.controlView.hiddenBackBtn = NO;
    if ( self.backstageRegistrar.generatedImages ) self.controlView.hiddenPreviewBtn = NO;
    self.controlView.hiddenMoreBtn = NO;
}

- (void)_controlViewLockScreen {
    self.controlView.hiddenControl = YES;
    self.controlView.hiddenUnlockBtn = !(self.controlView.hiddenLockBtn = NO);
}

- (void)_controlViewUnlockScreen {
    self.controlView.hiddenControl = NO;
    self.controlView.hiddenUnlockBtn = !(self.controlView.hiddenLockBtn = YES);
}

- (void)_controlViewHidenMoreSettingsView {
    self.controlView.hiddenMoreSettingsView = YES;
}

- (void)_controlViewShowTwoMoreSettingsView {
    self.controlView.hiddenMoreSettingsView = YES;
    self.controlView.hiddenMoreSettingsTwoLevelView = NO;
}

- (void)_controlViewHiddenTwoMoreSettingsView {
    self.controlView.hiddenMoreSettingsTwoLevelView = YES;
}

- (void)_controlViewHiddenControl {
    self.controlView.hiddenControl = YES;
}

- (void)_controlViewControlLayerStateChanged {
    if ( self.controlView.hiddenControl ) {
        self.controlView.hiddenPreview = YES;
        self.controlView.hiddenLockContainerView = !self.backstageRegistrar.isLock;
    }
    else {
        self.controlView.hiddenLockContainerView = NO;
    }
    self.controlView.hiddenBottomProgressView = !self.controlView.hiddenControl;
}

- (void)_controlViewPreviewShowedOrHidden {
    self.controlView.hiddenControl = NO;
    self.controlView.hiddenPreview = !self.controlView.hiddenPreview;
    if ( !self.controlView.hiddenPreview )
        [self _resetTimer];
    else {
        if ( !self.controlView.hiddenControl ) [self.pointTimer fire];
    }
}

@end

