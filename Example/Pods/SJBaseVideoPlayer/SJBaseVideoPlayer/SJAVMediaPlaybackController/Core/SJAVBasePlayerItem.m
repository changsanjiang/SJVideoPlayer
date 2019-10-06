//
//  SJAVBasePlayerItem.m
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/9/25.
//

#import "SJAVBasePlayerItem.h"

NS_ASSUME_NONNULL_BEGIN
static NSNotificationName const SJAVBasePlayerItemStatusDidChangeNotification = @"SJAVBasePlayerItemStatusDidChangeNotification";
static NSNotificationName const SJAVBasePlayerItemPlaybackLikelyToKeepUpDidChangeNotification = @"SJAVBasePlayerItemPlaybackLikelyToKeepUpDidChangeNotification";
static NSNotificationName const SJAVBasePlayerItemPlaybackBufferEmptyDidChangeNotification = @"SJAVBasePlayerItemPlaybackBufferEmptyDidChangeNotification";
static NSNotificationName const SJAVBasePlayerItemPlaybackBufferFullDidChangeNotification = @"SJAVBasePlayerItemPlaybackBufferFullDidChangeNotification";
static NSNotificationName const SJAVBasePlayerItemLoadedTimeRangesDidChangeNotification = @"SJAVBasePlayerItemLoadedTimeRangesDidChangeNotification";
static NSNotificationName const SJAVBasePlayerItemPresentationSizeDidChangeNotification = @"SJAVBasePlayerItemPresentationSizeDidChangeNotification";


@implementation SJAVBasePlayerItem
- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [super initWithAsset:asset];
    if ( self ) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self _initObservations];
        });
    }
    return self;
}

static NSString *kStatus = @"status";
static NSString *kPlaybackLikelyToKeepUp = @"playbackLikelyToKeepUp";
static NSString *kPlaybackBufferEmpty = @"playbackBufferEmpty";
static NSString *kPlaybackBufferFull = @"playbackBufferFull";
static NSString *kLoadedTimeRanges = @"loadedTimeRanges";
static NSString *kPresentationSize = @"presentationSize";

- (void)_initObservations {
    NSKeyValueObservingOptions ops = NSKeyValueObservingOptionNew;
    [self addObserver:self forKeyPath:kStatus options:ops context:&kStatus];
    [self addObserver:self forKeyPath:kPlaybackLikelyToKeepUp options:ops context:&kPlaybackLikelyToKeepUp];
    [self addObserver:self forKeyPath:kPlaybackBufferEmpty options:ops context:&kPlaybackBufferEmpty];
    [self addObserver:self forKeyPath:kPlaybackBufferFull options:ops context:&kPlaybackBufferFull];
    [self addObserver:self forKeyPath:kLoadedTimeRanges options:ops context:&kLoadedTimeRanges];
    [self addObserver:self forKeyPath:kPresentationSize options:ops context:&kPresentationSize];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
    [self removeObserver:self forKeyPath:kStatus];
    [self removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
    [self removeObserver:self forKeyPath:kPlaybackBufferEmpty];
    [self removeObserver:self forKeyPath:kPlaybackBufferFull];
    [self removeObserver:self forKeyPath:kLoadedTimeRanges];
    [self removeObserver:self forKeyPath:kPresentationSize];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    NSNotificationName _Nullable name = nil;
    if ( context == &kStatus )
        name = SJAVBasePlayerItemStatusDidChangeNotification;
    else if ( context == &kPlaybackLikelyToKeepUp )
        name = SJAVBasePlayerItemPlaybackLikelyToKeepUpDidChangeNotification;
    else if ( context == &kPlaybackBufferEmpty )
        name = SJAVBasePlayerItemPlaybackBufferEmptyDidChangeNotification;
    else if ( context == &kPlaybackBufferFull )
        name = SJAVBasePlayerItemPlaybackBufferFullDidChangeNotification;
    else if ( context == &kLoadedTimeRanges )
        name = SJAVBasePlayerItemLoadedTimeRangesDidChangeNotification;
    else if ( context == &kPresentationSize )
        name = SJAVBasePlayerItemPresentationSizeDidChangeNotification;

    if ( name != nil )
        [NSNotificationCenter.defaultCenter postNotificationName:name object:self];
}
@end


@interface SJAVBasePlayerItemObserver ()
@property (nonatomic, weak, readonly, nullable) SJAVBasePlayerItem *item;
@end
@implementation SJAVBasePlayerItemObserver
- (instancetype)initWithBasePlayerItem:(SJAVBasePlayerItem *)item {
    self = [super init];
    if ( self ) {
        _item = item;
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerItemStatusDidChange:) name:SJAVBasePlayerItemStatusDidChangeNotification object:item];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playbackLikelyToKeepUpDidChange:) name:SJAVBasePlayerItemPlaybackLikelyToKeepUpDidChangeNotification object:item];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playbackBufferEmptyDidChange:) name:SJAVBasePlayerItemPlaybackBufferEmptyDidChangeNotification object:item];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playbackBufferFullDidChange:) name:SJAVBasePlayerItemPlaybackBufferFullDidChangeNotification object:item];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(loadedTimeRangesDidChange:) name:SJAVBasePlayerItemLoadedTimeRangesDidChangeNotification object:item];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(presentationSizeDidChange:) name:SJAVBasePlayerItemPresentationSizeDidChangeNotification object:item];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(failedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:item];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(newAccessLogEntry:) name:AVPlayerItemNewAccessLogEntryNotification object:item];
    }
    return self;
}
- (void)playerItemStatusDidChange:(NSNotification *)note {
    if ( note.object == _item && _statusDidChangeExeBlock != nil ) _statusDidChangeExeBlock(_item);
}
- (void)playbackLikelyToKeepUpDidChange:(NSNotification *)note {
    if ( note.object == _item && _playbackLikelyToKeepUpExeBlock != nil ) _playbackLikelyToKeepUpExeBlock(_item);
}
- (void)playbackBufferEmptyDidChange:(NSNotification *)note {
    if ( note.object == _item && _playbackBufferEmptyDidChangeExeBlock != nil ) _playbackBufferEmptyDidChangeExeBlock(_item);
}
- (void)playbackBufferFullDidChange:(NSNotification *)note {
    if ( note.object == _item && _playbackBufferFullDidChangeExeBlock != nil ) _playbackBufferFullDidChangeExeBlock(_item);
}
- (void)loadedTimeRangesDidChange:(NSNotification *)note {
    if ( note.object == _item && _loadedTimeRangesDidChangeExeBlock != nil ) _loadedTimeRangesDidChangeExeBlock(_item);
}
- (void)presentationSizeDidChange:(NSNotification *)note {
    if ( note.object == _item && _presentationSizeDidChangeExeBlock != nil ) _presentationSizeDidChangeExeBlock(_item);
}
- (void)failedToPlayToEndTime:(NSNotification *)note {
    NSError *_Nullable error = note.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
    if ( error != nil ) {
        if ( note.object == _item && _failedToPlayToEndTimeExeBlock != nil ) _failedToPlayToEndTimeExeBlock(_item, error);
    }
}
- (void)didPlayToEndTime:(NSNotification *)note {
    if ( note.object == _item && _didPlayToEndTimeExeBlock != nil ) _didPlayToEndTimeExeBlock(_item);
}
- (void)newAccessLogEntry:(NSNotification *)note {
    if ( note.object == _item && _newAccessLogEntryExeBlock != nil ) _newAccessLogEntryExeBlock(_item);
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
@end
NS_ASSUME_NONNULL_END
