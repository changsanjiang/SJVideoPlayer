//
//  SJVideoPlayerAssetCarrier.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/1.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerAssetCarrier.h"
#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <SJObserverHelper/NSObject+SJObserverHelper.h>

/*!
 *  Refresh interval for timed observations of AVPlayer
 */
static float const __TimeRefreshInterval = 0.5;

/*!
 *  0.0 - 1.0
 */
static float const __GeneratePreImgScale = 0.05;


@interface NSTimer (SJAssetAdd)
+ (NSTimer *)assetAdd_timerWithTimeInterval:(NSTimeInterval)ti
                                      block:(void(^)(NSTimer *timer))block
                                    repeats:(BOOL)repeats;
@end

@interface SJAssetUIKitEctype: NSObject
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) NSInteger superviewTag;
@property (nonatomic, unsafe_unretained) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger scrollViewTag; // _scrollView `tag`
@property (nonatomic, strong) NSIndexPath *scrollViewIndexPath;
@property (nonatomic, unsafe_unretained) UIScrollView *rootScrollView;
@property (nonatomic, weak) UIView *tableHeaderSubView;
@property (nonatomic, assign) BOOL scrollIn_bool;
@property (nonatomic, assign) BOOL parent_scrollIn_bool;

@property (nonatomic, copy, readwrite) void(^playerItemStateChanged)(SJVideoPlayerAssetCarrier *asset, AVPlayerItemStatus status);
@property (nonatomic, copy, readwrite) void(^playTimeChanged)(SJVideoPlayerAssetCarrier *asset, NSTimeInterval currentTime, NSTimeInterval duration);
@property (nonatomic, copy, readwrite) void(^playDidToEnd)(SJVideoPlayerAssetCarrier *asset);
@property (nonatomic, copy, readwrite) void(^loadedTimeProgress)(float progress);
@property (nonatomic, copy, readwrite) void(^startBuffering)(SJVideoPlayerAssetCarrier *asset);
@property (nonatomic, copy, readwrite) void(^completeBuffer)(SJVideoPlayerAssetCarrier *asset);
@property (nonatomic, copy, readwrite) void(^cancelledBuffer)(SJVideoPlayerAssetCarrier *asset);
@property (nonatomic, copy, readwrite) void(^touchedScrollView)(SJVideoPlayerAssetCarrier *asset, BOOL tracking);
@property (nonatomic, copy, readwrite) void(^scrollViewDidScroll)(SJVideoPlayerAssetCarrier *asset);
@property (nonatomic, copy, readwrite) void(^presentationSize)(SJVideoPlayerAssetCarrier *asset, CGSize size);
@property (nonatomic, copy, readwrite) void(^scrollIn)(SJVideoPlayerAssetCarrier *asset, UIView *superView);
@property (nonatomic, copy, readwrite) void(^scrollOut)(SJVideoPlayerAssetCarrier *asset);
@property (nonatomic, copy, readwrite) void(^rateChanged)(SJVideoPlayerAssetCarrier *asset, float rate);

@end
@implementation SJAssetUIKitEctype
@end

#pragma mark -

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerAssetCarrier () {
    id _timeObserver;
    id _itemEndObserver;
    NSTimer *_bufferRefreshTimer;
    NSTimer *_refreshProgressTimer;
}

@property (nonatomic, strong, readwrite, nullable) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong, readwrite, nullable) AVAssetImageGenerator *tmp_imageGenerator;
@property (nonatomic, assign, readwrite) BOOL hasBeenGeneratedPreviewImages;
@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPreviewModel *> *generatedPreviewImages;
@property (nonatomic, assign, readwrite) BOOL jumped;
@property (nonatomic, assign, readwrite) BOOL scrollIn_bool;
@property (nonatomic, assign, readwrite) BOOL parent_scrollIn_bool;
@property (nonatomic, strong, readwrite, nullable) SJAssetUIKitEctype *ectype;
@property (nonatomic, assign, readwrite) CGSize maxItemSize;
@property (nonatomic, assign, readwrite) BOOL beginBuffer;
@property (nonatomic, strong, readonly) NSTimer *bufferRefreshTimer;
@property (nonatomic, strong, readwrite, nullable) AVAssetExportSession *exportSession;
@property (nonatomic, strong, readwrite, nullable) NSTimer *refreshProgressTimer;

@end
NS_ASSUME_NONNULL_END

@implementation SJVideoPlayerAssetCarrier

#pragma mark -

- (instancetype)initWithAssetURL:(NSURL *)assetURL {
    return [self initWithAssetURL:assetURL beginTime:0];
}

/// unit is sec.
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime {
    return [self initWithAssetURL:assetURL beginTime:beginTime scrollView:nil indexPath:nil superviewTag:0];
}

#pragma mark - Cell

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                      scrollView:(__unsafe_unretained UIScrollView * __nullable)scrollView
                       indexPath:(NSIndexPath * __nullable)indexPath
                    superviewTag:(NSInteger)superviewTag {
    return [self initWithAssetURL:assetURL beginTime:0 scrollView:scrollView indexPath:indexPath superviewTag:superviewTag];
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
                      scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag {
    return [self initWithAssetURL:assetURL beginTime:beginTime indexPath:indexPath superviewTag:superviewTag scrollViewIndexPath:nil scrollViewTag:0 scrollView:scrollView rootScrollView:nil];
}

#pragma mark - Table Header View.

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
    playerSuperViewOfTableHeader:(__weak UIView *)superView
                       tableView:(UITableView *)tableView {
    self = [self initWithAssetURL:assetURL
                        beginTime:beginTime
                       scrollView:tableView
                        indexPath:nil
                     superviewTag:0];
    if ( !self ) return nil;
    _tableHeaderSubView = superView;
    return self;
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
     collectionViewOfTableHeader:(__weak UICollectionView *)collectionView
         collectionCellIndexPath:(NSIndexPath *)indexPath
              playerSuperViewTag:(NSInteger)playerSuperViewTag
                   rootTableView:(UITableView *)rootTableView {
    self = [self initWithAssetURL:assetURL
                        beginTime:beginTime
                        indexPath:indexPath
                     superviewTag:playerSuperViewTag
              scrollViewIndexPath:nil
                    scrollViewTag:0
                       scrollView:collectionView
                   rootScrollView:rootTableView];
    if ( !self ) return nil;
    _tableHeaderSubView = collectionView;
    return self;
}

#pragma mark - Nested

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag
             scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                   scrollViewTag:(NSInteger)scrollViewTag
                  rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView {
    UIScrollView *scrollView = nil;
    if ( rootScrollView && 0 != scrollViewTag ) {
        if ( [rootScrollView isKindOfClass:[UITableView class]] ) {
            scrollView = [[(UITableView *)rootScrollView cellForRowAtIndexPath:scrollViewIndexPath] viewWithTag:scrollViewTag];
        }
        else if ( [rootScrollView isKindOfClass:[UICollectionView class]] ) {
            scrollView = [[(UICollectionView *)rootScrollView cellForItemAtIndexPath:scrollViewIndexPath] viewWithTag:scrollViewTag];
        }
    }
    return [self initWithAssetURL:assetURL beginTime:beginTime indexPath:indexPath superviewTag:superviewTag scrollViewIndexPath:scrollViewIndexPath scrollViewTag:scrollViewTag scrollView:scrollView rootScrollView:rootScrollView];
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag
             scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                   scrollViewTag:(NSInteger)scrollViewTag
                      scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                  rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView {
    self = [super init];
    if ( !self ) return nil;
    _assetURL = assetURL;
    _beginTime = beginTime; if ( 0 == _beginTime ) _jumped = YES;
    _scrollView = scrollView;
    _indexPath = indexPath;
    _superviewTag = superviewTag;
    _scrollViewTag = scrollViewTag;
    _rootScrollView = rootScrollView;
    _scrollViewIndexPath = scrollViewIndexPath;
    // default value
    _scrollIn_bool = YES;
    _parent_scrollIn_bool = YES;
    _rate = 1;
    
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _initializeAVPlayer];
        [self _itemObserving];
    });
    
    [self _scrollViewObserving];
    return self;
}

- (void)_initializeAVPlayer {
    _asset = [AVURLAsset assetWithURL:_assetURL];
    _playerItem = [AVPlayerItem playerItemWithAsset:_asset automaticallyLoadedAssetKeys:@[@"duration"]];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    if ( @available(iOS 10.0, *) ) {
        _player.automaticallyWaitsToMinimizeStalling = YES;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        _loadedPlayer = YES;
        if ( self.loadedPlayerExeBlock ) self.loadedPlayerExeBlock(self);
    });
}

- (void)_itemObserving {
    /*!
     AVPlayerItemStatusUnknown 该状态表示当前媒体还未载入并且还不在播放队列中.
     将`AVPlayerItem`与一个`AVPlayer`对象进行关联就开始将媒体放入队列中, 但是在具体内容可以播放前, 需要等待对象的状态由`unknown`变为`readyToPlay`.
     我们可以通过`KVO`来监听`status`的改变.
     
     AVPlayerItemStatusReadyToPlay,
     AVPlayerItemStatusFailed
     **/
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];
    
    CMTime interval = CMTimeMakeWithSeconds(__TimeRefreshInterval, NSEC_PER_SEC);
    __weak typeof(self) _self = self;
    _timeObserver =
    [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        if ( self.playTimeChanged ) self.playTimeChanged(self, currentTime, self.duration);
    }];
    
    _itemEndObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.playDidToEnd ) self.playDidToEnd(self);
    }];
}

- (void)_clearAVPlayer {
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"presentationSize"];
    [_playerItem removeObserver:self forKeyPath:@"duration"];
    [_tmp_imageGenerator cancelAllCGImageGeneration];
    [self cancelPreviewImagesGeneration];
    if ( 0 != _player.rate ) [_player pause];
    [_player removeTimeObserver:_timeObserver]; _timeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem]; _itemEndObserver = nil;
    _beginBuffer = NO;
    [self _cleanBufferTimer];
    if ( _cancelledBuffer ) _cancelledBuffer(self);
    [_exportSession cancelExport];
    _exportSession = nil;
    _loadedPlayer = NO;
    [self _cleanRefreshProgressTimer];
}

- (void)_scrollViewObserving {
    if ( _scrollView ) [self _observeScrollView:_scrollView];
    if ( _rootScrollView ) [self _observeScrollView:_rootScrollView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( [keyPath isEqualToString:@"contentOffset"] ) {
            [self _scrollViewDidScroll:object];
        }
        else if ( [keyPath isEqualToString:@"state"] ) {
            UIGestureRecognizerState state = [change[NSKeyValueChangeNewKey] integerValue];
            switch ( state ) {
                case UIGestureRecognizerStateChanged: break;
                case UIGestureRecognizerStatePossible: break;
                case UIGestureRecognizerStateBegan: {
                    if ( _touchedScrollView ) _touchedScrollView(self, YES);
                }
                    break;
                case UIGestureRecognizerStateEnded:
                case UIGestureRecognizerStateFailed:
                case UIGestureRecognizerStateCancelled: {
                    if ( _touchedScrollView ) _touchedScrollView(self, NO);
                }
                    break;
            }
        }
        else if ( [keyPath isEqualToString:@"loadedTimeRanges"] ) {
            if ( 0 == self.duration ) return;
            float progress = [self _loadedTimeSecs] / self.duration;
            _loadedTimeProgressValue = progress;
            if ( self.loadedTimeProgress ) self.loadedTimeProgress(progress);
        }
        else if ( [keyPath isEqualToString:@"status"] ) {
            if ( !_jumped &&
                AVPlayerItemStatusReadyToPlay == self.playerItem.status &&
                0 != self.beginTime ) {
                // begin time
                if ( _beginTime > self.duration ) return ;
                __weak typeof(self) _self = self;
                [self jumpedToTime:_beginTime completionHandler:^(BOOL finished) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    self.jumped = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ( self.playerItemStateChanged ) self.playerItemStateChanged(self, self.playerItem.status);
                    });
                }];
            }
            else {
                if ( self.playerItemStateChanged ) self.playerItemStateChanged(self, self.playerItem.status);
            }
        }
        else if ( [keyPath isEqualToString:@"duration"] ) {
            _duration = CMTimeGetSeconds(_playerItem.duration);
        }
        else if ( [keyPath isEqualToString:@"playbackBufferEmpty"] ) {
            [self _itemPlaybackBufferEmptyStateChanged];
        }
        else if ( [keyPath isEqualToString:@"presentationSize"] ) {
            if ( self.presentationSize ) self.presentationSize(self, self.playerItem.presentationSize);
        }
    });
}

#pragma mark - handle buffer

- (void)_itemPlaybackBufferEmptyStateChanged {
    if ( self.beginBuffer ) return;
    NSTimeInterval duration = floor(self.duration);
    NSTimeInterval close_currentTime = floor(self.currentTime) + 5;
    NSTimeInterval loadedTimeSecs = floor([self _loadedTimeSecs]);
    NSTimeInterval prepare = close_currentTime < duration ? close_currentTime : duration;
    BOOL factor = loadedTimeSecs >= prepare; // 如果缓存超过5秒
    if ( factor ) return;
    self.beginBuffer = YES;
    if ( self.startBuffering ) self.startBuffering(self);
    [self.bufferRefreshTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [[NSRunLoop currentRunLoop] addTimer:self.bufferRefreshTimer forMode:NSRunLoopCommonModes];
}

- (Float64)_loadedTimeSecs {
    CMTimeRange loadTimeRange = [_playerItem.loadedTimeRanges.firstObject CMTimeRangeValue];
    CMTime startTime = loadTimeRange.start;
    CMTime rangeDuration  = loadTimeRange.duration;
    Float64 seconds = CMTimeGetSeconds(startTime) + CMTimeGetSeconds(rangeDuration);
    return seconds;
}

- (NSTimer *)bufferRefreshTimer {
    if ( _bufferRefreshTimer ) return _bufferRefreshTimer;
    __weak typeof(self) _self = self;
    _bufferRefreshTimer = [NSTimer assetAdd_timerWithTimeInterval:2 block:^(NSTimer *timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        NSTimeInterval duration = floor(self.duration);
        NSTimeInterval close_currentTime = floor(self.currentTime) + 5;
        NSTimeInterval loadedTimeSecs = floor([self _loadedTimeSecs]);
        NSTimeInterval prepare = close_currentTime < duration ? close_currentTime : duration;
        BOOL factor = loadedTimeSecs >= prepare;
        if ( factor ) {
            [self _cleanBufferTimer];
            self.beginBuffer = NO;
            if ( self.completeBuffer ) self.completeBuffer(self);
        }
    } repeats:YES];
    return _bufferRefreshTimer;
}

- (void)_cleanBufferTimer {
    if ( _bufferRefreshTimer ) {
        [_bufferRefreshTimer invalidate];
        _bufferRefreshTimer = nil;
    }
}

#pragma mark -

- (void)setPresentationSize:(void (^)(SJVideoPlayerAssetCarrier * _Nonnull, CGSize))presentationSize {
    _presentationSize = [presentationSize copy];
    if ( !CGSizeEqualToSize(_playerItem.presentationSize, CGSizeZero) ) {
        if ( presentationSize ) presentationSize(self, _playerItem.presentationSize);
    }
}

#pragma mark -

- (UIImage *)screenshot {
    CMTime time = _playerItem.currentTime;
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_asset];
    generator.appliesPreferredTrackTransform = YES;
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:&time error:nil];
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    return image;
}

- (void)screenshotWithTime:(NSTimeInterval)t
                completion:(void(^)(SJVideoPlayerAssetCarrier *asset, SJVideoPreviewModel *images, NSError *__nullable error))block {
    return [self screenshotWithTime:t size:CGSizeZero completion:block];
}

- (void)screenshotWithTime:(NSTimeInterval)t
                      size:(CGSize)size
                completion:(void(^)(SJVideoPlayerAssetCarrier *asset, SJVideoPreviewModel *images, NSError *__nullable error))block {
    if ( !_playerItem || !_asset ) return;
    [_tmp_imageGenerator cancelAllCGImageGeneration];
    
    CMTime time = CMTimeMakeWithSeconds(t, NSEC_PER_SEC);
    _tmp_imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_asset];
    _tmp_imageGenerator.appliesPreferredTrackTransform = YES;
    _tmp_imageGenerator.maximumSize = size;
    __weak typeof(self) _self = self;
    [_tmp_imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( result == AVAssetImageGeneratorSucceeded ) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            if ( block ) block(self, [SJVideoPreviewModel previewModelWithImage:image localTime:actualTime], nil);
        }
        else if ( result == AVAssetImageGeneratorFailed ) {
            if ( block ) block(self, nil, error);
        }
    }];
}

#pragma mark -
- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize completion:(void (^)(SJVideoPlayerAssetCarrier * _Nonnull, NSArray<SJVideoPreviewModel *> * _Nullable, NSError * _Nullable))block {
    if ( self.hasBeenGeneratedPreviewImages && CGSizeEqualToSize(itemSize, self.maxItemSize) ) {
        if ( block ) block(self, self.generatedPreviewImages, nil);
        return;
    }
    
    if ( !_asset ) return;
    if ( 0 == _asset.duration.timescale ) return;
    NSMutableArray<NSValue *> *timesM = [NSMutableArray new];
    NSInteger seconds = (long)_asset.duration.value / _asset.duration.timescale;
    if ( 0 == seconds || isnan(seconds) ) return;
    if ( __GeneratePreImgScale > 1.0 || __GeneratePreImgScale <= 0 ) return;
    __block short maxCount = (short)floorf(1.0 / __GeneratePreImgScale);
    short interval = (short)floor(seconds * __GeneratePreImgScale);
    for ( short i = 0 ; i < maxCount ; i ++ ) {
        CMTime time = CMTimeMake(i * interval, 1);
        NSValue *tV = [NSValue valueWithCMTime:time];
        if ( tV ) [timesM addObject:tV];
    }
    __weak typeof(self) _self = self;
    NSMutableArray <SJVideoPreviewModel *> *imagesM = [NSMutableArray new];
    _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_asset];
    _imageGenerator.appliesPreferredTrackTransform = YES;
    _imageGenerator.maximumSize = itemSize;
    [_imageGenerator generateCGImagesAsynchronouslyForTimes:timesM completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        if ( result == AVAssetImageGeneratorSucceeded ) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            SJVideoPreviewModel *model = [SJVideoPreviewModel previewModelWithImage:image localTime:actualTime];
            if ( model ) [imagesM addObject:model];
        }
        else if ( result == AVAssetImageGeneratorFailed ) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( block ) block(self, nil, error);
            [self.imageGenerator cancelAllCGImageGeneration];
        }
        if ( --maxCount == 0 ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( 0 == imagesM.count ) return;
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                self.hasBeenGeneratedPreviewImages = YES;
                self.generatedPreviewImages = imagesM;
                self.maxItemSize = itemSize;
                if ( block ) block(self, imagesM, nil);
            });
        }
    }];
}

- (void)cancelPreviewImagesGeneration {
    [_imageGenerator cancelAllCGImageGeneration];
}

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    if ( isnan(time) ) { return;}
    CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    [self seekToTime:seekTime completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    if ( 1 == CMTimeCompare(time, _playerItem.duration) || AVPlayerStatusReadyToPlay != _playerItem.status ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    [_playerItem cancelPendingSeeks];
    __weak typeof(self) _self = self;
    [_playerItem seekToTime:time completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.player.rate = self.rate;
        if ( completionHandler ) completionHandler(finished);
    }];
}

- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    endTime:(NSTimeInterval)endTime
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(SJVideoPlayerAssetCarrier *asset, float progress))progress
                 completion:(void(^)(SJVideoPlayerAssetCarrier *asset, AVAsset *sandboxAsset, NSURL *fileURL, UIImage *thumbImage))completion
                    failure:(void(^)(SJVideoPlayerAssetCarrier *asset, NSError *error))failure {
    if ( endTime - beginTime <= 0 ) {
        if ( failure ) failure(self, [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"msg":@"Error: Start time is greater than end time!"}]);
        return;
    }
    if ( !presetName ) presetName = AVAssetExportPresetMediumQuality;
    [_exportSession cancelExport];
    [self _cleanRefreshProgressTimer];
    AVAsset *asset = self.asset;
    AVMutableComposition *compositionM = [AVMutableComposition composition];
    AVMutableCompositionTrack *audioTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *videoTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTimeRange cutRange = CMTimeRangeMake(CMTimeMakeWithSeconds(beginTime, NSEC_PER_SEC), CMTimeMakeWithSeconds(endTime - beginTime, NSEC_PER_SEC));
    AVAssetTrack *assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    AVAssetTrack *assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    NSError *error;
    [audioTrackM insertTimeRange:cutRange ofTrack:assetAudioTrack atTime:kCMTimeZero error:&error];
    if ( error ) { NSLog(@"Export Failed: error = %@", error); if ( failure ) failure(self, error); return;}
    [videoTrackM insertTimeRange:cutRange ofTrack:assetVideoTrack atTime:kCMTimeZero error:&error];
    if ( error ) { NSLog(@"Export Failed: error = %@", error); if ( failure ) failure(self, error); return;}
    
    NSURL *exportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"Export.mp4"];
    [[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
    _exportSession = [AVAssetExportSession exportSessionWithAsset:compositionM presetName:presetName];
    _exportSession.outputURL = exportURL;
    _exportSession.shouldOptimizeForNetworkUse = YES;
    _exportSession.outputFileType = AVFileTypeMPEG4;
    
    __weak typeof(self) _self = self;
    _refreshProgressTimer = [NSTimer assetAdd_timerWithTimeInterval:0.1 block:^(NSTimer *timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( progress ) progress(self, self.exportSession.progress);
    } repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_refreshProgressTimer forMode:NSRunLoopCommonModes];
    [_refreshProgressTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    [_exportSession exportAsynchronouslyWithCompletionHandler:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.exportSession.status == AVAssetExportSessionStatusCancelled ||
            self.exportSession.status == AVAssetExportSessionStatusCompleted ||
            self.exportSession.status == AVAssetExportSessionStatusFailed ) {
            [self _cleanRefreshProgressTimer];
        }
        
        switch ( self.exportSession.status ) {
            case AVAssetExportSessionStatusUnknown:
            case AVAssetExportSessionStatusWaiting:
            case AVAssetExportSessionStatusCancelled:
            case AVAssetExportSessionStatusExporting:
                break;
            case AVAssetExportSessionStatusCompleted: {
                [self screenshotWithTime:beginTime completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, SJVideoPreviewModel * _Nullable images, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __strong typeof(_self) self = _self;
                        if ( !self ) return;
                        if ( progress ) progress(self, 1);
                        if ( completion ) completion(self, compositionM, exportURL, images.image);
                    });
                }];
            }
                break;
            case AVAssetExportSessionStatusFailed: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    if ( failure ) failure(self, error);
                });
            }
                break;
        }
    }];
}

- (void)_cleanRefreshProgressTimer {
    [_refreshProgressTimer invalidate];
    _refreshProgressTimer = nil;
}

#pragma mark -
@synthesize duration = _duration;
- (NSTimeInterval)duration {
    return _duration;
}

- (NSTimeInterval)currentTime {
    return CMTimeGetSeconds(_playerItem.currentTime);
}

- (float)progress {
    NSInteger duration = self.duration;
    if ( 0 == duration ) return 0;
    else return self.currentTime / duration;
}

- (void)setRate:(float)rate {
    _rate = rate;
    _player.rate = rate;
    if ( _rateChanged ) _rateChanged(self, rate);
}

#pragma mark -

- (void)dealloc {
    [self _clearAVPlayer];
    if ( _deallocExeBlock ) _deallocExeBlock(self);
}

#pragma mark

- (void)_scrollViewDidScroll:(UIScrollView *)scrollView {
    if ( !_scrollView ) return;
    if ( scrollView == _scrollView ) {
        if ( _scrollViewDidScroll ) _scrollViewDidScroll(self);
    }
    
    if ( self.tableHeaderSubView ) {
        [self playOnHeader_scrollViewDidScroll:scrollView];
    }
    else {
        [self playOnCell_scrollViewDidScroll:scrollView];
    }
}

- (void)playOnHeader_scrollViewDidScroll:(UIScrollView *)scrollView {
    if ( [self.tableHeaderSubView isKindOfClass:[UICollectionView class]] &&
        scrollView == self.tableHeaderSubView ) {
        UICollectionView *collectionView = (UICollectionView *)scrollView;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.indexPath];
        bool visable = [collectionView.visibleCells containsObject:cell];
        self.scrollIn_bool = visable;
    }
    else {
        CGFloat offsetY = scrollView.contentOffset.y;
        if ( offsetY < self.tableHeaderSubView.frame.size.height ) {
            if ( [self.scrollView isKindOfClass:[UITableView class]] ) {
                self.scrollIn_bool = YES;
            }
            else {
                UICollectionView *collectionView = (UICollectionView *)self.scrollView;
                UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.indexPath];
                self.scrollIn_bool = [collectionView.visibleCells containsObject:cell];
            }
        }
        else {
            self.scrollIn_bool = NO;
        }
    }
}

- (void)playOnCell_scrollViewDidScroll:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = nil;
    if ( scrollView == _scrollView ) {
        indexPath = _indexPath;
    }
    else {
        indexPath = _scrollViewIndexPath;
    }
    
    if ( [scrollView isKindOfClass:[UITableView class]] ) {
        UITableView *tableView = (UITableView *)scrollView;
        __block BOOL visable = NO;
        [tableView.indexPathsForVisibleRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( [obj compare:indexPath] == NSOrderedSame ) {
                visable = YES;
                *stop = YES;
            }
        }];
        if ( scrollView == _rootScrollView ) {
            if ( visable == self.parent_scrollIn_bool ) return;
            self.parent_scrollIn_bool = visable;
            if ( visable ) [self _updateScrollView];
        }
        self.scrollIn_bool = self.parent_scrollIn_bool && visable;
    }
    else if ( [scrollView isKindOfClass:[UICollectionView class]] ) {
        UICollectionView *collectionView = (UICollectionView *)scrollView;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        bool visable = [collectionView.visibleCells containsObject:cell];
        if ( scrollView == _rootScrollView ) {
            if ( visable == self.parent_scrollIn_bool ) return;
            self.parent_scrollIn_bool = visable;
            if ( visable ) [self _updateScrollView];
        }
        self.scrollIn_bool = self.parent_scrollIn_bool && visable;
    }
}

- (void)setScrollIn_bool:(BOOL)scrollIn_bool {
    _scrollIn_bool = scrollIn_bool;
    if ( scrollIn_bool ) {
        if ( _scrollIn ) _scrollIn(self, [self _getVideoPlayerSuperView]);
    }
    else {
        if ( _scrollOut ) _scrollOut(self);
    }
}

- (void)_updateScrollView {
    UIScrollView *newScrollView = nil;
    if      ( [_rootScrollView isKindOfClass:[UITableView class]] ) {
        UITableView *parent = (UITableView *)_rootScrollView;
        UITableViewCell *parentCell = [parent cellForRowAtIndexPath:_scrollViewIndexPath];
        newScrollView = [parentCell viewWithTag:_scrollViewTag];
    }
    else if ( [_rootScrollView isKindOfClass:[UICollectionView class]] ) {
        UICollectionView *parent = (UICollectionView *)_rootScrollView;
        UICollectionViewCell *parentCell = [parent cellForItemAtIndexPath:_scrollViewIndexPath];
        newScrollView = [parentCell viewWithTag:_scrollViewTag];
    }
    
    if ( !newScrollView || newScrollView == _scrollView ) return;
    
    // set new scrollview
    _scrollView = newScrollView;
    
    // add observer
    [self _observeScrollView:newScrollView];
}

- (UIView *)_getVideoPlayerSuperView {
    UIView *superView = nil;
    if ( [_scrollView isKindOfClass:[UITableView class]] ) {
        UITableView *tableView = (UITableView *)_scrollView;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:_indexPath];
        superView = [cell.contentView viewWithTag:_superviewTag];
    }
    else if ( [_scrollView isKindOfClass:[UICollectionView class]] ) {
        UICollectionView *collectionView = (UICollectionView *)_scrollView;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:_indexPath];
        superView = [cell.contentView viewWithTag:_superviewTag];
    }
    return superView;
}

- (void)_observeScrollView:(UIScrollView *)scrollView {
    [scrollView sj_addObserver:self forKeyPath:@"contentOffset"];
    [scrollView.panGestureRecognizer sj_addObserver:self forKeyPath:@"state"];
}

- (NSString *)timeString:(NSInteger)secs {
    NSInteger min = 60;
    NSInteger hour = 60 * min;
    
    NSInteger hours, seconds, minutes;
    hours = secs / hour;
    minutes = (secs - hours * hour) / 60;
    seconds = secs % 60;
    if ( self.duration < hour ) {
        return [NSString stringWithFormat:@"%02zd:%02zd", minutes, seconds];
    }
    else {
        return [NSString stringWithFormat:@"%02zd:%02zd:%02zd", hours, minutes, seconds];
    }
}

- (void)refreshAVPlayer {
    @synchronized(self) {
        [self _clearAVPlayer];
        [self _initializeAVPlayer];
        [self _itemObserving];
    }
}

- (void)convertToOriginal {
    if ( !_converted ) return;
    [self _convertingWithBlock:^{
        _indexPath = _ectype.indexPath;
        _superviewTag = _ectype.superviewTag;
        _scrollView = _ectype.scrollView;
        _scrollViewTag = _ectype.scrollViewTag;
        _scrollViewIndexPath = _ectype.scrollViewIndexPath;
        _rootScrollView = _ectype.rootScrollView;
        _tableHeaderSubView = _ectype.tableHeaderSubView;
        _scrollIn_bool = _ectype.scrollIn_bool;
        _parent_scrollIn_bool = _ectype.parent_scrollIn_bool;
        
        _playerItemStateChanged = _ectype.playerItemStateChanged;
        _playTimeChanged = _ectype.playTimeChanged;
        _playDidToEnd = _ectype.playDidToEnd;
        _loadedTimeProgress = _ectype.loadedTimeProgress;
        _startBuffering = _ectype.startBuffering;
        _completeBuffer = _ectype.completeBuffer;
        _cancelledBuffer = _ectype.cancelledBuffer;
        _touchedScrollView = _ectype.touchedScrollView;
        _scrollViewDidScroll = _ectype.scrollViewDidScroll;
        _presentationSize = _ectype.presentationSize;
        _scrollIn = _ectype.scrollIn;
        _scrollOut = _ectype.scrollOut;
        _rateChanged = _ectype.rateChanged;
    }];
    _converted = NO;
}

- (void)_clearUIKit {
    if ( !_ectype ) {
        _ectype = [SJAssetUIKitEctype new];
        _ectype.indexPath = _indexPath;
        _ectype.superviewTag = _superviewTag;
        _ectype.scrollView = _scrollView;
        _ectype.scrollViewTag = _scrollViewTag;
        _ectype.scrollViewIndexPath = _scrollViewIndexPath;
        _ectype.rootScrollView = _rootScrollView;
        _ectype.tableHeaderSubView = _tableHeaderSubView;
        _ectype.scrollIn_bool = _scrollIn_bool;
        _ectype.parent_scrollIn_bool = _parent_scrollIn_bool;
        
        _ectype.playerItemStateChanged = _playerItemStateChanged;
        _ectype.playTimeChanged = _playTimeChanged;
        _ectype.playDidToEnd = _playDidToEnd;
        _ectype.loadedTimeProgress = _loadedTimeProgress;
        _ectype.startBuffering = _startBuffering;
        _ectype.completeBuffer = _completeBuffer;
        _ectype.cancelledBuffer = _cancelledBuffer;
        _ectype.touchedScrollView = _touchedScrollView;
        _ectype.scrollViewDidScroll = _scrollViewDidScroll;
        _ectype.presentationSize = _presentationSize;
        _ectype.scrollIn = _scrollIn;
        _ectype.scrollOut = _scrollOut;
        _ectype.rateChanged = _rateChanged;
    }
    
    _indexPath = nil;
    _superviewTag = 0;
    _scrollView = nil;
    _scrollViewTag = 0;
    _scrollViewIndexPath = nil;
    _rootScrollView = nil;
    _tableHeaderSubView = nil;
    _scrollIn_bool = YES;
    _parent_scrollIn_bool = YES;
}

- (void)convertToUIView {
    [self _convertingWithBlock:nil];
}

- (void)convertToCellWithTableOrCollectionView:(__unsafe_unretained UIScrollView *)tableOrCollectionView
                                     indexPath:(NSIndexPath *)indexPath
                            playerSuperviewTag:(NSInteger)superviewTag {
    [self _convertingWithBlock:^{
        _indexPath = indexPath;
        _superviewTag = superviewTag;
        _scrollView = tableOrCollectionView;
    }];
}

- (void)convertToTableHeaderViewWithPlayerSuperView:(__weak UIView *)superView
                                          tableView:(__unsafe_unretained UITableView *)tableView {
    [self _convertingWithBlock:^{
        _tableHeaderSubView = superView;
        _scrollView = tableView;
    }];
}

- (void)convertToTableHeaderViewWithCollectionView:(__weak UICollectionView *)collectionView
                           collectionCellIndexPath:(NSIndexPath *)indexPath
                                playerSuperViewTag:(NSInteger)playerSuperViewTag
                                     rootTableView:(__unsafe_unretained UITableView *)rootTableView {
    [self _convertingWithBlock:^{
        _scrollView = collectionView;
        _indexPath = indexPath;
        _superviewTag = playerSuperViewTag;
        _rootScrollView = rootTableView;
    }];
}

- (void)convertToCellWithIndexPath:(NSIndexPath *)indexPath
                      superviewTag:(NSInteger)superviewTag
           collectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath
                 collectionViewTag:(NSInteger)collectionViewTag
                     rootTableView:(__unsafe_unretained UITableView *)rootTableView {
    [self _convertingWithBlock:^{
        _indexPath = indexPath;
        _superviewTag = superviewTag;
        _scrollView = [[rootTableView cellForRowAtIndexPath:collectionViewIndexPath] viewWithTag:collectionViewTag];
        _scrollViewTag = collectionViewTag;
        _rootScrollView = rootTableView;
    }];
}

- (void)_convertingWithBlock:(void(^)(void))block {
    [self _clearUIKit];
    if ( block ) block();
    [self _scrollViewObserving];
    _converted = YES;
}

@end


#pragma mark -


@implementation SJVideoPreviewModel

+ (instancetype)previewModelWithImage:(UIImage *)image localTime:(CMTime)time {
    SJVideoPreviewModel *model = [self new];
    model -> _image = image;
    model -> _localTime = time;
    return model;
}

@end


@implementation NSTimer (SJAssetAdd)
+ (NSTimer *)assetAdd_timerWithTimeInterval:(NSTimeInterval)ti
                                      block:(void(^)(NSTimer *timer))block
                                    repeats:(BOOL)repeats {
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti
                                             target:self
                                           selector:@selector(assetAdd_exeBlock:)
                                           userInfo:block
                                            repeats:repeats];
    return timer;
}

+ (void)assetAdd_exeBlock:(NSTimer *)timer {
    void(^block)(NSTimer *timer) = timer.userInfo;
    if ( block ) block(timer);
}

@end
