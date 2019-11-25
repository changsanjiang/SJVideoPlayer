//
//  SJPlaybackObservation.m
//  Pods
//
//  Created by 畅三江 on 2019/8/27.
//

#import "SJPlaybackObservation.h"
#import "SJBaseVideoPlayerConst.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJPlaybackObservation {
    NSMutableArray *_tokens;
}
- (instancetype)initWithPlayer:(__kindof SJBaseVideoPlayer *)player {
    self = [super init];
    if ( self ) {
        _tokens = NSMutableArray.new;
        _player = player;
        
        __weak typeof(self) _self = self;
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJVideoPlayerAssetStatusDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.assetStatusDidChangeExeBlock ) self.assetStatusDidChangeExeBlock(self.player);
            if ( self.playbackStatusDidChangeExeBlock ) self.playbackStatusDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.timeControlStatusDidChangeExeBlock ) self.timeControlStatusDidChangeExeBlock(self.player);
            if ( self.playbackStatusDidChangeExeBlock ) self.playbackStatusDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJVideoPlayerDidPlayToEndTimeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.didPlayToEndTimeExeBlock ) self.didPlayToEndTimeExeBlock(self.player);
            if ( self.playbackStatusDidChangeExeBlock ) self.playbackStatusDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJVideoPlayerDefinitionSwitchStatusDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.definitionSwitchStatusDidChangeExeBlock ) self.definitionSwitchStatusDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJVideoPlayerCurrentTimeDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.currentTimeDidChangeExeBlock ) self.currentTimeDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJVideoPlayerDurationDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.durationDidChangeExeBlock ) self.durationDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJVideoPlayerPlayableDurationDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.playableDurationDidChangeExeBlock ) self.playableDurationDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJVideoPlayerPresentationSizeDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.presentationSizeDidChangeExeBlock ) self.presentationSizeDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJVideoPlayerPlaybackTypeDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.playbackTypeDidChangeExeBlock ) self.playbackTypeDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJVideoPlayerLockedScreenDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.lockedScreenDidChangeExeBlock ) self.lockedScreenDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJVideoPlayerMutedDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.mutedDidChangeExeBlock ) self.mutedDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJVideoPlayerVolumeDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.playerVolumeDidChangeExeBlock ) self.playerVolumeDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJVideoPlayerRateDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.rateDidChangeExeBlock ) self.rateDidChangeExeBlock(self.player);
        }]];
    }
    return self;
}

- (void)dealloc {
    for ( id token in _tokens ) {
        [NSNotificationCenter.defaultCenter removeObserver:token];
    }
}
@end
NS_ASSUME_NONNULL_END
