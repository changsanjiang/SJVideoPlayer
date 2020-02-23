//
//  SJPlaybackRecordSaveHandler.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/2/20.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#if __has_include(<YYModel/YYModel.h>) || __has_include(<YYKit/YYKit.h>)

#import "SJPlaybackRecordSaveHandler.h"
#import <objc/message.h>
#import "SJBaseVideoPlayerConst.h"
#import "SJBaseVideoPlayer.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJPlaybackRecordSaveHandler {
    SJPlayerEventObserver *_observer;
    id<SJPlaybackHistoryController> _controller;
}

+ (instancetype)shared {
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [SJPlaybackRecordSaveHandler.alloc initWithEvents:SJPlayerEventMaskAll playbackHistoryController:SJPlaybackHistoryController.shared];
    });
    return obj;
}

- (instancetype)initWithEvents:(SJPlayerEventMask)events playbackHistoryController:(id<SJPlaybackHistoryController>)controller;
 {
    self = [super init];
    if ( self ) {
        _controller = controller;
        __weak typeof(self) _self = self;
        _observer = [SJPlayerEventObserver.alloc initWithEvents:events handler:^(id  _Nonnull target, SJPlayerEvent event) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _target:target event:event];
        }];
    }
    return self;
}

- (void)setEvents:(SJPlayerEventMask)events {
    _observer.events = events;
}

- (SJPlayerEventMask)events {
    return _observer.events;
}

- (void)_target:(id)target event:(SJPlayerEvent)event {
    switch ( event ) {
        case SJPlayerEventPlaybackDidPause: {
            SJBaseVideoPlayer *player = target;
            if ( player.isPaused ) {
                [self _saveForPlayer:player];
            }
        }
            break;
        case SJPlayerEventPlaybackWillRefresh:
        case SJPlayerEventURLAssetWillChange:
        case SJPlayerEventPlaybackWillStop:
        case SJPlayerEventApplicationDidEnterBackground:
        case SJPlayerEventApplicationWillTerminate:
            [self _saveForPlayer:target];
            break;
        case SJPlayerEventPlaybackControllerWillDeallocate:
            [self _saveForPlaybackController:target];
            break;
    }
}

- (void)_saveForPlayer:(SJBaseVideoPlayer *)player {
    SJPlaybackRecord *record = player.URLAsset.record;
    if ( record != nil ) {
        record.position = player.currentTime;
        [self _saveRecord:record];
    }
}

- (void)_saveForPlaybackController:(id<SJVideoPlayerPlaybackController>)playbackController {
    SJPlaybackRecord *record = ((SJVideoPlayerURLAsset *)playbackController.media).record;
    if ( record != nil ) {
        record.position = playbackController.currentTime;
        [self _saveRecord:record];
    }
}

- (void)_saveRecord:(SJPlaybackRecord *)record {
    [_controller save:record];
#ifdef DEBUG
    NSLog(@"%d \t %s \t 已保存播放位置: %lf", (int)__LINE__, __func__, record.position);
#endif
}
@end

@implementation SJVideoPlayerURLAsset (SJPlaybackRecordSaveHandlerExtended)
- (void)setRecord:(nullable SJPlaybackRecord *)record {
    objc_setAssociatedObject(self, @selector(record), record, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable SJPlaybackRecord *)record {
    return objc_getAssociatedObject(self, _cmd);
}
@end


@implementation SJPlayerEventObserver {
    void(^_block)(id target, SJPlayerEvent event);
}
- (instancetype)initWithEvents:(SJPlayerEventMask)events handler:(void(^)(id target, SJPlayerEvent event))block {
    self = [super init];
    if ( self ) {
        _events = events;
        _block = block;
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_timeControlStatusDidChange:) name:SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_URLAssetWillChange:) name:SJVideoPlayerURLAssetWillChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_playbackWillStop:) name:SJVideoPlayerPlaybackWillStopNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_playbackWillRefresh:) name:SJVideoPlayerPlaybackWillRereshNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didEnterBackground:) name:SJVideoPlayerApplicationDidEnterBackgroundNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_willTerminate:) name:SJVideoPlayerApplicationWillTerminateNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_playbackControllerWillDeallocate:) name:SJVideoPlayerPlaybackControllerWillDeallocateNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)_timeControlStatusDidChange:(NSNotification *)note {
    if ( _events & SJPlayerEventMaskPlaybackDidPause ) {
        SJBaseVideoPlayer *player = note.object;
        if ( player.isPaused ) {
            if ( _block ) _block(player, SJPlayerEventPlaybackDidPause);
        }
    }
}

- (void)_URLAssetWillChange:(NSNotification *)note {
    if ( _events & SJPlayerEventMaskURLAssetWillChange ) {
        if ( _block ) _block(note.object, SJPlayerEventURLAssetWillChange);
    }
}

- (void)_playbackWillStop:(NSNotification *)note {
    if ( _events & SJPlayerEventMaskPlaybackWillStop ) {
        if ( _block ) _block(note.object, SJPlayerEventPlaybackWillStop);
    }
}

- (void)_playbackWillRefresh:(NSNotification *)note {
    if ( _events & SJPlayerEventMaskPlaybackWillRefresh ) {
        if ( _block ) _block(note.object, SJPlayerEventPlaybackWillRefresh);
    }
}

- (void)_didEnterBackground:(NSNotification *)note {
    if ( _events & SJPlayerEventMaskApplicationDidEnterBackground ) {
        if ( _block ) _block(note.object, SJPlayerEventApplicationDidEnterBackground);
    }
}

- (void)_willTerminate:(NSNotification *)note {
    if ( _events & SJPlayerEventMaskApplicationWillTerminate ) {
        if ( _block ) _block(note.object, SJPlayerEventApplicationWillTerminate);
    }
}

- (void)_playbackControllerWillDeallocate:(NSNotification *)note {
    if ( _events & SJPlayerEventMaskPlaybackControllerWillDeallocate ) {
        if ( _block ) _block(note.object, SJPlayerEventPlaybackControllerWillDeallocate);
    }
}
@end
NS_ASSUME_NONNULL_END

#endif
