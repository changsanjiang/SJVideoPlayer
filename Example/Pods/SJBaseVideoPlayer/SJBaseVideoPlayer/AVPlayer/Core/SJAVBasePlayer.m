//
//  SJAVBasePlayer.m
//  SJUIKit
//
//  Created by 畅三江 on 2019/8/26.
//

#import "SJAVBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVBasePlayer ()
@property (nonatomic, nullable) SJWaitingReason sj_reasonForWaitingToPlay;
@property (nonatomic) SJPlaybackTimeControlStatus sj_timeControlStatus;

@property (nonatomic, strong, nullable) NSError *sj_failedToPlayEndTimeError;
@property (nonatomic) SJAssetStatus sj_assetStatus;

@property (nonatomic) SJSeekingInfo seekingInfo;

@property (nonatomic, strong) SJAVBasePlayerItemObserver *sj_itemObsever;

@property (nonatomic, strong, readonly) NSMutableArray *sj_periodicTimeObservers;
@end

@implementation SJAVBasePlayer
static NSString *kStatus = @"status";
static NSString *kTimeControlStatus = @"timeControlStatus";

- (nullable instancetype)initWithBasePlayerItem:(SJAVBasePlayerItem *)item {
    if ( item == nil ) return nil;
    self = [super initWithPlayerItem:item];
    if ( self ) {
        self.sj_assetStatus = SJAssetStatusPreparing;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self _sjbase_initItemObserver];
            [self _sjbase_initObservations];
        });
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
    if ( _sj_periodicTimeObservers.count != 0 ) {
        for ( id observer in _sj_periodicTimeObservers )
            [super removeTimeObserver:observer];
    }
    
    [self removeObserver:self forKeyPath:kStatus];
    if ( @available(iOS 10.0, *) ) {
        [self removeObserver:self forKeyPath:kTimeControlStatus];
    }
}

- (id)addPeriodicTimeObserverForInterval:(CMTime)interval queue:(nullable dispatch_queue_t)queue usingBlock:(void (^)(CMTime))block {
    id observer = [super addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:block];
    [self.sj_periodicTimeObservers addObject:observer];
    return observer;
}

- (id)addBoundaryTimeObserverForTimes:(NSArray<NSValue *> *)times queue:(nullable dispatch_queue_t)queue usingBlock:(void (^)(void))block {
    id observer = [super addBoundaryTimeObserverForTimes:times queue:queue usingBlock:block];
    [self.sj_periodicTimeObservers addObject:observer];
    return observer;
}

- (void)removeTimeObserver:(id)observer {
    if ( [_sj_periodicTimeObservers containsObject:observer] ) {
        [_sj_periodicTimeObservers removeObject:observer];
        [self removeTimeObserver:observer];
    }
}

- (nullable NSError *)sj_error {
    if ( self.error != nil ) {
        return self.error;
    }
    
    if ( self.currentItem.error != nil ) {
        return self.currentItem.error;
    }
    
    return self.sj_failedToPlayEndTimeError;
}

- (void)play {
    if ( @available(iOS 10.0, *) ) {
        [super play];
    }
    else {
        self.sj_reasonForWaitingToPlay = SJWaitingWhileEvaluatingBufferingRateReason;
        self.sj_timeControlStatus = SJPlaybackTimeControlStatusWaitingToPlay;
        [super play];
    }
}

- (void)sj_playImmediatelyAtRate:(float)rate {
    if ( @available(iOS 10.0, *) ) {
        [super playImmediatelyAtRate:rate];
    }
    else {
        self.rate = rate;
    }
}

- (void)setRate:(float)rate {
    [super setRate:rate];
    
    if ( @available(iOS 10.0, *) ) { }
    else {
        if ( rate == 0 ) {
            if ( self.sj_timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
                [self pause];
            }
        }
        else if ( self.sj_timeControlStatus != SJPlaybackTimeControlStatusPlaying ) {
            [self _sjbase_toEvaluating];
        }
    }
}

- (void)pause {
    if ( @available(iOS 10.0, *) ) {
        [super pause];
    }
    else {
        self.sj_reasonForWaitingToPlay = nil;
        self.sj_timeControlStatus = SJPlaybackTimeControlStatusPaused;
        [super pause];
    }
}

- (void)seekToTime:(CMTime)time {
    [self seekToTime:time toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter {
    [self seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:^(BOOL finished) { }];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL))completionHandler {
    if ( self.currentItem.status != AVPlayerItemStatusReadyToPlay ) {
        if ( completionHandler ) {
            completionHandler(NO);
        }
        return;
    }
 
    [self _willSeeking:time];
    __weak typeof(self) _self = self;
    [super seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _didEndSeeking];
        if ( completionHandler ) completionHandler(finished);
    }];
}

- (CMTime)currentTime {
    if ( _seekingInfo.isSeeking )
        return _seekingInfo.time;
    return [super currentTime];
}

- (void)_willSeeking:(CMTime)time {
    _seekingInfo.time = time;
    _seekingInfo.isSeeking = YES;
}

- (void)_didEndSeeking {
    _seekingInfo.time = kCMTimeZero;
    _seekingInfo.isSeeking = NO;
}

#pragma mark -

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    __weak typeof(self) _self = self;
    if ( context == &kStatus ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _sjbase_refreshPlayerStatus];
        });
    }
    else if ( context == &kTimeControlStatus ) {
        if ( @available(iOS 10.0, *) ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( self.reasonForWaitingToPlay == AVPlayerWaitingWithNoItemToPlayReason )
                    return;
                
                SJWaitingReason reason = nil;
                SJPlaybackTimeControlStatus status = (NSInteger)self.timeControlStatus;
                if ( self.sj_error != nil )
                    status = SJPlaybackTimeControlStatusPaused;
                else if ( self.reasonForWaitingToPlay == AVPlayerWaitingToMinimizeStallsReason )
                    reason = SJWaitingToMinimizeStallsReason;
                else if ( self.reasonForWaitingToPlay == AVPlayerWaitingWhileEvaluatingBufferingRateReason )
                    reason = SJWaitingWhileEvaluatingBufferingRateReason;
                else if ( self.reasonForWaitingToPlay == AVPlayerWaitingWithNoItemToPlayReason )
                    reason = SJWaitingWithNoAssetToPlayReason;
                
                if ( status != self.sj_timeControlStatus || reason != self.sj_reasonForWaitingToPlay ) {
                    self.sj_reasonForWaitingToPlay = reason;
                    self.sj_timeControlStatus = status;
                }
            });
        }
    }
}

- (void)_sjbase_initObservations {
    NSKeyValueObservingOptions ops = NSKeyValueObservingOptionNew;
    [self addObserver:self forKeyPath:kStatus options:ops context:&kStatus];
    if ( @available(iOS 10.0, *) ) {
        [self addObserver:self forKeyPath:kTimeControlStatus options:ops context:&kTimeControlStatus];
    }
}

- (void)_sjbase_initItemObserver {
#ifdef DEBUG
    NSParameterAssert(self.currentItem);
#endif
    
    __weak typeof(self) _self = self;
    _sj_itemObsever = [SJAVBasePlayerItemObserver.alloc initWithBasePlayerItem:(SJAVBasePlayerItem *)self.currentItem];
    _sj_itemObsever.statusDidChangeExeBlock = ^(SJAVBasePlayerItem * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _sjbase_refreshPlayerStatus];
            
            if ( @available(iOS 10.0, *) ) { }
            else if ( self.sj_timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
                [self _sjbase_toEvaluating];
            }
        });
    };
    
    _sj_itemObsever.failedToPlayToEndTimeExeBlock = ^(SJAVBasePlayerItem * _Nonnull item, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.sj_failedToPlayEndTimeError = error;
            [self _sjbase_refreshPlayerStatus];
        });
    };
    
    if ( @available(iOS 10.0, *) ) { }
    else {
        _sj_itemObsever.didPlayToEndTimeExeBlock = ^(SJAVBasePlayerItem * _Nonnull item) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self pause];
            });
        };
        
        _sj_itemObsever.playbackLikelyToKeepUpExeBlock = ^(SJAVBasePlayerItem * _Nonnull item) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( self.sj_timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
                    [self _sjbase_toEvaluating];
                }
            });
        };
        
        _sj_itemObsever.playbackBufferEmptyDidChangeExeBlock = ^(SJAVBasePlayerItem * _Nonnull item) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( self.sj_timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
                    [self _sjbase_toEvaluating];
                }
            });
        };
        
        _sj_itemObsever.playbackBufferFullDidChangeExeBlock = ^(SJAVBasePlayerItem * _Nonnull item) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( self.sj_timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
                    [self _sjbase_toEvaluating];
                }
            });
        };
    }
}

- (void)_sjbase_toEvaluating {
    SJWaitingReason _Nullable waitingReason = _sj_reasonForWaitingToPlay;
    SJPlaybackTimeControlStatus timeControlStatus = _sj_timeControlStatus;
    
    if ( self.currentItem.status == AVPlayerItemStatusReadyToPlay && (self.currentItem.isPlaybackBufferFull || self.currentItem.isPlaybackLikelyToKeepUp) ) {
        waitingReason = nil;
        timeControlStatus = SJPlaybackTimeControlStatusPlaying;
    }
    else {
        waitingReason = (self.currentItem == nil) ? SJWaitingWithNoAssetToPlayReason : SJWaitingToMinimizeStallsReason;
        timeControlStatus = SJPlaybackTimeControlStatusWaitingToPlay;
    }
    
    if ( waitingReason != _sj_reasonForWaitingToPlay || timeControlStatus != _sj_timeControlStatus ) {
        self.sj_reasonForWaitingToPlay = waitingReason;
        self.sj_timeControlStatus = timeControlStatus;
    }
    
    if ( timeControlStatus == SJPlaybackTimeControlStatusPlaying ) [super play];
}

- (void)_sjbase_refreshPlayerStatus {
    SJAssetStatus status = self.sj_assetStatus;
    
    if ( self.sj_error ) {
        status = SJAssetStatusFailed;
    }
    else if ( self.currentItem.status == AVPlayerItemStatusReadyToPlay && self.status == AVPlayerStatusReadyToPlay ) {
        status = SJAssetStatusReadyToPlay;
    }
    
    if ( status != self.sj_assetStatus ) {
        self.sj_assetStatus = status;
    }
}

@synthesize sj_periodicTimeObservers = _sj_periodicTimeObservers;
- (NSMutableArray *)sj_periodicTimeObservers {
    if ( _sj_periodicTimeObservers == nil ) {
        _sj_periodicTimeObservers = [NSMutableArray arrayWithCapacity:3];
    }
    return _sj_periodicTimeObservers;
}
@end
NS_ASSUME_NONNULL_END
