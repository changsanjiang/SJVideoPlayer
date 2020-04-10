//
//  SJAVMediaPlaybackController.m
//  Pods
//
//  Created by 畅三江 on 2020/2/18.
//

#import "SJAVMediaPlaybackController.h"
#import "SJAVMediaPlayerLoader.h"
#import "SJAVMediaPlayer.h"
#import "SJAVMediaPlayerLayerView.h"
#import "SJVideoPlayerURLAsset+SJAVMediaPlaybackAdd.h"
#import "AVAsset+SJAVMediaExport.h"

NS_ASSUME_NONNULL_BEGIN
 
@implementation SJAVMediaPlaybackController
@dynamic currentPlayer;

- (instancetype)init {
    self = [super init];
    if ( self ) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_av_playbackTypeDidChange:) name:SJMediaPlayerPlaybackTypeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark -

- (void)playerWithMedia:(SJVideoPlayerURLAsset *)media completionHandler:(void (^)(id<SJMediaPlayer> _Nullable))completionHandler {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        SJAVMediaPlayer *player = [SJAVMediaPlayerLoader loadPlayerForMedia:media];
        player.minBufferedDuration = self.minBufferedDuration;
        player.accurateSeeking = self.accurateSeeking;
        
        if ( (player.isPlayed && media.original == nil) || player.isPlaybackFinished ) {
            [player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ( completionHandler ) completionHandler(player);
                });
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( completionHandler ) completionHandler(player);
            });
        }
    });
}

- (UIView<SJMediaPlayerView> *)playerViewWithPlayer:(SJAVMediaPlayer *)player {
    SJAVMediaPlayerLayerView *view = [SJAVMediaPlayerLayerView.alloc initWithFrame:CGRectZero];
    view.layer.player = player.avPlayer;
    return view;
}
 
- (void)receivedApplicationDidBecomeActiveNotification {
    SJAVMediaPlayerLayerView *view = self.currentPlayerView;
    view.layer.player = self.currentPlayer.avPlayer;
}
 
- (void)receivedApplicationDidEnterBackgroundNotification {
    if ( self.pauseWhenAppDidEnterBackground ) {
        [self pause];
    }
    else {
        SJAVMediaPlayerLayerView *view = self.currentPlayerView;
        view.layer.player = nil;
    }
}

- (void)replaceMediaForDefinitionMedia:(SJVideoPlayerURLAsset *)definitionMedia {
    [SJAVMediaPlayerLoader clearPlayerForMedia:self.media];
    [super replaceMediaForDefinitionMedia:definitionMedia];
}

#pragma mark -

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^_Nullable)(BOOL))completionHandler {
    if ( self.media.trialEndPosition != 0 && CMTimeGetSeconds(time) >= self.media.trialEndPosition ) {
        time = CMTimeMakeWithSeconds(self.media.trialEndPosition * 0.98, NSEC_PER_SEC);
    }
    [self.currentPlayer seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
}

- (NSTimeInterval)durationWatched {
    NSTimeInterval time = 0;
    for ( AVPlayerItemAccessLogEvent *event in self.currentPlayer.avPlayer.currentItem.accessLog.events) {
        if ( event.durationWatched <= 0 ) continue;
        time += event.durationWatched;
    }
    return time;
}

- (void)setAccurateSeeking:(BOOL)accurateSeeking {
    _accurateSeeking = accurateSeeking;
    self.currentPlayer.accurateSeeking = accurateSeeking;
}

- (void)setMinBufferedDuration:(NSTimeInterval)minBufferedDuration {
    [super setMinBufferedDuration:minBufferedDuration];
    self.currentPlayer.minBufferedDuration = minBufferedDuration;
}

- (void)refresh {
    if ( self.media != nil ) [SJAVMediaPlayerLoader clearPlayerForMedia:self.media];
    [super refresh];
}

- (void)stop {
    [self cancelGenerateGIFOperation];
    [self cancelExportOperation];
    [super stop];
}

- (SJPlaybackType)playbackType {
    return self.currentPlayer.playbackType;
}

#pragma mark -

- (void)_av_playbackTypeDidChange:(NSNotification *)note {
    if ( note.object == self.currentPlayer ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:playbackTypeDidChange:)] ) {
            [self.delegate playbackController:self playbackTypeDidChange:self.playbackType];
        }
    }
}
@end


@implementation SJAVMediaPlaybackController (SJAVMediaPlaybackAdd)
- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(SJAVMediaPlaybackController *controller, UIImage * __nullable image, NSError *__nullable error))block {
    __weak typeof(self) _self = self;
    [self.currentPlayer.avPlayer.currentItem.asset sj_screenshotWithTime:time size:size completionHandler:^(AVAsset * _Nonnull a, UIImage * _Nullable image, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self, image, error);
    }];
}

- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                   duration:(NSTimeInterval)duration
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(SJAVMediaPlaybackController *controller, float progress))progressBlock
                 completion:(void(^)(SJAVMediaPlaybackController *controller, NSURL * __nullable saveURL, UIImage * __nullable thumbImage))completionBlock
                    failure:(void(^)(SJAVMediaPlaybackController *controller, NSError * __nullable error))failureBlock {
    [self cancelExportOperation];
    NSURL *exportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"Export.mp4"];
    [[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
    __weak typeof(self) _self = self;
    [self.currentPlayer.avPlayer.currentItem.asset sj_exportWithStartTime:beginTime duration:duration toFile:exportURL presetName:presetName progress:^(AVAsset * _Nonnull a, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( progressBlock ) progressBlock(self, progress);
    } success:^(AVAsset * _Nonnull a, AVAsset * _Nullable sandboxAsset, NSURL * _Nullable fileURL, UIImage * _Nullable thumbImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completionBlock ) completionBlock(self, fileURL, thumbImage);
    } failure:^(AVAsset * _Nonnull a, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failureBlock ) failureBlock(self, error);
    }];
}

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(SJAVMediaPlaybackController *controller, float progress))progressBlock
                      completion:(void(^)(SJAVMediaPlaybackController *controller, UIImage *imageGIF, UIImage *screenshot))completion
                         failure:(void(^)(SJAVMediaPlaybackController *controller, NSError *error))failure {
    [self cancelGenerateGIFOperation];
    __weak typeof(self) _self = self;
    [self.currentPlayer.avPlayer.currentItem.asset sj_generateGIFWithBeginTime:beginTime duration:duration imageMaxSize:maximumSize interval:interval toFile:gifSavePath progress:^(AVAsset * _Nonnull a, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( progressBlock ) progressBlock(self, progress);
    } success:^(AVAsset * _Nonnull a, UIImage * _Nonnull GIFImage, UIImage * _Nonnull thumbnailImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completion ) completion(self, GIFImage, thumbnailImage);
    } failure:^(AVAsset * _Nonnull a, NSError * _Nonnull error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failure ) failure(self, error);
    }];
}

- (void)cancelExportOperation {
    [self.currentPlayer.avPlayer.currentItem.asset sj_cancelExportOperation];
}
- (void)cancelGenerateGIFOperation {
    [self.currentPlayer.avPlayer.currentItem.asset sj_cancelGenerateGIFOperation];
}
@end

NS_ASSUME_NONNULL_END
