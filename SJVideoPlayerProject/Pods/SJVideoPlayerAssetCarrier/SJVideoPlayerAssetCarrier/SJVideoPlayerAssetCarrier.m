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
static float const __TimeRefreshInterval = 0.5;

/*!
 *  0.0 - 1.0
 */
static float const __GeneratePreImgScale = 0.05;


@interface SJTmpObj : NSObject
@property (nonatomic, copy) void(^deallocCallBlock)(SJTmpObj *obj);
@end

@implementation SJTmpObj
- (void)dealloc {
    if ( _deallocCallBlock ) _deallocCallBlock(self);
}
@end

#pragma mark -

@interface SJVideoPlayerAssetCarrier () {
    id _timeObserver;
    id _itemEndObserver;
}

@property (nonatomic, strong, readwrite) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong, readwrite) AVAssetImageGenerator *tmp_imageGenerator;
@property (nonatomic, assign, readwrite) BOOL hasBeenGeneratedPreviewImages;
@property (nonatomic, strong, readwrite) NSArray<SJVideoPreviewModel *> *generatedPreviewImages;
@property (nonatomic, assign, readwrite) BOOL jumped;
@property (nonatomic, assign, readwrite) BOOL scrollIn_bool;
@property (nonatomic, assign, readwrite) BOOL removedScrollObserver;
@property (nonatomic, assign, readwrite) BOOL removedParentScrollObserver;

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
                      scrollView:(__unsafe_unretained UIScrollView * __nullable)scrollView
                       indexPath:(__weak NSIndexPath * __nullable)indexPath
                    superviewTag:(NSInteger)superviewTag {
    return [self initWithAssetURL:assetURL beginTime:0 scrollView:scrollView indexPath:indexPath superviewTag:superviewTag];
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
                      scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                       indexPath:(__weak NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag {
    return [self initWithAssetURL:assetURL beginTime:beginTime scrollView:scrollView indexPath:indexPath superviewTag:superviewTag scrollViewTag:0 parentScrollView:nil parentIndexPath:nil];
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
                      scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                       indexPath:(__weak NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag
                   scrollViewTag:(NSInteger)scrollViewTag
                parentScrollView:(__unsafe_unretained UIScrollView *__nullable)parentScrollView
                 parentIndexPath:(NSIndexPath *__nullable)parentIndexPath {
    self = [super init];
    if ( !self ) return nil;
    _asset = [AVURLAsset assetWithURL:assetURL];
    _playerItem = [AVPlayerItem playerItemWithAsset:_asset automaticallyLoadedAssetKeys:@[@"duration"]];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _assetURL = assetURL;
    _beginTime = beginTime;
    if ( 0 == _beginTime ) _jumped = YES;
    _scrollView = scrollView;
    _indexPath = indexPath;
    _superviewTag = superviewTag;
    _scrollViewTag = scrollViewTag;
    _parentScrollView = parentScrollView;
    _parentIndexPath = parentIndexPath;
    [self _addTimeObserver];
    [self _addItemPlayEndObserver];
    [self _observing];
    
    // default value 
    _scrollIn_bool = YES;
    return self;
}

- (void)_addTimeObserver {
    CMTime interval = CMTimeMakeWithSeconds(__TimeRefreshInterval, NSEC_PER_SEC);
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
    [_playerItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    
    if ( _scrollView ) {
        [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        __weak typeof(self) _self = self;
        [self _injectTmpObjToScrollView:_scrollView deallocCallBlock:^(SJTmpObj *obj) {
            obj.deallocCallBlock = ^(SJTmpObj *obj) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( !self.removedScrollObserver ) {
                    [self _removingScrollViewObserver];
                }
            };
        }];
    }
    
    if ( _parentScrollView ) {
        [_parentScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        __weak typeof(self) _self = self;
        [self _injectTmpObjToScrollView:_parentScrollView deallocCallBlock:^(SJTmpObj *obj) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( !self.removedParentScrollObserver ) {
                [self _removingParentScrollViewObserver];
            }
        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ( [keyPath isEqualToString:@"status"] ) {
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
        else if ( [keyPath isEqualToString:@"loadedTimeRanges"] ) {
            if ( 0 == CMTimeGetSeconds(_playerItem.duration) ) return;
            CGFloat progress = [self _loadedTimeSecs] / CMTimeGetSeconds(_playerItem.duration);
            if ( self.loadedTimeProgress ) self.loadedTimeProgress(progress);
        }
        else if ( [keyPath isEqualToString:@"playbackBufferEmpty"] ) {
            if ( self.beingBuffered ) self.beingBuffered([self _loadedTimeSecs] <= self.currentTime + 5);
        }
        else if ( [keyPath isEqualToString:@"presentationSize"] ) {
            if ( self.presentationSize ) self.presentationSize(self, self.playerItem.presentationSize);
        }
        if ( [keyPath isEqualToString:@"contentOffset"] ) {
            [self _scrollViewDidScroll:object];
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
        if ( result == AVAssetImageGeneratorSucceeded ) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            if ( block ) block(self, [SJVideoPreviewModel previewModelWithImage:image localTime:actualTime], nil);
        }
        else if ( result == AVAssetImageGeneratorFailed ) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( block ) block(self, nil, error);
        }
    }];
}

#pragma mark -
- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize completion:(void (^)(SJVideoPlayerAssetCarrier * _Nonnull, NSArray<SJVideoPreviewModel *> * _Nullable, NSError * _Nullable))block {
    
    if ( !_asset ) return;
    if ( 0 == _asset.duration.timescale ) return;
    NSMutableArray<NSValue *> *timesM = [NSMutableArray new];
    NSInteger seconds = (long)_asset.duration.value / _asset.duration.timescale;
    if ( 0 == seconds || isnan(seconds) ) return;
    if ( __GeneratePreImgScale > 1.0 || __GeneratePreImgScale <= 0 ) return;
    __block short maxCount = (short)floorf(1.0 / __GeneratePreImgScale);
    short interval = (short)floor(seconds * __GeneratePreImgScale);
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

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    if ( isnan(time) ) { return;}
    CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    [self seekToTime:seekTime completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    if ( 1 == CMTimeCompare(time, _playerItem.duration) ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    [_playerItem seekToTime:time completionHandler:^(BOOL finished) {
        if ( completionHandler ) completionHandler(finished);
    }];
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
    [_tmp_imageGenerator cancelAllCGImageGeneration];
    [self cancelPreviewImagesGeneration];
    [_player pause];
    [_player removeTimeObserver:_timeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"presentationSize"];
    if ( !_removedScrollObserver ) [self _removingScrollViewObserver];
    if ( !_removedParentScrollObserver ) [self _removingParentScrollViewObserver];
}

#pragma mark

- (void)_scrollViewDidScroll:(UIScrollView *)scrollView {
    // old method(v0.0.4 below)
    if ( scrollView == _scrollView ) {
        if ( _scrollViewDidScroll ) _scrollViewDidScroll(self);
    }
    
    
    // new method
    NSIndexPath *indexPath = nil;
    if ( scrollView == _scrollView ) {
        indexPath = _indexPath;
    }
    else {
        indexPath = _parentIndexPath;
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
        if ( scrollView == _parentScrollView ) [self _setNewScrollView];
        self.scrollIn_bool = visable;
    }
    else if ( [scrollView isKindOfClass:[UICollectionView class]] ) {
        UICollectionView *collectionView = (UICollectionView *)scrollView;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        bool visable = [collectionView.visibleCells containsObject:cell];;
        if ( scrollView == _parentScrollView ) [self _setNewScrollView];
        self.scrollIn_bool = visable;
    }
}

- (void)setScrollIn_bool:(BOOL)scrollIn_bool {
    if ( scrollIn_bool == _scrollIn_bool ) return;
    _scrollIn_bool = scrollIn_bool;
    if ( scrollIn_bool ) {
        if ( _scrollIn ) _scrollIn(self, [self _getVideoPlayerSuperView]);
    }
    else {
        if ( _scrollOut ) _scrollOut(self);
    }
}

- (void)_setNewScrollView {
    UIScrollView *newScrollView = nil;
    if ( [_parentScrollView isKindOfClass:[UITableView class]] ) {
        UITableView *parent = (UITableView *)_parentScrollView;
        UITableViewCell *parentCell = [parent cellForRowAtIndexPath:_parentIndexPath];
        newScrollView = [parentCell viewWithTag:_scrollViewTag];
    }
    else if ( [_parentScrollView isKindOfClass:[UICollectionView class]] ) {
        UICollectionView *parent = (UICollectionView *)_parentScrollView;
        UICollectionViewCell *parentCell = [parent cellForItemAtIndexPath:_parentIndexPath];
        newScrollView = [parentCell viewWithTag:_scrollViewTag];
    }
    
    if ( !newScrollView || newScrollView == _scrollView ) return;
    
    // remove observer
    [self _removingScrollViewObserver];
    
    // set new scrollview
    _scrollView = newScrollView;
    
    // add observer
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) _self = self;
    [self _injectTmpObjToScrollView:_scrollView deallocCallBlock:^(SJTmpObj *obj) {
        obj.deallocCallBlock = ^(SJTmpObj *obj) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( !self.removedScrollObserver ) {
                [self _removingScrollViewObserver];
            }
        };
    }];
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

- (void)_injectTmpObjToScrollView:(UIScrollView *)scrollView deallocCallBlock:(void(^)(SJTmpObj *obj))block {
    SJTmpObj *obj = [SJTmpObj new];
    obj.deallocCallBlock = block;
    objc_setAssociatedObject(scrollView, _cmd, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)_removingScrollViewObserver {
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    _scrollView = nil;
    _removedScrollObserver = YES;
}

- (void)_removingParentScrollViewObserver {
    [_parentScrollView removeObserver:self forKeyPath:@"contentOffset"];
    _parentScrollView = nil;
    _removedParentScrollObserver = YES;
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

