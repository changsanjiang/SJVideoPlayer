//
//  SJPlaybackListController.m
//  Pods-SJPlaybackListController_Example
//
//  Created by BlueDancer on 2019/1/23.
//

#import "SJPlaybackListController.h"
#import "SJPlaybackListControllerObserver.h"
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer+PlayStatus.h>
#else
#import "SJBaseVideoPlayer.h"
#import "SJBaseVideoPlayer+PlayStatus.h"
#endif

NS_ASSUME_NONNULL_BEGIN
#define SJPlaybackListControllerLock() dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
#define SJPlaybackListControllerUnlock() dispatch_semaphore_signal(_lock);

@interface SJPlaybackListController ()
@property (nonatomic, strong, readonly) id<SJPlayStatusObserver> playStatusObserver;
@property (nonatomic, strong, readonly) NSMutableArray<id<SJMediaInfo>> *m;
@property (strong, nullable) id<SJMediaInfo> currentMedia;
@end

@implementation SJPlaybackListController {
    dispatch_semaphore_t _lock;
}
@synthesize supportedMode = _supportedMode;
@synthesize delegate = _delegate;

- (instancetype)initWithPlayer:(__kindof SJBaseVideoPlayer *)player {
    self = [super init];
    if (self) {
        _player = player;
        _m = [NSMutableArray array];
        _lock = dispatch_semaphore_create(1);
        _supportedMode = SJSupportedPlaybackMode_All;
        [self initializePlayStatusObserver];
    }
    return self;
}

- (id<SJPlaybackListControllerObserver>)getObserver {
    return [[SJPlaybackListControllerObserver alloc] initWithListController:self];
}

#pragma mark -

- (NSInteger)indexForMediaId:(NSInteger)mediaId {
    SJPlaybackListControllerLock();
    NSInteger idx = [self _indexForMediaId:mediaId];
    SJPlaybackListControllerUnlock();
    return idx;
}

- (nullable id<SJMediaInfo>)mediaAtIndex:(NSInteger)index {
    id<SJMediaInfo> info = nil;
    SJPlaybackListControllerLock();
    if ( index >= 0 && index < _m.count ) {
        info = _m[index];
    }
    SJPlaybackListControllerUnlock();
    return info;
}

- (void)addMedia:(id<SJMediaInfo>)media {
    if ( !media || self.currentMedia.id == media.id )
        return;
    SJPlaybackListControllerLock();
    NSInteger idx = [self _indexForMediaId:media.id];
    if ( idx != NSNotFound ) {
        [_m removeObjectAtIndex:idx];
    }
    [_m addObject:media];
    SJPlaybackListControllerUnlock();
    [NSNotificationCenter.defaultCenter postNotificationName:SJPlaybackListControllerListDidChangeNotification object:self];
}

- (void)addToTheBackOfCurrentMedia:(id<SJMediaInfo>)media {
    if ( !media || self.currentMedia.id == media.id )
        return;
    SJPlaybackListControllerLock();
    NSInteger idx = [self _indexForMediaId:media.id];
    if ( idx != NSNotFound ) {
        [_m removeObjectAtIndex:idx];
    }
    idx = [self _indexForMediaId:self.currentMedia.id] + 1;
    [_m insertObject:media atIndex:idx];
    SJPlaybackListControllerUnlock();
    [NSNotificationCenter.defaultCenter postNotificationName:SJPlaybackListControllerListDidChangeNotification object:self];
}

- (void)replaceMedias:(NSArray<id<SJMediaInfo>> *)medias {
    if ( 0 == medias.count )
        return;
    SJPlaybackListControllerLock();
    [_m removeAllObjects];
    [_m addObjectsFromArray:medias];
    SJPlaybackListControllerUnlock();
    [NSNotificationCenter.defaultCenter postNotificationName:SJPlaybackListControllerListDidChangeNotification object:self];
}

- (void)remove:(NSInteger)mediaId {
    SJPlaybackListControllerLock();
    NSInteger idx = [self _indexForMediaId:mediaId];
    if ( idx != NSNotFound ) {
        [_m removeObjectAtIndex:idx];
    }
    SJPlaybackListControllerUnlock();
    [NSNotificationCenter.defaultCenter postNotificationName:SJPlaybackListControllerListDidChangeNotification object:self];
}

- (void)removeAllMedias {
    SJPlaybackListControllerLock();
    [_m removeAllObjects];
    SJPlaybackListControllerUnlock();
    [NSNotificationCenter.defaultCenter postNotificationName:SJPlaybackListControllerListDidChangeNotification object:self];
}

- (NSArray<id<SJMediaInfo>> *)medias {
    SJPlaybackListControllerLock();
    NSArray<id<SJMediaInfo>> *medias = _m.copy;
    SJPlaybackListControllerUnlock();
    return medias;
}

#pragma mark -

- (void)changePlaybackMode {
    if ( self.supportedMode == SJSupportedPlaybackMode_ListCycle ) return;
    if ( self.supportedMode == SJSupportedPlaybackMode_SingleCycle ) return;
    if ( self.supportedMode == SJSupportedPlaybackMode_RandomPlay ) return;
    SJPlaybackMode mode = self.mode;
    while ( ![self _isSupportedMode:(mode = (mode + 1) % 3)] ) { }
    self.mode = mode;
}

- (BOOL)_isSupportedMode:(SJPlaybackMode)mode {
    switch ( mode ) {
        case SJPlaybackMode_ListCycle:
            return _supportedMode & SJSupportedPlaybackMode_ListCycle;
        case SJPlaybackMode_SingleCycle:
            return _supportedMode & SJSupportedPlaybackMode_SingleCycle;
        case SJPlaybackMode_RandomPlay:
            return _supportedMode & SJSupportedPlaybackMode_RandomPlay;
    }
}

@synthesize mode = _mode;
- (void)setMode:(SJPlaybackMode)mode {
    @synchronized (self) {
        if ( mode == _mode )
            return;
        _mode = mode;
    }
    [NSNotificationCenter.defaultCenter postNotificationName:SJPlaybackListControllerPlaybackModeDidChangeNotification object:self];
}
- (SJPlaybackMode)mode {
    @synchronized(self) {
        return _mode;
    }
}

- (void)playPreviousMedia {
    if ( 0 == _m.count )
        return;
    NSInteger idx = [self indexForMediaId:self.currentMedia.id];
    [self playAtIndex:(idx-1<_m.count)?(idx-1):(_m.count-1)];
}
- (void)playNextMedia {
    if ( 0 == _m.count )
        return;
    NSInteger idx = [self indexForMediaId:self.currentMedia.id];
    [self playAtIndex:(idx+1<_m.count)?(idx+1):0];
}
- (void)playAtIndex:(NSInteger)idx {
    id<SJMediaInfo>_Nullable info = [self mediaAtIndex:idx];
    if ( !info || !info.URL )
        return;
    self.currentMedia = info;
    
    __weak typeof(self) _self = self;
    void(^_innerBlock)(NSURL *URL) = ^(NSURL *URL) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:URL playModel:info.viewHierarchy];
        [NSNotificationCenter.defaultCenter postNotificationName:SJPlaybackListControllerPrepareToPlayMediaNotification object:self];
    };
    
    if ( [self.delegate respondsToSelector:@selector(listController:willPlayAtIndex:playbackURLDecisionHandler:)] ) {
        [self.delegate listController:self willPlayAtIndex:idx playbackURLDecisionHandler:^(NSURL * _Nullable URL) {
            _innerBlock(URL?:info.URL);
        }];
    }
    else {
        _innerBlock(info.URL);
    }
}

#pragma mark -

- (NSInteger)_indexForMediaId:(NSInteger)mediaId {
    NSInteger idx = NSNotFound;
    for ( NSInteger i = 0 ; i < _m.count ; ++ i ) {
        id<SJMediaInfo> info = _m[i];
        if ( info.id == mediaId ) {
            idx = i;
            break;
        }
    }
    return idx;
}

#pragma mark -

- (void)initializePlayStatusObserver {
    _playStatusObserver = [_player getPlayStatusObserver];
    
    __weak typeof(self) _self = self;
    _playStatusObserver.playStatusDidChangeExeBlock = ^(SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [player playStatus_isInactivity_ReasonPlayEnd] ) {
            if ( self.mode == SJPlaybackMode_SingleCycle ) {
                [player replay];
            }
            else {
                [self playNextMedia];
            }
        }
    };
}
@end
NS_ASSUME_NONNULL_END
