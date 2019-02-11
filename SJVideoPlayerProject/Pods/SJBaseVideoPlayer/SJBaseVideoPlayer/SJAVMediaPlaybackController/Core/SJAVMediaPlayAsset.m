//
//  SJAVMediaPlayAsset.m
//  SJVideoPlayerAssetCarrier
//
//  Created by BlueDancer on 2018/6/28.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJAVMediaPlayAsset.h"
#import "NSTimer+SJAssetAdd.h"

#if __has_include(<SJObserverHelper/NSObject+SJObserverHelper.h>)
#import <SJObserverHelper/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
inline static bool isFloatZero(float value) {
    return fabsf(value) <= 0.00001f;
}

static NSNotificationName const SJAVMediaPlayerItemDidPlayToEndTimeNotification = @"SJAVMediaPlayerItemDidPlayToEndTimeNotification";
static NSNotificationName const SJAVMediaPlaybackTimeDidChangeNotification = @"SJAVMediaPlaybackTimeDidChangeNotification";
static NSNotificationName const SJAVMediaPlaybackDurationDidChangeNotificationn = @"SJAVMediaPlaybackDurationDidChangeNotificationn";
static NSNotificationName const SJAVMediaLoadedTimeRangesDidChangeNotification = @"SJAVMediaLoadedTimeRangesDidChangeNotification";
static NSNotificationName const SJAVMediaPlaybackBufferStatusDidChangeNotification = @"SJAVMediaPlaybackBufferStatusDidChangeNotification";
static NSNotificationName const SJAVMediakPresentationSizeDidChangeNotification = @"SJAVMediakPresentationSizeDidChangeNotification";
static NSNotificationName const SJAVMediaPlayerItemStatusDidChangeNotification = @"SJAVMediaPlayerItemStatusDidChangeNotification";

@interface SJAVMediaPlayAsset()
@property (nonatomic, strong, nullable) AVURLAsset *URLAsset;
@property (nonatomic, strong, nullable) AVPlayerItem *playerItem;
@property (nonatomic, strong, nullable) AVPlayer *player;

@property (nonatomic) CMTime duration;
@property (nonatomic) CMTime currentTime;
@property (nonatomic) CMTimeRange bufferLoadedTime;
@property (nonatomic) SJPlayerBufferStatus bufferStatus;
@property (nonatomic) CGSize presentationSize;
@property (nonatomic) AVPlayerItemStatus playerItemStatus;
@end

@implementation SJAVMediaPlayAsset {
    id _noteToken;
    id _currentTimeNoteToken;
    id _AVPLayerItemDidPlayToEndNoteToken;
}

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithURL:URL specifyStartTime:0];
}

- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime {
    NSParameterAssert(URL);
    
    self = [super init];
    if ( !self ) return nil;
    _URL = URL;
    _specifyStartTime = specifyStartTime;
    [self _initializeAVPlayer];
    return self;
}

- (instancetype)initWithAVAsset:(__kindof AVAsset *)asset specifyStartTime:(NSTimeInterval)specifyStartTime {
    NSParameterAssert(asset);
    
    self = [super init];
    if ( !self ) return nil;
    _specifyStartTime = specifyStartTime;
    _URLAsset = asset;
    [self _initializeAVPlayer];
    return self;
}

- (void)dealloc {
    if ( _currentTimeNoteToken ) [_player removeTimeObserver:_currentTimeNoteToken];
    if ( _noteToken ) [NSNotificationCenter.defaultCenter removeObserver:_noteToken];
    if ( _AVPLayerItemDidPlayToEndNoteToken ) [NSNotificationCenter.defaultCenter removeObserver:_AVPLayerItemDidPlayToEndNoteToken];
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}

- (void)_initializeAVPlayer {
    _currentTime = kCMTimeZero;
    _duration = kCMTimeZero;
    _bufferLoadedTime = kCMTimeRangeZero;
    
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        AVURLAsset *URLAsset = self.URLAsset?:[AVURLAsset assetWithURL:self.URL];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:URLAsset];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        self.URLAsset = URLAsset;
        self.playerItem = playerItem;
        self.player = player;
        if (@available(iOS 10.0, *) ) {
            if ( ![self.URL.pathExtension isEqualToString:@"m3u8"] ) self.player.automaticallyWaitsToMinimizeStalling = NO;
        }
        [self _observeProperties];
    });
}

static NSString *kLoadedTimeRanges = @"loadedTimeRanges";
static NSString *kDuration = @"duration";
static NSString *kPlaybackBufferEmpty = @"playbackBufferEmpty";
static NSString *kPresentationSize = @"presentationSize";
static NSString *kPlayerItemStatus = @"status";

static NSString *kPlaybackLikelyToKeeyUp = @"playbackLikelyToKeepUp";
static NSString *kPlaybackBufferFull = @"playbackBufferFull";
static NSString *kRate = @"rate";

- (void)_observeProperties {
    [_playerItem sj_addObserver:self forKeyPath:kLoadedTimeRanges context:&kLoadedTimeRanges];
    [_playerItem sj_addObserver:self forKeyPath:kDuration context:&kDuration];
    [_playerItem sj_addObserver:self forKeyPath:kPlaybackBufferEmpty context:&kPlaybackBufferEmpty];
    [_playerItem sj_addObserver:self forKeyPath:kPresentationSize context:&kPresentationSize];
    [_playerItem sj_addObserver:self forKeyPath:kPlayerItemStatus context:&kPlayerItemStatus];
    [_playerItem sj_addObserver:self forKeyPath:kPlaybackLikelyToKeeyUp context:&kPlaybackLikelyToKeeyUp];
    [_playerItem sj_addObserver:self forKeyPath:kPlaybackBufferFull context:&kPlaybackBufferFull];
    [_player     sj_addObserver:self forKeyPath:kRate context:&kRate];
    
    __weak typeof(self) _self = self;
    _currentTimeNoteToken = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _updateCurrentTime:time];
    }];
    
    _AVPLayerItemDidPlayToEndNoteToken =
    [NSNotificationCenter.defaultCenter addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [NSNotificationCenter.defaultCenter postNotificationName:SJAVMediaPlayerItemDidPlayToEndTimeNotification object:self];
    }];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    id value_new = change[NSKeyValueChangeNewKey];
    id value_old = change[NSKeyValueChangeOldKey];
    if ( value_new == value_old ) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( context == &kLoadedTimeRanges ) {
            [self _updateBufferLoadedTime];
            [self _updateBufferStatus];
        }
        else if ( context == &kPlayerItemStatus ) {
            [self _updatePlayerItemStatus];
#ifdef SJ_MAC
            //printf("\n:--<%p>.kPlayerItemStatus %ld \n", self, (long)_playerItem.status);
#endif
        }
        else if ( context == &kDuration ) {
            [self _updateDuration:[value_new CMTimeValue]];
        }
        else if ( context == &kPresentationSize ) {
            [self _updatePresentationSize];
        }
        else if ( context == &kPlaybackBufferEmpty ) {
            [self _updateBufferStatus];
#ifdef SJ_MAC
            //printf("\n:--<%p>.kPlaybackBufferEmpty %d \n", self, _playerItem.isPlaybackBufferEmpty);
#endif
        }
        else if ( context == &kPlaybackBufferFull ) {
            [self _updateBufferStatus];
#ifdef SJ_MAC
            //printf("\n:--<%p>.kPlaybackBufferFull %d \n", self, _playerItem.isPlaybackBufferFull);
#endif
        }
        else if ( context == &kPlaybackLikelyToKeeyUp ) {
            [self _updateBufferStatus];
#ifdef SJ_MAC
            //printf("\n:--<%p>.kPlaybackLikelyToKeeyUp %d \n", self, _playerItem.isPlaybackLikelyToKeepUp);
#endif
        }
        else if ( context == &kRate ) {
            [self _updateBufferStatus];
            
#ifdef SJ_MAC
            //printf("\n:--<%p>.kRate %lf \n", self, [change[NSKeyValueChangeNewKey] doubleValue]);
#endif
        }
    });
}

- (void)_updateCurrentTime:(CMTime)time {
    int32_t result = CMTimeCompare(_currentTime, time);
    if ( result != 0 ) {
        _currentTime = time;
        [NSNotificationCenter.defaultCenter postNotificationName:SJAVMediaPlaybackTimeDidChangeNotification object:self];
    }
}

- (void)_updateDuration:(CMTime)duration {
    int32_t result = CMTimeCompare(_duration, duration);
    if ( result != 0 ) {
        _duration = duration;
        [NSNotificationCenter.defaultCenter postNotificationName:SJAVMediaPlaybackDurationDidChangeNotificationn object:self];
    }
}

- (void)_updateBufferLoadedTime {
    CMTimeRange range = _playerItem.loadedTimeRanges.firstObject.CMTimeRangeValue;
    Boolean result = CMTimeRangeEqual(_bufferLoadedTime, range);
    if ( false == result ) {
        _bufferLoadedTime = range;
        [NSNotificationCenter.defaultCenter postNotificationName:SJAVMediaLoadedTimeRangesDidChangeNotification object:self];
    }
}

- (void)_updateBufferStatus {
    SJPlayerBufferStatus status = SJPlayerBufferStatusUnknown;
    float rate = self.player.rate;
    if ( self.playerItem.status == AVPlayerItemStatusReadyToPlay ) {
        BOOL isPlaybackBufferEmpty = self.playerItem.isPlaybackBufferEmpty;
        BOOL isPlaybackBufferFull = self.playerItem.isPlaybackBufferFull;
        BOOL isPre_buf = NO;
        if ( !isPlaybackBufferEmpty || [self.URLAsset.URL isFileURL] ) {
            CMTimeRange range = [self.playerItem.loadedTimeRanges.firstObject CMTimeRangeValue];
            NSTimeInterval currentTime = CMTimeGetSeconds(self.playerItem.currentTime);
            NSTimeInterval bufferTime = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
            isPre_buf = (bufferTime > currentTime) && CMTimeGetSeconds(range.duration) > 0.1;
        }
        
        if ( isPre_buf || isPlaybackBufferFull ) {
            status = SJPlayerBufferStatusPlayable;
        }
        else {
            status = SJPlayerBufferStatusUnplayable;
        }
    }
    
    if ( status != self.bufferStatus || ( status == SJPlayerBufferStatusPlayable && isFloatZero(rate)) ) {
        self.bufferStatus = status;
        [NSNotificationCenter.defaultCenter postNotificationName:SJAVMediaPlaybackBufferStatusDidChangeNotification object:self];
    }
}

- (void)_updatePresentationSize {
    CGSize size = _playerItem.presentationSize;
    if ( !CGSizeEqualToSize(_presentationSize, size) ) {
        _presentationSize = size;
        [NSNotificationCenter.defaultCenter postNotificationName:SJAVMediakPresentationSizeDidChangeNotification object:self];
    }
}

- (void)_updatePlayerItemStatus {
    AVPlayerItemStatus status = _playerItem.status;
    if ( status != _playerItemStatus ) {
        _playerItemStatus = status;
        [NSNotificationCenter.defaultCenter postNotificationName:SJAVMediaPlayerItemStatusDidChangeNotification object:self];
    }
}
@end


#pragma mark -

@interface SJAVMediaPlayAssetPropertiesObserver()
@property (nonatomic, weak, nullable) SJAVMediaPlayAsset *playerAsset;
@property (nonatomic) SJPlayerBufferStatus bufferStatus;
@end

@implementation SJAVMediaPlayAssetPropertiesObserver {
    id _playerItemDidPlayToEndTimeNoteToken;
    id _playbackTimeDidChangeNoteToken;
    id _durationDidChangeNoteToken;
    id _loadedTimeRangesDidChangeNoteToken;
    id _bufferStatusDidChangeNoteToken;
    id _presentationSizeDidChangeNoteToken;
    id _playerItemStatusDidChangeNoteToken;
}

- (instancetype)initWithPlayerAsset:(SJAVMediaPlayAsset *)playerAsset {
    self = [super init];
    if ( !self ) return nil;
    _playerAsset = playerAsset;
    
    __weak typeof(self) _self = self;
    _playerItemDidPlayToEndTimeNoteToken = [NSNotificationCenter.defaultCenter addObserverForName:SJAVMediaPlayerItemDidPlayToEndTimeNotification object:playerAsset queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.delegate respondsToSelector:@selector(playDidToEndForObserver:)] ) {
            [self.delegate playDidToEndForObserver:self];
        }
    }];
    
    _playbackTimeDidChangeNoteToken = [NSNotificationCenter.defaultCenter addObserverForName:SJAVMediaPlaybackTimeDidChangeNotification object:playerAsset queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.delegate respondsToSelector:@selector(observer:currentTimeDidChange:)] ) {
            [self.delegate observer:self currentTimeDidChange:self.currentTime];
        }
    }];
    
    _durationDidChangeNoteToken = [NSNotificationCenter.defaultCenter addObserverForName:SJAVMediaPlaybackDurationDidChangeNotificationn object:playerAsset queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.delegate respondsToSelector:@selector(observer:durationDidChange:)] ) {
            [self.delegate observer:self durationDidChange:self.duration];
        }
    }];
    
    _loadedTimeRangesDidChangeNoteToken = [NSNotificationCenter.defaultCenter addObserverForName:SJAVMediaLoadedTimeRangesDidChangeNotification object:playerAsset queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.delegate respondsToSelector:@selector(observer:bufferLoadedTimeDidChange:)] ) {
            [self.delegate observer:self bufferLoadedTimeDidChange:self.bufferLoadedTime];
        }
    }];
    
    _bufferStatusDidChangeNoteToken = [NSNotificationCenter.defaultCenter addObserverForName:SJAVMediaPlaybackBufferStatusDidChangeNotification object:playerAsset queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.delegate respondsToSelector:@selector(observer:bufferStatusDidChange:)] ) {
            [self.delegate observer:self bufferStatusDidChange:self.bufferStatus];
        }
    }];
    
    _presentationSizeDidChangeNoteToken = [NSNotificationCenter.defaultCenter addObserverForName:SJAVMediakPresentationSizeDidChangeNotification object:playerAsset queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.delegate respondsToSelector:@selector(observer:presentationSizeDidChange:)] ) {
            [self.delegate observer:self presentationSizeDidChange:self.presentationSize];
        }
    }];
    
    _playerItemStatusDidChangeNoteToken = [NSNotificationCenter.defaultCenter addObserverForName:SJAVMediaPlayerItemStatusDidChangeNotification object:playerAsset queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.delegate respondsToSelector:@selector(observer:playerItemStatusDidChange:)] ) {
            [self.delegate observer:self playerItemStatusDidChange:self.playerItemStatus];
        }
    }];

    return self;
}

- (void)dealloc {
    if ( _playerItemDidPlayToEndTimeNoteToken )
        [NSNotificationCenter.defaultCenter removeObserver:_playerItemDidPlayToEndTimeNoteToken];
    
    if ( _playbackTimeDidChangeNoteToken )
        [NSNotificationCenter.defaultCenter removeObserver:_playbackTimeDidChangeNoteToken];
    
    if ( _durationDidChangeNoteToken )
        [NSNotificationCenter.defaultCenter removeObserver:_durationDidChangeNoteToken];
    
    if ( _loadedTimeRangesDidChangeNoteToken )
        [NSNotificationCenter.defaultCenter removeObserver:_loadedTimeRangesDidChangeNoteToken];
    
    if ( _bufferStatusDidChangeNoteToken )
        [NSNotificationCenter.defaultCenter removeObserver:_bufferStatusDidChangeNoteToken];
    
    if ( _presentationSizeDidChangeNoteToken )
        [NSNotificationCenter.defaultCenter removeObserver:_presentationSizeDidChangeNoteToken];
    
    if ( _playerItemStatusDidChangeNoteToken )
        [NSNotificationCenter.defaultCenter removeObserver:_playerItemStatusDidChangeNoteToken];
}

- (AVPlayerItemStatus)playerItemStatus {
    return _playerAsset.playerItemStatus;
}

- (SJPlayerBufferStatus)bufferStatus {
    return _playerAsset.bufferStatus;
}

- (NSTimeInterval)bufferLoadedTime {
    CMTimeRange range = _playerAsset.bufferLoadedTime;
    return CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
}

- (NSTimeInterval)currentTime {
    return CMTimeGetSeconds(_playerAsset.currentTime);
}

- (NSTimeInterval)duration {
    return CMTimeGetSeconds(_playerAsset.duration);
}

- (CGSize)presentationSize {
    return _playerAsset.presentationSize;
}
@end

NS_ASSUME_NONNULL_END
