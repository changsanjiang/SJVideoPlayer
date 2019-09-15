//
//  SJAVBasePlayer.m
//  SJUIKit
//
//  Created by BlueDancer on 2019/8/26.
//

#import "SJAVBasePlayer.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
SJWaitingReason const SJWaitingToMinimizeStallsReason = @"AVPlayerWaitingToMinimizeStallsReason";
SJWaitingReason const SJWaitingWhileEvaluatingBufferingRateReason = @"AVPlayerWaitingWhileEvaluatingBufferingRateReason";
SJWaitingReason const SJWaitingWithNoAssetToPlayReason = @"AVPlayerWaitingWithNoItemToPlayReason";

typedef struct {
    BOOL isSeeking;
    CMTime time;
} SJAVBasePlayerSeekingInfo;

@interface SJAVBasePlayer ()
@property (nonatomic, nullable) SJWaitingReason sj_reasonForWaitingToPlay;
@property (nonatomic) SJPlaybackTimeControlStatus sj_timeControlStatus;

@property (nonatomic, strong, nullable) NSError *sj_failedToPlayEndTimeError;
@property (nonatomic) SJAssetStatus sj_assetStatus;

@property (nonatomic) SJAVBasePlayerSeekingInfo seekingInfo;
@end

@implementation SJAVBasePlayer
- (instancetype)initWithPlayerItem:(nullable AVPlayerItem *)item {
    self = [super initWithPlayerItem:item];
    if ( !self ) return nil;
    
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _sjbase_initObservations];
    });
    return self;
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

- (void)_sjbase_initObservations {
#ifdef DEBUG
    NSParameterAssert(self.currentItem);
#endif
    
    if ( self.currentItem == nil ) return;
    
    __weak typeof(self) _self = self;
    sjkvo_observe(self.currentItem, @"status", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _sjbase_refreshPlayerStatus];
           
            if ( @available(iOS 10.0, *) ) { }
            else if ( self.sj_timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
                [self _sjbase_toEvaluating];
            }
        });
    });
    
    [self sj_observeWithNotification:AVPlayerItemFailedToPlayToEndTimeNotification target:self.currentItem usingBlock:^(SJAVBasePlayer *self, NSNotification * _Nonnull note) {
        NSError *_Nullable error = note.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
        if ( error ) {
            self.sj_failedToPlayEndTimeError = error;
            [self _sjbase_refreshPlayerStatus];
        }
    }];
    
    if ( @available(iOS 10.0, *) ) { }
    else {
        [self sj_observeWithNotification:AVPlayerItemDidPlayToEndTimeNotification target:self.currentItem usingBlock:^(SJAVBasePlayer *self, NSNotification * _Nonnull note) {
            [self pause];
        }];
    }
    
    sjkvo_observe(self, @"status", ^(id target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _sjbase_refreshPlayerStatus];
        });
    });
    
    if ( @available(iOS 10.0, *) ) {
        sjkvo_observe(self, @"timeControlStatus", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( self.reasonForWaitingToPlay == AVPlayerWaitingWithNoItemToPlayReason )
                    return;
                
                SJWaitingReason reason = nil;
                SJPlaybackTimeControlStatus status = (NSInteger)self.timeControlStatus;
                if ( self.reasonForWaitingToPlay == AVPlayerWaitingToMinimizeStallsReason )
                    reason = SJWaitingToMinimizeStallsReason;
                
                if ( self.reasonForWaitingToPlay == AVPlayerWaitingWhileEvaluatingBufferingRateReason )
                    reason = SJWaitingWhileEvaluatingBufferingRateReason;
                
                if ( self.reasonForWaitingToPlay == AVPlayerWaitingWithNoItemToPlayReason )
                    reason = SJWaitingWithNoAssetToPlayReason;
                
                if ( status != self.sj_timeControlStatus || reason != self.sj_reasonForWaitingToPlay ) {
                    self.sj_reasonForWaitingToPlay = reason;
                    self.sj_timeControlStatus = status;
                }
            });
        });
    }
    else {
        sjkvo_observe(self.currentItem, @"playbackLikelyToKeepUp", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( self.sj_timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
                    [self _sjbase_toEvaluating];
                }
            });
        });
        
        sjkvo_observe(self.currentItem, @"playbackBufferEmpty", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( self.sj_timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
                    [self _sjbase_toEvaluating];
                }
            });
        });
        
        sjkvo_observe(self.currentItem, @"playbackBufferFull", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( self.sj_timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
                    [self _sjbase_toEvaluating];
                }
            });
        });
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
    
    if ( self.rate == 0 ) [super play];
}

- (void)_sjbase_refreshPlayerStatus {
    SJAssetStatus status = SJAssetStatusPreparing;
    
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
@end
NS_ASSUME_NONNULL_END
