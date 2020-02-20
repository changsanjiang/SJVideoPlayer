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
    SJPlaybackRecordSaveTimeMask _times;
    id<SJPlaybackHistoryController> _controller;
}

+ (instancetype)shared {
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [SJPlaybackRecordSaveHandler.alloc initWithSaveTimes:SJPlaybackRecordSaveTimeMaskAll playbackHistoryController:SJPlaybackHistoryController.shared];
    });
    return obj;
}

- (instancetype)initWithSaveTimes:(SJPlaybackRecordSaveTimeMask)times playbackHistoryController:(id<SJPlaybackHistoryController>)controller;
 {
    self = [super init];
    if ( self ) {
        _times = times;
        _controller = controller;
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_timeControlStatusDidChange:) name:SJVideoPlayerPlaybackTimeControlStatusDidChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_URLAssetWillChange:) name:SJVideoPlayerURLAssetWillChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_playbackWillStop:) name:SJVideoPlayerPlaybackWillStopNotification object:nil];
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
    if ( _times & SJPlaybackRecordSaveTimeMaskPlayerPaused ) {
        SJBaseVideoPlayer *player = note.object;
        if ( player.isPaused ) {
            [self _saveForPlayer:player];
        }
    }
}

- (void)_URLAssetWillChange:(NSNotification *)note {
    if ( _times & SJPlaybackRecordSaveTimeMaskPlayerURLAssetWillChange ) {
        [self _saveForPlayer:note.object];
    }
}

- (void)_playbackWillStop:(NSNotification *)note {
    if ( _times & SJPlaybackRecordSaveTimeMaskPlayerPlaybackWillStop ) {
        [self _saveForPlayer:note.object];
    }
}

- (void)_didEnterBackground:(NSNotification *)note {
    if ( _times & SJPlaybackRecordSaveTimeMaskApplicationDidEnterBackground ) {
        [self _saveForPlayer:note.object];
    }
}

- (void)_willTerminate:(NSNotification *)note {
    if ( _times & SJPlaybackRecordSaveTimeMaskApplicationWillTerminate ) {
        [self _saveForPlayer:note.object];
    }
}

- (void)_playbackControllerWillDeallocate:(NSNotification *)note {
    if ( _times & SJPlaybackRecordSaveTimeMaskPlayerPlaybackControllerWillDeallocate ) {
        [self _saveForPlaybackController:note.object];
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
NS_ASSUME_NONNULL_END

#endif
