//
//  SJMediaPlaybackController.m
//  Pods
//
//  Created by 畅三江 on 2020/2/17.
//

#import "SJMediaPlaybackController.h"
#import "NSTimer+SJAssetAdd.h"

NS_ASSUME_NONNULL_BEGIN
///
/// 清晰度切换加载控制
///
///     当`definitionMediaPlayer`加载完成或失败后, 将会回调`completionHandler`
///
@interface SJDefinitionMediaPlayerLoader : NSObject
- (instancetype)initWithDefinitionMediaPlayer:(id<SJMediaPlayer>)definitionMediaPlayer
                    definitionMediaPlayerView:(UIView<SJMediaPlayerView> *)definitionMediaPlayerView
                                currentPlayer:(id<SJMediaPlayer>)currentPlayer
                            currentPlayerView:(UIView<SJMediaPlayerView> *)currentPlayerView
                            completionHandler:(void(^)(SJDefinitionMediaPlayerLoader *loader, BOOL isFinished))completionHandler;

@property (nonatomic, strong, readonly, nullable) id<SJMediaPlayer> definitionMediaPlayer;
@property (nonatomic, strong, readonly, nullable) UIView<SJMediaPlayerView> *definitionMediaPlayerView;
@property (nonatomic, strong, readonly, nullable) id<SJMediaPlayer> currentPlayer;
@property (nonatomic, strong, readonly, nullable) UIView<SJMediaPlayerView> *currentPlayerView;
- (void)cancel;
@end


@interface SJMediaPlayerTimeObserverItem : NSObject
- (instancetype)initWithInterval:(NSTimeInterval)interval player:(__weak id<SJMediaPlayer>)player currentTimeDidChangeExeBlock:(nonnull void (^)(NSTimeInterval time))currentTimeDidChangeExeBlock playableDurationDidChangeExeBlock:(nonnull void (^)(NSTimeInterval time))playableDurationDidChangeExeBlock durationDidChangeExeBlock:(nonnull void (^)(NSTimeInterval time))durationDidChangeExeBlock;
- (void)invalidate;
@end

@implementation SJMediaPlayerTimeObserverItem {
    void (^_currentTimeDidChangeExeBlock)(NSTimeInterval);
    void (^_playableDurationDidChangeExeBlock)(NSTimeInterval);
    void (^_durationDidChangeExeBlock)(NSTimeInterval);
    __weak id<SJMediaPlayer> _player;
    NSTimeInterval _interval;
    
    NSTimer *_timer;
    NSTimeInterval _currentTime;
}

- (instancetype)initWithInterval:(NSTimeInterval)interval player:(__weak id<SJMediaPlayer>)player currentTimeDidChangeExeBlock:(nonnull void (^)(NSTimeInterval))currentTimeDidChangeExeBlock playableDurationDidChangeExeBlock:(nonnull void (^)(NSTimeInterval))playableDurationDidChangeExeBlock durationDidChangeExeBlock:(nonnull void (^)(NSTimeInterval))durationDidChangeExeBlock {
    self = [super init];
    if ( self ) {
        _interval = interval;
        _player = player;
        _currentTimeDidChangeExeBlock = currentTimeDidChangeExeBlock;
        _playableDurationDidChangeExeBlock = playableDurationDidChangeExeBlock;
        _durationDidChangeExeBlock = durationDidChangeExeBlock;
        
        [self resumeOrPause];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(resumeOrPause) name:SJMediaPlayerTimeControlStatusDidChangeNotification object:player];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(durationDidChange) name:SJMediaPlayerDurationDidChangeNotification object:_player];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playableDurationDidChange) name:SJMediaPlayerPlayableDurationDidChangeNotification object:_player];
    }
    return self;
}

- (void)dealloc {
    [_timer invalidate];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)invalidate {
    [_timer invalidate];
    _timer = nil;
}

- (void)durationDidChange {
    if ( _durationDidChangeExeBlock ) _durationDidChangeExeBlock(_player.duration);
}

- (void)playableDurationDidChange {
    if ( _playableDurationDidChangeExeBlock ) _playableDurationDidChangeExeBlock(_player.playableDuration);
}

- (void)resumeOrPause {
    if ( _player.timeControlStatus == SJPlaybackTimeControlStatusPaused ) {
        [self invalidate];
    }
    else if ( _timer == nil ) {
        __weak typeof(self) _self = self;
        _timer = [NSTimer sj_timerWithTimeInterval:_interval repeats:YES usingBlock:^(NSTimer * _Nonnull timer) {
            __strong typeof(_self) self = _self;
            if ( !self ) { [timer invalidate]; return ; }
            [self _refresh];
        }];
        _timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:_interval];
        [NSRunLoop.mainRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}
 
- (void)_refresh {
    NSTimeInterval currentTime = _player.currentTime;
    if ( _currentTime != currentTime ) {
        _currentTime = currentTime;
        if ( _currentTimeDidChangeExeBlock ) _currentTimeDidChangeExeBlock(currentTime);
    }
}
@end

@interface SJMediaPlayerContentView : UIView
@property (nonatomic, strong, nullable) UIView <SJMediaPlayerView> *view;
@end

@implementation SJMediaPlayerContentView
- (void)setView:(nullable UIView<SJMediaPlayerView> *)view {
    if ( _view ) [_view removeFromSuperview];
    _view = view;
    if ( view != nil ) [self addSubview:view];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _view.frame = self.bounds;
}
@end

@interface SJMediaPlaybackController () {
    SJMediaPlayerContentView *_playerView;
}
@property (nonatomic) SJPlaybackTimeControlStatus timeControlStatus;
@property (nonatomic, nullable) SJWaitingReason reasonForWaitingToPlay;
@property (nonatomic, strong, nullable) id<SJMediaPlayer> currentPlayer;
@property (nonatomic, strong, nullable) id periodicTimeObserver;
@property (nonatomic, strong, nullable) SJDefinitionMediaPlayerLoader *definitionMediaPlayerLoader;
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *definitionMedia;
@end

@implementation SJMediaPlaybackController
@synthesize pauseWhenAppDidEnterBackground = _pauseWhenAppDidEnterBackground;
@synthesize periodicTimeInterval = _periodicTimeInterval;
@synthesize minBufferedDuration = _minBufferedDuration;
@synthesize delegate = _delegate;
@synthesize volume = _volume;
@synthesize rate = _rate;
@synthesize muted = _muted;
@synthesize media = _media;

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _rate = 1;
        _volume = 1;
        _pauseWhenAppDidEnterBackground = YES;
        _periodicTimeInterval = 0.5;
        [self _initObservations];
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    UIView *playerView = _playerView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [playerView removeFromSuperview];
    });
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)playerWithMedia:(SJVideoPlayerURLAsset *)media completionHandler:(void(^)(id<SJMediaPlayer> _Nullable player))completionHandler {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                                 userInfo:nil];
}

- (UIView<SJMediaPlayerView> *)playerViewWithPlayer:(id<SJMediaPlayer>)player {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                                 userInfo:nil];
}

- (void)receivedApplicationDidBecomeActiveNotification { }

- (void)receivedApplicationWillResignActiveNotification { }

- (void)receivedApplicationWillEnterForegroundNotification { }

- (void)receivedApplicationDidEnterBackgroundNotification {
    if ( self.pauseWhenAppDidEnterBackground )
        [self pause];
}

- (void)prepareToPlay {
    SJVideoPlayerURLAsset *media = _media;
    __weak typeof(self) _self = self;
    [self playerWithMedia:media completionHandler:^(id<SJMediaPlayer>  _Nullable player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.media != media ) return;
        if ( player == nil ) return;
        player.trialEndPosition = media.trialEndPosition;
        self.currentPlayer = player;
        self.currentPlayerView = [self playerViewWithPlayer:player];
    }];
}

#pragma mark -

- (void)pause {
    self.timeControlStatus = SJPlaybackTimeControlStatusPaused;
    [self.currentPlayer pause];
}

- (void)play {
    if ( self.assetStatus == SJAssetStatusFailed ) {
        [self refresh];
        return;
    }
    
    // no item to play
    if ( self.currentPlayer == nil ) {
        self.reasonForWaitingToPlay = SJWaitingWithNoAssetToPlayReason;
        self.timeControlStatus = SJPlaybackTimeControlStatusWaitingToPlay;
    }
    // play
    else {
        self.reasonForWaitingToPlay = SJWaitingWhileEvaluatingBufferingRateReason;
        self.timeControlStatus = SJPlaybackTimeControlStatusWaitingToPlay;
        self.isPlaybackFinished ? [self.currentPlayer replay] : [self.currentPlayer play];
        [self _toEvaluating];
    }
}

- (void)replay {
    [self play];
}

- (void)stop {
    [_definitionMediaPlayerLoader cancel];
    _definitionMediaPlayerLoader = nil;
    _definitionMedia = nil;
    [self _removePeriodicTimeObserver];
    [self.currentPlayerView removeFromSuperview];
    _playerView.view = nil;
    self.currentPlayer = nil;
    _media = nil;
    if ( self.timeControlStatus != SJPlaybackTimeControlStatusPaused )
        self.timeControlStatus = SJPlaybackTimeControlStatusPaused;
}

- (void)refresh {
    if ( self.currentPlayer.isPlayed && self.currentTime != 0 )
        self.media.startPosition = self.currentTime;
    self.currentPlayer = nil;
    [self prepareToPlay];
    [self play];
}

- (nullable UIImage *)screenshot {
    return [self.currentPlayer screenshot];
}

- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ _Nullable)(BOOL))completionHandler {
    [self seekToTime:CMTimeMakeWithSeconds(secs, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^ _Nullable)(BOOL))completionHandler {
    [self.currentPlayer seekToTime:time completionHandler:completionHandler];
}

- (void)switchVideoDefinition:(SJVideoPlayerURLAsset *)media {
    // clean
    if ( _definitionMediaPlayerLoader != nil ) {
        [_definitionMediaPlayerLoader cancel];
        _definitionMediaPlayerLoader = nil;
    }
    
    if ( !media || !self.currentPlayer ) return;
    
    self.definitionMedia = media;
    
    // reset status
    [self _definitionMedia:media switchStatusDidChange:SJDefinitionSwitchStatusUnknown];
    
    // begin
    [self _definitionMedia:media switchStatusDidChange:SJDefinitionSwitchStatusSwitching];

    // load
    __weak typeof(self) _self = self;
    [self playerWithMedia:media completionHandler:^(id<SJMediaPlayer>  _Nullable player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( media != self.definitionMedia ) return;
        
        id<SJMediaPlayer> definitionMediaPlayer = player;
        UIView<SJMediaPlayerView> *definitionMediaPlayerView = [self playerViewWithPlayer:player];
        
        id<SJMediaPlayer> currentPlayer = self.currentPlayer;
        UIView<SJMediaPlayerView> *currentPlayerView = self.currentPlayerView;

        self.definitionMediaPlayerLoader = [SJDefinitionMediaPlayerLoader.alloc initWithDefinitionMediaPlayer:definitionMediaPlayer definitionMediaPlayerView:definitionMediaPlayerView currentPlayer:currentPlayer currentPlayerView:currentPlayerView completionHandler:^(SJDefinitionMediaPlayerLoader * _Nonnull loader, BOOL isFinished) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( media != self.definitionMedia ) return;
            self.definitionMedia = nil;
            self.definitionMediaPlayerLoader = nil;
            if ( !isFinished ) {
                [self _definitionMedia:media switchStatusDidChange:SJDefinitionSwitchStatusFailed];
            }
            else {
                id<SJMediaPlayer> player = loader.definitionMediaPlayer;
                SJVideoPlayerURLAsset *newMedia = media;
                [self replaceMediaForDefinitionMedia:newMedia];
                
                id<SJMediaPlayer> oldPlayer = self.currentPlayer;
                id<SJMediaPlayer> newPlayer = player;
                self.currentPlayer = newPlayer;
                self.currentPlayerView = definitionMediaPlayerView;
                [oldPlayer pause];
                self.timeControlStatus != SJPlaybackTimeControlStatusPaused ? [newPlayer play] : [newPlayer pause];
                [self _definitionMedia:media switchStatusDidChange:SJDefinitionSwitchStatusFinished];
            }
        }];
    }];
}

- (SJAssetStatus)assetStatus {
    return self.currentPlayer.assetStatus;
}

- (NSTimeInterval)currentTime {
    return _currentPlayer.currentTime;
}

- (NSTimeInterval)duration {
    return _currentPlayer.duration;
}

- (NSTimeInterval)durationWatched {
    return 0;
}

- (nullable NSError *)error {
    return nil;
}

- (BOOL)isPlayed {
    return _currentPlayer.isPlayed;
}

- (BOOL)isReplayed {
    return _currentPlayer.isReplayed;
}

- (BOOL)isPlaybackFinished {
    return _currentPlayer.isPlaybackFinished;
}

- (nullable SJFinishedReason)finishedReason {
    return _currentPlayer.finishedReason;
}

- (NSTimeInterval)playableDuration {
    return _currentPlayer.playableDuration;
}

- (SJPlaybackType)playbackType {
    return SJPlaybackTypeUnknown;
}

- (SJMediaPlayerContentView *)playerView {
    if ( _playerView == nil ) {
        _playerView = [SJMediaPlayerContentView.alloc initWithFrame:CGRectZero];
    }
    return _playerView;
}

- (BOOL)isReadyForDisplay {
    return self.currentPlayerView.isReadyForDisplay;
}

- (CGSize)presentationSize {
    return _currentPlayer.presentationSize;
}

@synthesize videoGravity = _videoGravity;
- (void)setVideoGravity:(SJVideoGravity)videoGravity {
    _videoGravity = videoGravity ? : AVLayerVideoGravityResizeAspect;
    self.currentPlayerView.videoGravity = self.videoGravity;
}
- (SJVideoGravity)videoGravity {
    if ( _videoGravity == nil )
        return AVLayerVideoGravityResizeAspect;
    return _videoGravity;
}

- (void)setMedia:(nullable SJVideoPlayerURLAsset *)media {
    if ( _media != nil ) [self stop];
    _media = media;
}

- (void)replaceMediaForDefinitionMedia:(SJVideoPlayerURLAsset *)definitionMedia {
    _media = definitionMedia;
}

- (void)setPeriodicTimeInterval:(NSTimeInterval)periodicTimeInterval {
    _periodicTimeInterval = periodicTimeInterval;
    [self _removePeriodicTimeObserver];
    [self _addPeriodicTimeObserver];
}
 
- (void)setRate:(float)rate {
    _rate = rate;
    if ( self.timeControlStatus == SJPlaybackTimeControlStatusPaused ) [self play];
    _currentPlayer.rate = rate;
}

- (void)setVolume:(float)volume {
    _volume = volume;
    _currentPlayer.volume = volume;
}

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    _currentPlayer.muted = muted;
}

- (void)setCurrentPlayer:(nullable id<SJMediaPlayer>)currentPlayer {
    _currentPlayer = currentPlayer;
    if ( currentPlayer != nil ) {
        currentPlayer.volume = self.volume;
        currentPlayer.muted = self.muted;
        if ( self.timeControlStatus != SJPlaybackTimeControlStatusPaused ) currentPlayer.rate = self.rate;
        [self _addPeriodicTimeObserver];
        [currentPlayer report];
    }
}

- (void)setCurrentPlayerView:(__kindof UIView<SJMediaPlayerView> * _Nullable)currentPlayerView {
    currentPlayerView.videoGravity = self.videoGravity;
    _playerView.view = currentPlayerView;
}
- (nullable __kindof UIView<SJMediaPlayerView> *)currentPlayerView {
    return _playerView.view;
}

- (void)setTimeControlStatus:(SJPlaybackTimeControlStatus)timeControlStatus {
    if ( timeControlStatus == SJPlaybackTimeControlStatusPaused ) _reasonForWaitingToPlay = nil;
    _timeControlStatus = timeControlStatus;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].idleTimerDisabled = (timeControlStatus != SJPlaybackTimeControlStatusPaused);
        if ( [self.delegate respondsToSelector:@selector(playbackController:timeControlStatusDidChange:)] ) {
            [self.delegate playbackController:self timeControlStatusDidChange:timeControlStatus];
        }
    });
}

#pragma mark -

- (void)_toEvaluating {
    if ( self.assetStatus == SJAssetStatusFailed ) {
        self.timeControlStatus = SJPlaybackTimeControlStatusPaused;
    }
    
    if ( self.currentPlayer.isPlaybackFinished ) {
        self.timeControlStatus = SJPlaybackTimeControlStatusPaused;
    }
    
    if ( self.timeControlStatus == SJPlaybackTimeControlStatusPaused ) {
        return;
    }
    
    // 处于准备|失败中
    if ( self.currentPlayer.assetStatus != SJAssetStatusReadyToPlay )
        return;

    if ( self.reasonForWaitingToPlay == SJWaitingWithNoAssetToPlayReason )
        [self.currentPlayer play];
    
    if ( self.timeControlStatus != self.currentPlayer.timeControlStatus ||
         self.reasonForWaitingToPlay != self.currentPlayer.reasonForWaitingToPlay ) {
        if ( self.currentPlayer.timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
            self.reasonForWaitingToPlay = self.currentPlayer.reasonForWaitingToPlay;
            self.timeControlStatus = self.currentPlayer.timeControlStatus;
        }
    }
}

- (void)_definitionMedia:(id<SJMediaModelProtocol>)media switchStatusDidChange:(SJDefinitionSwitchStatus)status {
    if ( [self.delegate respondsToSelector:@selector(playbackController:switchingDefinitionStatusDidChange:media:)] ) {
        [self.delegate playbackController:self switchingDefinitionStatusDidChange:status media:media];
    }

#ifdef DEBUG
    char *str = nil;
    switch ( status ) {
        case SJDefinitionSwitchStatusUnknown:
            str = "Unknown";
            break;
        case SJDefinitionSwitchStatusSwitching:
            str = "Switching";
            break;
        case SJDefinitionSwitchStatusFinished:
            str = "Finished";
            break;
        case SJDefinitionSwitchStatusFailed:
            str = "Failed";
            break;
    }
    printf("SJMediaPlaybackController<%p>.switchStatus = %s\n", self, str);
#endif
}

- (void)_addPeriodicTimeObserver {
    __weak typeof(self) _self = self;
    _periodicTimeObserver = [SJMediaPlayerTimeObserverItem.alloc initWithInterval:_periodicTimeInterval player:self.currentPlayer currentTimeDidChangeExeBlock:^(NSTimeInterval time) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(playbackController:currentTimeDidChange:)] ) {
            [self.delegate playbackController:self currentTimeDidChange:time];
        }
    } playableDurationDidChangeExeBlock:^(NSTimeInterval time) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(playbackController:playableDurationDidChange:)] ) {
            [self.delegate playbackController:self playableDurationDidChange:time];
        }
    } durationDidChangeExeBlock:^(NSTimeInterval time) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(playbackController:durationDidChange:)] ) {
            [self.delegate playbackController:self durationDidChange:time];
        }
    }];
}

- (void)_removePeriodicTimeObserver {
    _periodicTimeObserver = nil;
}

- (void)_initObservations {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerAssetStatusDidChange:) name:SJMediaPlayerAssetStatusDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerTimeControlStatusDidChange:) name:SJMediaPlayerTimeControlStatusDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playbackDidFinish:) name:SJMediaPlayerPlaybackDidFinishNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerPresentationSizeDidChange:) name:SJMediaPlayerPresentationSizeDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerViewReadyForDisplay:) name:SJMediaPlayerViewReadyForDisplayNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerDidReplay:) name:SJMediaPlayerDidReplayNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(audioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(audioSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receivedApplicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receivedApplicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receivedApplicationDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)playerAssetStatusDidChange:(NSNotification *)note {
    if ( self.currentPlayer == note.object ) {
        [self _toEvaluating];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( [self.delegate respondsToSelector:@selector(playbackController:assetStatusDidChange:)] ) {
                [self.delegate playbackController:self assetStatusDidChange:self.assetStatus];
            }
        });
    }
}

- (void)playerTimeControlStatusDidChange:(NSNotification *)note {
    if ( self.currentPlayer == note.object ) {
        [self _toEvaluating];
    }
}

- (void)playbackDidFinish:(NSNotification *)note {
    if ( self.currentPlayer == note.object ) {
        [self _toEvaluating];
        if ( [self.delegate respondsToSelector:@selector(playbackController:playbackDidFinish:)] ) {
            [self.delegate playbackController:self playbackDidFinish:self.finishedReason];
        }
    }
}

- (void)playerPresentationSizeDidChange:(NSNotification *)note {
    if ( self.currentPlayer == note.object ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:presentationSizeDidChange:)] ) {
            [self.delegate playbackController:self presentationSizeDidChange:self.presentationSize];
        }
    }
}

- (void)playerViewReadyForDisplay:(NSNotification *)note {
    if ( self.currentPlayerView == note.object ) {
        if ( [self.delegate respondsToSelector:@selector(playbackControllerIsReadyForDisplay:)] ) {
            [self.delegate playbackControllerIsReadyForDisplay:self];
        }
    }
}

- (void)playerDidReplay:(NSNotification *)note {
    if ( self.currentPlayer == note.object ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:didReplay:)] ) {
            [self.delegate playbackController:self didReplay:self.media];
        }
    }
}

- (void)audioSessionInterruption:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *info = note.userInfo;
        if( (AVAudioSessionInterruptionType)[info[AVAudioSessionInterruptionTypeKey] integerValue] == AVAudioSessionInterruptionTypeBegan ) {
            [self pause];
        }
    });
}

- (void)audioSessionRouteChange:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *interuptionDict = note.userInfo;
        NSInteger reason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
        if ( reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable ) {
            [self pause];
        }
    });
}

@end

#pragma mark -


@interface SJDefinitionMediaPlayerLoader () {
    void(^_completionHandler)(SJDefinitionMediaPlayerLoader *loader, BOOL isFinished);
    BOOL _isSeeking;
}
@end

@implementation SJDefinitionMediaPlayerLoader
- (instancetype)initWithDefinitionMediaPlayer:(id<SJMediaPlayer>)definitionMediaPlayer
                    definitionMediaPlayerView:(UIView<SJMediaPlayerView> *)definitionMediaPlayerView
                                currentPlayer:(id<SJMediaPlayer>)currentPlayer
                            currentPlayerView:(UIView<SJMediaPlayerView> *)currentPlayerView
                            completionHandler:(void(^)(SJDefinitionMediaPlayerLoader *loader, BOOL isFinished))completionHandler {
    self = [super init];
    if ( self ) {
        _definitionMediaPlayer = definitionMediaPlayer;
        _definitionMediaPlayerView = definitionMediaPlayerView;
        
        _currentPlayer = currentPlayer;
        _currentPlayerView = currentPlayerView;
        
        _completionHandler = completionHandler;
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_statusDidChange) name:SJMediaPlayerAssetStatusDidChangeNotification object:definitionMediaPlayer];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_statusDidChange) name:SJMediaPlayerViewReadyForDisplayNotification object:definitionMediaPlayerView];

        UIView *superview = currentPlayerView.superview;
        definitionMediaPlayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        definitionMediaPlayerView.frame = superview.bounds;
        [superview insertSubview:definitionMediaPlayerView atIndex:0];

        _definitionMediaPlayer.muted = YES;
        [_definitionMediaPlayer play];
        
        [self _statusDidChange];
    }
    return self;
}

- (void)_statusDidChange {
    switch ( _definitionMediaPlayer.assetStatus ) {
        case SJAssetStatusUnknown:
        case SJAssetStatusPreparing:
            break;
        case SJAssetStatusReadyToPlay: {
            if ( _definitionMediaPlayerView.isReadyForDisplay && _isSeeking == NO ) {
                [self _seekToCurPos];
            }
        }
            break;
        case SJAssetStatusFailed:
            [self _didCompleteLoad:NO];
            break;
    }
}

- (void)_seekToCurPos {
    _isSeeking = YES;
    __weak typeof(self) _self = self;
    [_definitionMediaPlayer seekToTime:CMTimeMakeWithSeconds(_currentPlayer.currentTime, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _didCompleteLoad:finished];
    }];
}

- (void)_didCompleteLoad:(BOOL)result {
    if ( result ) {
        [_definitionMediaPlayerView removeFromSuperview];
        _definitionMediaPlayer.muted = NO;
    }
    else {
        [_definitionMediaPlayerView removeFromSuperview];
        [_definitionMediaPlayer pause];
        _definitionMediaPlayer = nil;
    }
    if ( _completionHandler ) _completionHandler(self, result);
    _completionHandler = nil;
}

- (void)cancel {
    _completionHandler = nil;
    [_definitionMediaPlayerView removeFromSuperview];
    _definitionMediaPlayer = nil;
}
@end

NSNotificationName const SJMediaPlayerAssetStatusDidChangeNotification = @"SJMediaPlayerAssetStatusDidChangeNotification";
NSNotificationName const SJMediaPlayerTimeControlStatusDidChangeNotification = @"SJMediaPlayerTimeControlStatusDidChangeNotification";
NSNotificationName const SJMediaPlayerPresentationSizeDidChangeNotification = @"SJMediaPlayerPresentationSizeDidChangeNotification";
NSNotificationName const SJMediaPlayerPlaybackDidFinishNotification = @"SJMediaPlayerPlaybackDidFinishNotification";
NSNotificationName const SJMediaPlayerDidReplayNotification = @"SJMediaPlayerDidReplayNotification";
NSNotificationName const SJMediaPlayerDurationDidChangeNotification = @"SJMediaPlayerDurationDidChangeNotification";
NSNotificationName const SJMediaPlayerPlayableDurationDidChangeNotification = @"SJMediaPlayerPlayableDurationDidChangeNotification";

NSNotificationName const SJMediaPlayerViewReadyForDisplayNotification = @"SJMediaPlayerViewReadyForDisplayNotification";
NSNotificationName const SJMediaPlayerPlaybackTypeDidChangeNotification = @"SJMediaPlayerPlaybackTypeDidChangeNotification";
NS_ASSUME_NONNULL_END
