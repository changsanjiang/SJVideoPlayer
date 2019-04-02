//
//  SJRemoteCommandHandler.m
//  Pods
//
//  Created by 畅三江 on 2018/5/26.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "SJRemoteCommandHandler.h"
#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJRemoteCommandHandler {
    id _pauseToken;
    id _playToken;
    id _previousToken;
    id _nextToken;
    id _seekToTimeToken;
}
@synthesize pauseCommandHandler = _pauseCommandHandler;
@synthesize playCommandHandler = _playCommandHandler;
@synthesize previousCommandHandler = _previousCommandHandler;
@synthesize nextCommandHandler = _nextCommandHandler;
@synthesize seekToTimeCommandHandler = _seekToTimeCommandHandler;

+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    __weak typeof(self) _self = self;
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    _pauseToken = [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(_self) self = _self;
        if ( !self ) return MPRemoteCommandHandlerStatusSuccess;
        if ( self.pauseCommandHandler ) self.pauseCommandHandler(self);
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    _playToken = [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(_self) self = _self;
        if ( !self ) return MPRemoteCommandHandlerStatusSuccess;
        if ( self.playCommandHandler ) self.playCommandHandler(self);
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    _previousToken = [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(_self) self = _self;
        if ( !self ) return MPRemoteCommandHandlerStatusSuccess;
        if ( self.previousCommandHandler ) self.previousCommandHandler(self);
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    _nextToken = [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(_self) self = _self;
        if ( !self ) return MPRemoteCommandHandlerStatusSuccess;
        if ( self.nextCommandHandler ) self.nextCommandHandler(self);
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    if (@available(iOS 9.1, *)) {
        _seekToTimeToken = [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            __strong typeof(_self) self = _self;
            if ( !self ) return MPRemoteCommandHandlerStatusSuccess;
            MPChangePlaybackPositionCommandEvent *playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
            if ( self.seekToTimeCommandHandler ) self.seekToTimeCommandHandler(self, playbackPositionEvent.positionTime);
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
    return self;
}

- (void)dealloc {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.pauseCommand removeTarget:_pauseToken];
    [commandCenter.playCommand removeTarget:_playToken];
    [commandCenter.previousTrackCommand removeTarget:_previousToken];
    [commandCenter.nextTrackCommand removeTarget:_nextToken];
    if (@available(iOS 9.1, *)) {
        [commandCenter.changePlaybackPositionCommand removeTarget:_seekToTimeToken];
    }
}

- (void)updateNowPlayingInfo:(NSDictionary *)info {
    [MPNowPlayingInfoCenter.defaultCenter setNowPlayingInfo:info];
}
@end
NS_ASSUME_NONNULL_END
