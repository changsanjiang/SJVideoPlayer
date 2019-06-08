//
//  SJBaseVideoPlayerStatistics.m
//  Pods
//
//  Created by BlueDancer on 2019/2/25.
//

#import "SJBaseVideoPlayerStatistics.h"
#import <objc/message.h>
#import "SJVideoPlayerURLAsset.h"
#import "NSTimer+SJAssetAdd.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif


NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerURLAsset (StatisticsAdd)
@property (nonatomic) NSTimeInterval statistics_currentPlayingTime;
- (void)statistics_start;
- (void)statistics_stop;

@property (nonatomic, copy, nullable) void(^statistics_currentPlayingTimeDidChangeExeBlock)(SJVideoPlayerURLAsset *asset);
@end

@implementation SJVideoPlayerURLAsset (StatisticsAdd)
- (void)setStatistics_currentPlayingTime:(NSTimeInterval)statistics_currentPlayingTime {
    if (self.originAsset && self.originAsset != self ) {
        self.originAsset.statistics_currentPlayingTime = statistics_currentPlayingTime;
    }
    else {
        objc_setAssociatedObject(self, @selector(statistics_currentPlayingTime), @(statistics_currentPlayingTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if ( self.statistics_currentPlayingTimeDidChangeExeBlock ) self.statistics_currentPlayingTimeDidChangeExeBlock(self);
    }
}
- (NSTimeInterval)statistics_currentPlayingTime {
    if (self.originAsset && self.originAsset != self ) {
        return self.originAsset.statistics_currentPlayingTime;
    }
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

- (void)setStatistics_currentPlayingTimeDidChangeExeBlock:(nullable void (^)(SJVideoPlayerURLAsset * _Nonnull))statistics_currentPlayingTimeDidChangeExeBlock {
    objc_setAssociatedObject(self, @selector(statistics_currentPlayingTimeDidChangeExeBlock), statistics_currentPlayingTimeDidChangeExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (nullable void (^)(SJVideoPlayerURLAsset * _Nonnull))statistics_currentPlayingTimeDidChangeExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

static const char *kTimer = "statistics_refreshTimer";
- (void)statistics_start {
    NSTimer *_Nullable timer = objc_getAssociatedObject(self, (kTimer));
    if ( timer ) return;
    __weak typeof(self) _self = self;
    timer = [NSTimer assetAdd_timerWithTimeInterval:1 block:^(NSTimer *timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) {
            [timer invalidate];
            return ;
        }
        self.statistics_currentPlayingTime += 1;
    } repeats:YES];
    
    [timer assetAdd_fire];
    [NSRunLoop.mainRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
    objc_setAssociatedObject(self, kTimer, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)statistics_stop {
    NSTimer *_Nullable timer = objc_getAssociatedObject(self, (kTimer));
    if ( !timer ) return;
    [timer invalidate];
    objc_setAssociatedObject(self, kTimer, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)statistics_reset {
    self.statistics_currentPlayingTime = 0;
}
@end

@interface SJBaseVideoPlayerStatistics ()
@property (nonatomic) NSTimeInterval totalPlayingTime;
@end

@implementation SJBaseVideoPlayerStatistics
@synthesize playStatusDidChangeHandler = _playStatusDidChangeHandler;

static NSString *kURLAsset = @"URLAsset";
static NSString *kPlayStatus = @"playStatus";
static NSString *kReplayed = @"replayed";
- (void)observePlayer:(__weak id<SJBaseVideoPlayer>)player {
    dispatch_async(dispatch_get_main_queue(), ^{
        [(id)player sj_addObserver:self forKeyPath:kURLAsset context:&kURLAsset];
        [(id)player sj_addObserver:self forKeyPath:kPlayStatus context:&kPlayStatus];
        [(id)player sj_addObserver:self forKeyPath:kReplayed context:&kReplayed];
        [self _playStatusDidChangeOfPlayer:player];
        [self _URLAssetDidChangeOfPlayer:player];
    });
}
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( context == &kPlayStatus ) {
        [self _playStatusDidChangeOfPlayer:object];
    }
    else if ( context == &kURLAsset ) {
        SJVideoPlayerURLAsset *old = change[NSKeyValueChangeOldKey];
        if ( [old isKindOfClass:[SJVideoPlayerURLAsset class]] ) [old statistics_stop];
        [self _URLAssetDidChangeOfPlayer:object];
    }
    else if ( context == &kReplayed ) {
        id<SJBaseVideoPlayer> player = object;
        [player.URLAsset statistics_reset];
    }
}
- (void)_playStatusDidChangeOfPlayer:(id<SJBaseVideoPlayer>)player {
    if ( player.playStatus == SJVideoPlayerPlayStatusPlaying ) {
        [player.URLAsset statistics_start];
    }
    else {
        [player.URLAsset statistics_stop];
    }
    
    if ( _playStatusDidChangeHandler ) _playStatusDidChangeHandler(self, player);
}
- (void)_URLAssetDidChangeOfPlayer:(id<SJBaseVideoPlayer>)player {
    __weak typeof(self) _self = self;
    player.URLAsset.statistics_currentPlayingTimeDidChangeExeBlock = ^(SJVideoPlayerURLAsset * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.totalPlayingTime += 1;
    };
}
- (NSTimeInterval)currentPlayingTimeOfAsset:(SJVideoPlayerURLAsset *)asset {
    return asset.statistics_currentPlayingTime;
}
@end
NS_ASSUME_NONNULL_END
