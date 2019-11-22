//
//  SJAVMediaPlayerDefinitionLoader.m
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2019/11/20.
//

#import "SJAVMediaPlayerDefinitionLoader.h"
#import "SJAVMediaPlayerLoader.h"
#import "SJAVMediaPresentView.h"
#import "SJAVMediaPresentController.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlayerDefinitionLoader ()
@property (nonatomic, strong) SJAVMediaPlayer *innerPlayer;
@property (nonatomic, strong) SJAVMediaPresentView *innerPresentView;
@end

@implementation SJAVMediaPlayerDefinitionLoader {
    void(^_completionHandler)(SJAVMediaPlayerDefinitionLoader *loader);
    BOOL _isSeeking;
}

- (instancetype)initWithMedia:(id<SJAVMediaModelProtocol>)media dataSource:(id<SJAVMediaPlayerDefinitionLoaderDataSource>)dataSource completionHandler:(void (^)(SJAVMediaPlayerDefinitionLoader * _Nonnull))completionHandler {
    self = [super init];
    if ( self ) {
        _media = media;
        _completionHandler = completionHandler;
        _dataSource = dataSource;

        _innerPlayer = [SJAVMediaPlayerLoader loadPlayerForMedia:media];
        _innerPlayer.muted = YES;
            
        UIView *superview = self.dataSource.superview;
        _innerPresentView = [SJAVMediaPresentView.alloc initWithFrame:superview.bounds player:_innerPlayer];
        [dataSource.presentController insertPresentViewToBack:_innerPresentView];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_statusDidChange) name:SJAVMediaPlayerAssetStatusDidChangeNotification object:_innerPlayer];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_statusDidChange) name:SJAVMediaPresentViewReadyForDisplayDidChangeNotification object:_innerPresentView];
    }
    return self;
}

- (void)_statusDidChange {
    switch ( _innerPlayer.sj_assetStatus ) {
        case SJAssetStatusUnknown:
        case SJAssetStatusPreparing:
            break;
        case SJAssetStatusReadyToPlay: {
            if ( _innerPresentView.isReadyForDisplay && _isSeeking == NO ) {
                [self _seekToCurPos];
            }
        }
            break;
        case SJAssetStatusFailed:
            [self _didCompleteLoad:NO];
            break;
    }
}

- (void)_seekToCurPos {
    _isSeeking = YES;
    
    if ( _innerPlayer.sj_playbackInfo.playbackType == SJPlaybackTypeLIVE ) {
        [self _didCompleteLoad:YES];
        return;
    }
    
    __weak typeof(self) _self = self;
    [_innerPlayer seekToTime:self.dataSource.player ? self.dataSource.player.currentTime : kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _didCompleteLoad:finished];
    }];
}

- (void)_didCompleteLoad:(BOOL)result {
    if ( result ) {
        [_innerPresentView removeFromSuperview];
        _presentView = _innerPresentView;
        
        _innerPlayer.muted = NO;
        _player = _innerPlayer;
    }
    else {
        [_innerPresentView removeFromSuperview];
        _innerPresentView = nil;
        [_innerPlayer pause];
        _innerPlayer = nil;
    }
    if ( _completionHandler ) _completionHandler(self);
    _completionHandler = nil;
}

- (void)cancel {
    _completionHandler = nil;

    [_innerPresentView removeFromSuperview];
    _innerPresentView = nil;

    [_innerPlayer pause];
    _innerPlayer = nil;
}
@end
NS_ASSUME_NONNULL_END
