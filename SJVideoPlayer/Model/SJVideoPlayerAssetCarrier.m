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

/*!
 *  Refresh interval for timed observations of AVPlayer
 */
#define SJREFRESH_INTERVAL (0.5)

/*!
 *  0.0 - 1.0
 */
#define SJPreImgGenerateInterval (0.05)


@interface SJTmpObj : NSObject
@property (nonatomic, copy) void(^deallocCallBlock)(SJTmpObj *obj);
@end

@implementation SJTmpObj
- (void)dealloc {
    if ( _deallocCallBlock ) _deallocCallBlock(self);
}
@end


@interface SJVideoPlayerAssetCarrier () {
    id _timeObserver;
    id _itemEndObserver;
}

@property (nonatomic, strong, readwrite) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, assign, readwrite) BOOL hasBeenGeneratedPreviewImages;
@property (nonatomic, strong, readwrite) NSArray<SJVideoPreviewModel *> *generatedPreviewImages;
@property (nonatomic, assign, readwrite) BOOL removedScrollObserver;

@end

@implementation SJVideoPlayerAssetCarrier

- (instancetype)initWithAssetURL:(NSURL *)assetURL {
    return [self initWithAssetURL:assetURL beginTime:0];
}

/// unit is sec.
- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime {
    return [self initWithAssetURL:assetURL beginTime:beginTime scrollView:nil indexPath:nil superviewTag:0];
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                      scrollView:(UIScrollView * __nullable)scrollView
                       indexPath:(NSIndexPath * __nullable)indexPath
                    superviewTag:(NSInteger)superviewTag {
    return [self initWithAssetURL:assetURL beginTime:0 scrollView:scrollView indexPath:indexPath superviewTag:superviewTag];
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
                      scrollView:(UIScrollView *__unsafe_unretained)scrollView
                       indexPath:(NSIndexPath *__weak)indexPath
                    superviewTag:(NSInteger)superviewTag {
    self = [super init];
    if ( !self ) return nil;
    _asset = [AVURLAsset assetWithURL:assetURL];
    _playerItem = [AVPlayerItem playerItemWithAsset:_asset automaticallyLoadedAssetKeys:@[@"duration"]];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _assetURL = assetURL;
    _beginTime = beginTime;
    _scrollView = scrollView;
    _indexPath = indexPath;
    _superviewTag = superviewTag;
    [self _addTimeObserver];
    [self _addItemPlayEndObserver];
    [self _observing];
    return self;
}

- (void)_addTimeObserver {
    CMTime interval = CMTimeMakeWithSeconds(SJREFRESH_INTERVAL, NSEC_PER_SEC);
    __weak typeof(self) _self = self;
    _timeObserver =
    [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(self.playerItem.duration);
        if ( self.playTimeChanged ) self.playTimeChanged(self, currentTime, duration);
    }];
}

- (void)_addItemPlayEndObserver {
    __weak typeof(self) _self = self;
    _itemEndObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.playDidToEnd ) self.playDidToEnd(self);
    }];
}

- (void)_observing {
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    if ( _scrollView ) {
        [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self _injectTmpObjToScrollView];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( [keyPath isEqualToString:@"status"] ) {
            if ( self.playerItemStateChanged ) self.playerItemStateChanged(self, self.playerItem.status);
        }
        else if ( [keyPath isEqualToString:@"loadedTimeRanges"] ) {
            if ( 0 == CMTimeGetSeconds(_playerItem.duration) ) return;
            CGFloat progress = [self _loadedTimeSecs] / CMTimeGetSeconds(_playerItem.duration);
            if ( self.loadedTimeProgress ) self.loadedTimeProgress(progress);
        }
        else if ( [keyPath isEqualToString:@"playbackBufferEmpty"] ) {
            if ( self.beingBuffered ) self.beingBuffered([self _loadedTimeSecs] <= self.currentTime + 5);
        }
        if ( [keyPath isEqualToString:@"contentOffset"] ) {
            if ( self.scrollViewDidScroll ) self.scrollViewDidScroll(self);
        }
    });
}

- (NSInteger)_loadedTimeSecs {
    CMTimeRange loadTimeRange = [_playerItem.loadedTimeRanges.firstObject CMTimeRangeValue];
    CMTime startTime = loadTimeRange.start;
    CMTime rangeDuration  = loadTimeRange.duration;
    NSInteger seconds = CMTimeGetSeconds(startTime) + CMTimeGetSeconds(rangeDuration);
    return seconds;
}

#pragma mark -
- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize completion:(void (^)(SJVideoPlayerAssetCarrier * _Nonnull, NSArray<SJVideoPreviewModel *> * _Nullable, NSError * _Nullable))block {
    
    if ( !_asset ) return;
    if ( 0 == _asset.duration.timescale ) return;
    NSMutableArray<NSValue *> *timesM = [NSMutableArray new];
    NSInteger seconds = (long)_asset.duration.value / _asset.duration.timescale;
    if ( 0 == seconds || isnan(seconds) ) return;
    if ( SJPreImgGenerateInterval > 1.0 || SJPreImgGenerateInterval <= 0 ) return;
    __block short maxCount = (short)floorf(1.0 / SJPreImgGenerateInterval);
    short interval = (short)floor(seconds * SJPreImgGenerateInterval);
    for ( int i = 0 ; i < maxCount ; i ++ ) {
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
                if ( block ) block(self, imagesM, nil);
            });
        }
    }];
}

- (void)cancelPreviewImagesGeneration {
    [_imageGenerator cancelAllCGImageGeneration];
}

- (UIImage *)screenshot {
    if ( !_playerItem || !_asset ) return nil;
    CMTime time = _playerItem.currentTime;
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_asset];
    generator.appliesPreferredTrackTransform = YES;
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:&time error:nil];
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    return image;
}

- (NSTimeInterval)duration {
    return CMTimeGetSeconds(_playerItem.duration);
}

- (NSTimeInterval)currentTime {
    return CMTimeGetSeconds(_playerItem.currentTime);
}

- (float)progress {
    NSInteger duration = self.duration;
    if ( 0 == duration ) return 0;
    else return self.currentTime / duration;
}

- (void)dealloc {
    [_player removeTimeObserver:_timeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    if ( !_removedScrollObserver ) [self _removingScrollViewObserver];
    if ( _deallocCallBlock ) _deallocCallBlock(self);
}

#pragma mark
- (void)_injectTmpObjToScrollView {
    SJTmpObj *obj = [SJTmpObj new];
    __weak typeof(self) _self = self;
    obj.deallocCallBlock = ^(SJTmpObj *obj) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.removedScrollObserver ) {
            [self _removingScrollViewObserver];
        }
    };
    objc_setAssociatedObject(_scrollView, _cmd, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)_removingScrollViewObserver {
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    _scrollView = nil;
    _removedScrollObserver = YES;
}

@end
