//
//  SJPlaybackListController.m
//  Pods-SJPlaybackListController_Example
//
//  Created by 畅三江 on 2019/1/23.
//

#import "SJPlaybackListController.h"
#import "SJPlaybackListControllerObserver.h"

NS_ASSUME_NONNULL_BEGIN
#define SJPlaybackListControllerLock() dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
#define SJPlaybackListControllerUnlock() dispatch_semaphore_signal(_lock);

@interface SJPlaybackListController ()
@property (nonatomic, strong, readonly) NSMutableArray<id<SJMediaInfo>> *m;
@property NSInteger currentMediaId;
@end

@implementation SJPlaybackListController {
    dispatch_semaphore_t _lock;
}
@synthesize supportedMode = _supportedMode;
@synthesize delegate = _delegate;
@synthesize recycle = _recycle;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _currentMediaId = NSNotFound;
    _m = [NSMutableArray array];
    _lock = dispatch_semaphore_create(1);
    _supportedMode = SJSupportedPlaybackMode_All;
    return self;
}

- (id<SJPlaybackListControllerObserver>)getObserver {
    return [[SJPlaybackListControllerObserver alloc] initWithListController:self];
}

#pragma mark -

- (NSInteger)indexForMediaId:(NSInteger)mediaId {
    SJPlaybackListControllerLock();
    NSInteger idx = [self _unsafe_indexForMediaId:mediaId];
    SJPlaybackListControllerUnlock();
    return idx;
}

- (nullable id<SJMediaInfo>)mediaForMediaId:(NSInteger)mediaId {
    SJPlaybackListControllerLock();
    id<SJMediaInfo> media = [self _unsafe_mediaForMediaId:mediaId];
    SJPlaybackListControllerUnlock();
    return media;
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
    SJPlaybackListControllerLock();
    [self _unsafe_addMedia:media];
    SJPlaybackListControllerUnlock();
    [NSNotificationCenter.defaultCenter postNotificationName:SJPlaybackListControllerListDidChangeNotification object:self];
}

- (void)addToTheBackOfCurrentMedia:(id<SJMediaInfo>)media {
    if ( !media || self.currentMediaId == media.id )
        return;
    SJPlaybackListControllerLock();
    NSInteger idx = [self _unsafe_indexForMediaId:media.id];
    if ( idx != NSNotFound ) {
        [_m removeObjectAtIndex:idx];
    }
    
    idx = [self _unsafe_indexForMediaId:self.currentMediaId] + 1;
    
    if ( idx > _m.count || idx < 0 ) {
        [_m addObject:media];
    }
    else {
        [_m insertObject:media atIndex:idx];
    }
    SJPlaybackListControllerUnlock();
    [NSNotificationCenter.defaultCenter postNotificationName:SJPlaybackListControllerListDidChangeNotification object:self];
}

- (void)addMedias:(NSArray<id<SJMediaInfo>> *)medias {
    if ( 0 == medias.count )
        return;
    SJPlaybackListControllerLock();
    for ( id<SJMediaInfo> info in [self _removeDuplicateMedias:medias] ) {
        [self _unsafe_addMedia:info];
    }
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
    NSInteger idx = [self _unsafe_indexForMediaId:mediaId];
    if ( idx != NSNotFound ) {
        [_m removeObjectAtIndex:idx];
    }
    SJPlaybackListControllerUnlock();
    if ( self.currentMediaId == mediaId ) {
        self.currentMediaId = NSNotFound;
        if ( [self.delegate respondsToSelector:@selector(currentMediaForListControllerIsRemoved:)] ) {
            [self.delegate currentMediaForListControllerIsRemoved:self];
        }
    }
    [NSNotificationCenter.defaultCenter postNotificationName:SJPlaybackListControllerListDidChangeNotification object:self];
}

- (void)removeAllMedias {
    SJPlaybackListControllerLock();
    [_m removeAllObjects];
    self.currentMediaId = NSNotFound;
    SJPlaybackListControllerUnlock();
    if ( self.currentMediaId != NSNotFound ) {
        self.currentMediaId = NSNotFound;
        if ( [self.delegate respondsToSelector:@selector(currentMediaForListControllerIsRemoved:)] ) {
            [self.delegate currentMediaForListControllerIsRemoved:self];
        }
    }
    [NSNotificationCenter.defaultCenter postNotificationName:SJPlaybackListControllerListDidChangeNotification object:self];
}

- (nullable id<SJMediaInfo>)currentMedia {
    return [self mediaForMediaId:self.currentMediaId];
}

- (NSArray<id<SJMediaInfo>> *)medias {
    SJPlaybackListControllerLock();
    NSArray<id<SJMediaInfo>> *medias = _m.copy;
    SJPlaybackListControllerUnlock();
    return medias;
}

#pragma mark -

- (void)changePlaybackMode {
    if ( self.supportedMode == SJSupportedPlaybackMode_InOrder ) return;
    if ( self.supportedMode == SJSupportedPlaybackMode_RepeatOne ) return;
    if ( self.supportedMode == SJSupportedPlaybackMode_Shuffle ) return;
    SJPlaybackMode mode = self.mode;
    while ( ![self _isSupportedMode:(mode = (mode + 1) % 3)] ) { }
    self.mode = mode;
}

- (BOOL)_isSupportedMode:(SJPlaybackMode)mode {
    SJSupportedPlaybackMode supportedMode = self.supportedMode;
    switch ( mode ) {
        case SJPlaybackMode_InOrder:
            return supportedMode & SJSupportedPlaybackMode_InOrder;
        case SJPlaybackMode_RepeatOne:
            return supportedMode & SJSupportedPlaybackMode_RepeatOne;
        case SJPlaybackMode_Shuffle:
            return supportedMode & SJSupportedPlaybackMode_Shuffle;
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
    if ( __builtin_expect(self.mode == SJPlaybackMode_Shuffle, 0) ) {
        [self _randomModePlayNextMedia];
    }
    else {
        NSInteger idx = [self indexForMediaId:self.currentMediaId];
        NSInteger idx2 = idx - 1;
        if ( !_recycle && idx2 < 0 )
            return;
        
        [self playAtIndex:(idx2<_m.count)?idx2:(_m.count-1)];
    }
}
- (void)playNextMedia {
    if ( 0 == _m.count )
        return;
    if ( __builtin_expect(self.mode == SJPlaybackMode_Shuffle, 0) ) {
        [self _randomModePlayNextMedia];
    }
    else {
        NSInteger idx = [self indexForMediaId:self.currentMediaId];
        NSInteger idx2 = idx + 1;
        if ( !_recycle && idx2 >= _m.count )
            return;
        
        [self playAtIndex:(idx2<_m.count)?idx2:0];
    }
}

///
/// Thanks @szdkkk
/// https://github.com/changsanjiang/SJPlaybackListController/issues/1
///
- (void)_randomModePlayNextMedia {
    if ( _m.count == 0 )
        return;
    if ( __builtin_expect(_m.count == 1, 0) ) {
        [self playAtIndex:0];
    }
    else {
        NSInteger idx = [self indexForMediaId:self.currentMediaId];
        NSInteger next = idx; while ( next == idx ) next = arc4random() % _m.count;
        [self playAtIndex:next];
    }
}
- (void)playAtIndex:(NSInteger)idx {
    id<SJMediaInfo>_Nullable info = [self mediaAtIndex:idx];
    if ( !info )
        return;
    self.currentMediaId = info.id;
    
#ifdef DEBUG
    printf("\n播放列表: 将要播放 - idx = %ld \n", (long)idx);
#endif
    
    if ( [self.delegate respondsToSelector:@selector(listController:needToPlayMedia:)] ) {
        [self.delegate listController:self needToPlayMedia:info];
    }
    
    [NSNotificationCenter.defaultCenter postNotificationName:SJPlaybackListControllerPrepareToPlayMediaNotification object:self];
}
- (void)currentMediaFinishedPlaying {
    if ( self.mode == SJPlaybackMode_RepeatOne ) {
        if ( [self.delegate respondsToSelector:@selector(listController:needToReplayCurrentMedia:)] ) {
            [self.delegate listController:self needToReplayCurrentMedia:self.currentMedia];
        }
    }
    else {
        [self playNextMedia];
    }
}

#pragma mark - unsafe

- (NSInteger)_unsafe_indexForMediaId:(NSInteger)mediaId {
    return [self _unsafe_medias:_m indexForMediaId:mediaId];
}

- (nullable id<SJMediaInfo>)_unsafe_mediaForMediaId:(NSInteger)mediaId {
    NSInteger idx = [self _unsafe_indexForMediaId:mediaId];
    if ( idx != NSNotFound ) {
        return _m[idx];
    }
    return nil;
}

- (void)_unsafe_addMedia:(id<SJMediaInfo>)media {
    if ( !media || self.currentMediaId == media.id )
        return;
    
    NSInteger idx = [self _unsafe_indexForMediaId:media.id];
    if ( idx != NSNotFound ) {
        [_m removeObjectAtIndex:idx];
    }
    [_m addObject:media];
}

- (NSInteger)_unsafe_medias:(NSArray<id<SJMediaInfo>> *)medias indexForMediaId:(NSInteger)mediaId {
    NSInteger idx = NSNotFound;
    for ( NSInteger i = 0 ; i < medias.count ; ++ i ) {
        id<SJMediaInfo> info = medias[i];
        if ( info.id == mediaId ) {
            idx = i;
            break;
        }
    }
    return idx;
}

- (nullable NSArray<id<SJMediaInfo>> *)_removeDuplicateMedias:(NSArray<id<SJMediaInfo>> *)medias {
    NSInteger count = medias.count;
    if ( 0 == count )
        return nil;
    NSMutableArray<id<SJMediaInfo>> *m = [NSMutableArray arrayWithCapacity:count];
    for ( id<SJMediaInfo> info in medias ) {
        NSInteger idx = [self _unsafe_medias:m indexForMediaId:info.id];
        if ( idx == NSNotFound ) {
            [m addObject:info];
        }
    }
    return m.copy;
}
@end
NS_ASSUME_NONNULL_END
