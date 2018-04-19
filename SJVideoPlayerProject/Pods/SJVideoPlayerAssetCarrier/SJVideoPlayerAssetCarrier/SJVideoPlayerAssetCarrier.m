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
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>


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

#pragma mark -
@interface SJPlayerSuperViewHelper : NSObject
- (BOOL)isShowWithCell:(UIView *)cell playerContainerView:(UIView *)playerContainerView scrollView:(UIScrollView *)scrollView;
@end
@implementation SJPlayerSuperViewHelper
- (BOOL)isShowWithCell:(UIView *)cell playerContainerView:(UIView *)playerContainerView scrollView:(UIScrollView *)scrollView {
    CGRect convertedRect = [playerContainerView.superview convertRect:playerContainerView.frame toView:scrollView.superview];
    CGRect intersectionRect = CGRectIntersection(convertedRect, scrollView.frame);
    return !CGRectIsNull(intersectionRect);
}
@end

#pragma mark - 已弃用
@interface SJAssetUIKitEctype: NSObject
@property (nonatomic, assign) SJViewHierarchyStack viewHierarchyStack;
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

@interface SJGIFCreator : NSObject
@property (nonatomic, strong, readonly) UIImage *firstImage;
- (instancetype)initWithSavePath:(NSURL *)savePath imagesCount:(int)count;
- (void)addImage:(CGImageRef)imageRef;
- (BOOL)finalize;
@end

#pragma mark -

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerAssetCarrier () {
    id _timeObserver;
    id _itemEndObserver;
    NSTimer *_bufferRefreshTimer;
    NSTimer *_refreshProgressTimer;
    SJPlayerSuperViewHelper *_superViewHelper;
}
@property (nonatomic, assign, readwrite) SJViewHierarchyStack viewHierarchyStack;
@property (nonatomic, strong, readwrite, nullable) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong, readwrite, nullable) AVAssetImageGenerator *tmp_imageGenerator;
@property (nonatomic, strong, readwrite, nullable) AVAssetImageGenerator *gif_imageGenerator;

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
@property (nonatomic, strong, nullable) SJGIFCreator *gifCreator;
@property (nonatomic, weak, readonly, nullable) id <SJVideoPlayerAVAsset> otherAsset;
@property (nonatomic, strong, readonly) SJPlayerSuperViewHelper *superViewHelper;
@property (nonatomic, readwrite) CGPoint beforeContentOffset;
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
    return [self initWithAssetURL:assetURL beginTime:0 indexPath:indexPath superviewTag:superviewTag scrollViewIndexPath:nil scrollViewTag:0 scrollView:scrollView rootScrollView:nil];
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
    _viewHierarchyStack = SJViewHierarchyStack_TableHeaderView;
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
    _viewHierarchyStack = SJViewHierarchyStack_NestedInTableHeaderView;
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
    
    // views
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
    
    // av asset
    _assetURL = assetURL;
    _beginTime = beginTime; if ( 0 == _beginTime ) _jumped = YES;
    if ( _assetURL.absoluteString.length != 0 ) {
        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _initializeAVPlayer];
            [self _itemObserving];
        });
    }
    
    [self _scrollViewObserving];
    
    // view stack
    if ( _rootScrollView && _scrollView ) _viewHierarchyStack = SJViewHierarchyStack_NestedInTableView;
    else if ( _scrollView ) _viewHierarchyStack = SJViewHierarchyStack_ScrollView;
    else _viewHierarchyStack = SJViewHierarchyStack_View;
    return self;
}
- (instancetype)initWithOtherAsset:(__weak id<SJVideoPlayerAVAsset>)asset {
    return [self initWithOtherAsset:asset scrollView:nil indexPath:nil superviewTag:0];
}
- (instancetype)initWithOtherAsset:(__weak id<SJVideoPlayerAVAsset>)asset
                        scrollView:(__unsafe_unretained UIScrollView * __nullable)tableOrCollectionView
                         indexPath:(NSIndexPath * __nullable)indexPath
                      superviewTag:(NSInteger)superviewTag {
    return [self initWithOtherAsset:asset indexPath:indexPath superviewTag:superviewTag scrollViewIndexPath:nil scrollViewTag:0 scrollView:tableOrCollectionView rootScrollView:nil];
}
- (instancetype)initWithOtherAsset:(__weak id<SJVideoPlayerAVAsset>)asset
      playerSuperViewOfTableHeader:(__unsafe_unretained UIView *)superView
                         tableView:(__unsafe_unretained UITableView *)tableView {
    self = [self initWithOtherAsset:asset
                         scrollView:tableView
                          indexPath:nil
                       superviewTag:0];
    if ( !self ) return nil;
    _tableHeaderSubView = superView;
    _viewHierarchyStack = SJViewHierarchyStack_TableHeaderView;
    return self;
}
- (instancetype)initWithOtherAsset:(__weak id<SJVideoPlayerAVAsset>)asset
       collectionViewOfTableHeader:(__unsafe_unretained UICollectionView *)collectionView
           collectionCellIndexPath:(NSIndexPath *)indexPath
                playerSuperViewTag:(NSInteger)playerSuperViewTag
                     rootTableView:(__unsafe_unretained UITableView *)rootTableView {
    self = [self initWithOtherAsset:asset
                          indexPath:indexPath
                       superviewTag:playerSuperViewTag
                scrollViewIndexPath:nil
                      scrollViewTag:0
                         scrollView:collectionView
                     rootScrollView:rootTableView];
    if ( !self ) return nil;
    _tableHeaderSubView = collectionView;
    _viewHierarchyStack = SJViewHierarchyStack_NestedInTableHeaderView;
    return self;
    
}
- (instancetype)initWithOtherAsset:(__weak id<SJVideoPlayerAVAsset>)asset
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
    return [self initWithOtherAsset:asset indexPath:indexPath superviewTag:superviewTag scrollViewIndexPath:scrollViewIndexPath scrollViewTag:scrollViewTag scrollView:scrollView rootScrollView:rootScrollView];
}
- (instancetype)initWithOtherAsset:(__weak id<SJVideoPlayerAVAsset>)asset
                         indexPath:(NSIndexPath *__nullable)indexPath
                      superviewTag:(NSInteger)superviewTag
               scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                     scrollViewTag:(NSInteger)scrollViewTag
                        scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                    rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView {
    self = [self initWithAssetURL:[NSURL new] beginTime:0 indexPath:indexPath superviewTag:superviewTag scrollViewIndexPath:scrollViewIndexPath scrollViewTag:scrollViewTag scrollView:scrollView rootScrollView:rootScrollView];
    if ( !self ) return nil;
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _settingAVPlayerWithAsset:asset];
    });
    return self;
}

- (void)_settingAVPlayerWithAsset:(__weak id<SJVideoPlayerAVAsset>)asset {
    _isOtherAsset = asset != nil;
    _otherAsset = asset;
    _asset = asset.asset;
    _playerItem = asset.playerItem;
    _player = asset.player;
    _rate = asset.rate;
    _loadedPlayer = YES;
    if ( self.loadedPlayerExeBlock ) self.loadedPlayerExeBlock(self);
    [self _itemObserving];
    [self _updateDuration];
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
        self->_loadedPlayer = YES;
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
    if ( !_otherAsset && 0 != _player.rate ) [_player pause];
    
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"presentationSize"];
    [_playerItem removeObserver:self forKeyPath:@"duration"];
    [_tmp_imageGenerator cancelAllCGImageGeneration];
    [self cancelExportOperation];
    [self cancelGenerateGIFOperation];
    [self cancelExportOperation];
    [self cancelPreviewImagesGeneration];
    [_player removeTimeObserver:_timeObserver]; _timeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem]; _itemEndObserver = nil;
    _beginBuffer = NO;
    [self _cleanBufferTimer];
    [_exportSession cancelExport];
    _exportSession = nil;
    _loadedPlayer = NO;
    _isOtherAsset = NO;
    _otherAsset = nil;
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
                    if ( self->_touchedScrollView ) self->_touchedScrollView(self, YES);
                }
                    break;
                case UIGestureRecognizerStateEnded:
                case UIGestureRecognizerStateFailed:
                case UIGestureRecognizerStateCancelled: {
                    if ( self->_touchedScrollView ) self->_touchedScrollView(self, NO);
                }
                    break;
            }
        }
        else if ( [keyPath isEqualToString:@"loadedTimeRanges"] ) {
            if ( 0 == self.duration ) return;
            float progress = [self _loadedTimeSecs] / self.duration;
            self->_loadedTimeProgressValue = progress;
            if ( self.loadedTimeProgress ) self.loadedTimeProgress(progress);
        }
        else if ( [keyPath isEqualToString:@"status"] ) {
            if ( !self->_jumped &&
                AVPlayerItemStatusReadyToPlay == self.playerItem.status &&
                0 != self.beginTime ) {
                // begin time
                if ( self.beginTime > self.duration ) return ;
                __weak typeof(self) _self = self;
                [self jumpedToTime:self->_beginTime completionHandler:^(BOOL finished) {
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
            [self _updateDuration];
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
    return [self screenshotWithTime:_playerItem.currentTime];
}

- (UIImage * __nullable)screenshotWithTime:(CMTime)time {
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
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
    _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    [_imageGenerator generateCGImagesAsynchronouslyForTimes:timesM completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        switch ( result ) {
            case AVAssetImageGeneratorSucceeded: {
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                SJVideoPreviewModel *model = [SJVideoPreviewModel previewModelWithImage:image localTime:actualTime];
                [imagesM addObject:model];
                if ( --maxCount != 0 ) return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    self.hasBeenGeneratedPreviewImages = YES;
                    self.generatedPreviewImages = imagesM;
                    self.maxItemSize = itemSize;
                    if ( block ) block(self, imagesM, nil);
                });
            }
                break;
            case AVAssetImageGeneratorFailed: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    [self.imageGenerator cancelAllCGImageGeneration];
                    if ( block ) block(self, nil, error);
                });
            }
                break;
            case AVAssetImageGeneratorCancelled: break;
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

- (void)cancelExportOperation {
    [_exportSession cancelExport];
}

#pragma mark - gif
- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(SJVideoPlayerAssetCarrier *asset, float progress))progressBlock
                      completion:(void(^)(SJVideoPlayerAssetCarrier *asset, UIImage *imageGIF, UIImage *thumbnailImage))completion
                         failure:(void(^)(SJVideoPlayerAssetCarrier *asset, NSError *error))failure {
    if ( interval == 0 ) interval = 0.2f;
    __block int count = (int)ceil(duration / interval);
    NSMutableArray<NSValue *> *timesM = [NSMutableArray new];
    for ( int i = 0 ; i < count ; ++ i ) {
        [timesM addObject:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(beginTime + i * interval, NSEC_PER_SEC)]];
    }
    
    _gif_imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_asset];
    _gif_imageGenerator.appliesPreferredTrackTransform = YES;
    _gif_imageGenerator.maximumSize = maximumSize;
    _gif_imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    _gif_imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    
    self.gifCreator = [[SJGIFCreator alloc] initWithSavePath:gifSavePath imagesCount:count];
    int all = count;
    __weak typeof(self) _self = self;
    [_gif_imageGenerator generateCGImagesAsynchronouslyForTimes:timesM completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch ( result ) {
            case AVAssetImageGeneratorSucceeded: {
                [self.gifCreator addImage:imageRef];
                if ( progressBlock ) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressBlock(self, 1 - count * 1.0f / all);
                    });
                }
                if ( --count != 0 ) return;
                BOOL result = [self.gifCreator finalize];
                UIImage *image = getImage([NSData dataWithContentsOfURL:gifSavePath], [UIScreen mainScreen].scale);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ( !result ) {
                        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                             code:-1
                                                         userInfo:@{@"msg":@"Generate Gif Failed!"}];
                        if ( failure ) failure(self, error);
                    }
                    else {
                        if ( progressBlock ) progressBlock(self, 1);
                        if ( completion ) completion(self, image, self.gifCreator.firstImage);
                        self.gifCreator = nil;
                    }
                });
            }
                break;
            case AVAssetImageGeneratorFailed: {
                [self.gif_imageGenerator cancelAllCGImageGeneration];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ( failure ) failure(self, error);
                    self.gifCreator = nil;
                });
            }
                break;
            case AVAssetImageGeneratorCancelled: {
                self.gifCreator = nil;
            }
                break;
        }
    }];
}

- (void)cancelGenerateGIFOperation {
    [_gif_imageGenerator cancelAllCGImageGeneration];
}

- (void)_cleanRefreshProgressTimer {
    [_refreshProgressTimer invalidate];
    _refreshProgressTimer = nil;
}

#pragma mark -
- (void)_updateDuration {
    self->_duration = CMTimeGetSeconds(self->_playerItem.duration);
}
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
    if ( CGPointEqualToPoint(_beforeContentOffset, scrollView.contentOffset) ) return;
    if ( scrollView == _scrollView ) {
        if ( _scrollViewDidScroll ) _scrollViewDidScroll(self);
    }
    
    if ( self.tableHeaderSubView ) {
        [self playOnHeader_scrollViewDidScroll:scrollView];
    }
    else {
        [self playOnCell_scrollViewDidScroll:scrollView];
    }
    _beforeContentOffset = scrollView.contentOffset;
}

- (void)playOnHeader_scrollViewDidScroll:(UIScrollView *)scrollView {
    if ( [self.tableHeaderSubView isKindOfClass:[UICollectionView class]] &&
        scrollView == self.tableHeaderSubView ) {
        [self playOnCell_scrollViewDidScroll:scrollView];
    }
    else {
        CGFloat offsetY = scrollView.contentOffset.y;
        if ( offsetY < self.tableHeaderSubView.frame.size.height ) {
            if ( [self.scrollView isKindOfClass:[UITableView class]] ) {
                self.scrollIn_bool = YES;
            }
            else {
                [self playOnCell_scrollViewDidScroll:self.scrollView];
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
    
    __block BOOL visable = NO;
    if ( [scrollView isKindOfClass:[UITableView class]] ) {
        UITableView *tableView = (UITableView *)scrollView;
        [tableView.indexPathsForVisibleRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( [obj compare:indexPath] == NSOrderedSame ) {
                *stop = YES;
                visable = [self.superViewHelper isShowWithCell:[self _getCell] playerContainerView:[self _getContainerView] scrollView:scrollView];
            }
        }];
    }
    else if ( [scrollView isKindOfClass:[UICollectionView class]] ) {
        UICollectionView *collectionView = (UICollectionView *)scrollView;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if ( [collectionView.visibleCells containsObject:cell] ) {
            visable = [self.superViewHelper isShowWithCell:[self _getCell] playerContainerView:[self _getContainerView] scrollView:scrollView];
        }
    }
    if ( scrollView == _rootScrollView ) {
        if ( visable == self.parent_scrollIn_bool ) return;
        self.parent_scrollIn_bool = visable;
        if ( visable ) [self _updateScrollView];
    }
    self.scrollIn_bool = self.parent_scrollIn_bool && visable;
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

- (SJPlayerSuperViewHelper *)superViewHelper {
    if ( _superViewHelper ) return _superViewHelper;
    _superViewHelper = [SJPlayerSuperViewHelper new];
    return _superViewHelper;
}

- (UIView *)_getCell {
    UIView *cell = nil;
    if ( [_scrollView isKindOfClass:[UITableView class]] ) {
        cell = [(UITableView *)_scrollView cellForRowAtIndexPath:_indexPath];
        
    }
    else if ( [_scrollView isKindOfClass:[UICollectionView class]] ) {
        cell = [(UICollectionView *)_scrollView cellForItemAtIndexPath:_indexPath];
    }
    return cell;
}

- (UIView *)_getContainerView {
    UIView *cell = [self _getCell];
    return [cell viewWithTag:_superviewTag];
}

- (void)_observeScrollView:(UIScrollView *)scrollView {
    [scrollView sj_addObserver:self forKeyPath:@"contentOffset"];
    [scrollView.panGestureRecognizer sj_addObserver:self forKeyPath:@"state"];
}

- (NSString *)timeString:(NSInteger)secs {
    long min = 60;
    long hour = 60 * min;
    
    long hours, seconds, minutes;
    hours = secs / hour;
    minutes = (secs - hours * hour) / 60;
    seconds = secs % 60;
    if ( self.duration < hour ) {
        return [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
    }
    else {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
    }
}

- (void)refreshAVPlayer {
    @synchronized(self) {
        [self _clearAVPlayer];
        [self _initializeAVPlayer];
        [self _itemObserving];
    }
}

- (void)pause {
    if ( 0 != self.player.rate ) [self.player pause];
}
- (void)play {
    if ( 0 == self.player.rate ) [self.player play];
}

- (void)convertToOriginal {
    if ( !_converted ) return;
    [self _convertingWithBlock:^{
        self->_viewHierarchyStack = self->_ectype.viewHierarchyStack;
        self->_indexPath = self->_ectype.indexPath;
        self->_superviewTag = self->_ectype.superviewTag;
        self->_scrollView = self->_ectype.scrollView;
        self->_scrollViewTag = self->_ectype.scrollViewTag;
        self->_scrollViewIndexPath = self->_ectype.scrollViewIndexPath;
        self->_rootScrollView = self->_ectype.rootScrollView;
        self->_tableHeaderSubView = self->_ectype.tableHeaderSubView;
        self->_scrollIn_bool = self->_ectype.scrollIn_bool;
        self->_parent_scrollIn_bool = self->_ectype.parent_scrollIn_bool;
        
        self->_playerItemStateChanged = self->_ectype.playerItemStateChanged;
        self->_playTimeChanged = self->_ectype.playTimeChanged;
        self->_playDidToEnd = self->_ectype.playDidToEnd;
        self->_loadedTimeProgress = self->_ectype.loadedTimeProgress;
        self->_startBuffering = self->_ectype.startBuffering;
        self->_completeBuffer = self->_ectype.completeBuffer;
        self->_cancelledBuffer = self->_ectype.cancelledBuffer;
        self->_touchedScrollView = self->_ectype.touchedScrollView;
        self->_scrollViewDidScroll = self->_ectype.scrollViewDidScroll;
        self->_presentationSize = self->_ectype.presentationSize;
        self->_scrollIn = self->_ectype.scrollIn;
        self->_scrollOut = self->_ectype.scrollOut;
        self->_rateChanged = self->_ectype.rateChanged;
    }];
    _converted = NO;
    if ( _convertToOriginalExeBlock ) _convertToOriginalExeBlock(self);
}

- (void)_clearUIKit {
    if ( !_ectype ) {
        self->_ectype = [SJAssetUIKitEctype new];
        self->_ectype.viewHierarchyStack = _viewHierarchyStack;
        self->_ectype.indexPath = _indexPath;
        self->_ectype.superviewTag = _superviewTag;
        self->_ectype.scrollView = _scrollView;
        self->_ectype.scrollViewTag = _scrollViewTag;
        self->_ectype.scrollViewIndexPath = _scrollViewIndexPath;
        self->_ectype.rootScrollView = _rootScrollView;
        self->_ectype.tableHeaderSubView = _tableHeaderSubView;
        self->_ectype.scrollIn_bool = _scrollIn_bool;
        self->_ectype.parent_scrollIn_bool = _parent_scrollIn_bool;
        
        self->_ectype.playerItemStateChanged = _playerItemStateChanged;
        self->_ectype.playTimeChanged = _playTimeChanged;
        self->_ectype.playDidToEnd = _playDidToEnd;
        self->_ectype.loadedTimeProgress = _loadedTimeProgress;
        self->_ectype.startBuffering = _startBuffering;
        self->_ectype.completeBuffer = _completeBuffer;
        self->_ectype.cancelledBuffer = _cancelledBuffer;
        self->_ectype.touchedScrollView = _touchedScrollView;
        self->_ectype.scrollViewDidScroll = _scrollViewDidScroll;
        self->_ectype.presentationSize = _presentationSize;
        self->_ectype.scrollIn = _scrollIn;
        self->_ectype.scrollOut = _scrollOut;
        self->_ectype.rateChanged = _rateChanged;
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
    [self _convertingWithBlock:^{
        self->_viewHierarchyStack = SJViewHierarchyStack_View;
    }];
}

- (void)convertToCellWithTableOrCollectionView:(__unsafe_unretained UIScrollView *)tableOrCollectionView
                                     indexPath:(NSIndexPath *)indexPath
                            playerSuperviewTag:(NSInteger)superviewTag {
    [self _convertingWithBlock:^{
        self->_indexPath = indexPath;
        self->_superviewTag = superviewTag;
        self->_scrollView = tableOrCollectionView;
        self->_viewHierarchyStack = SJViewHierarchyStack_ScrollView;
    }];
}

- (void)convertToTableHeaderViewWithPlayerSuperView:(__weak UIView *)superView
                                          tableView:(__unsafe_unretained UITableView *)tableView {
    [self _convertingWithBlock:^{
        self->_tableHeaderSubView = superView;
        self->_scrollView = tableView;
        self->_viewHierarchyStack = SJViewHierarchyStack_TableHeaderView;
    }];
}

- (void)convertToTableHeaderViewWithCollectionView:(__weak UICollectionView *)collectionView
                           collectionCellIndexPath:(NSIndexPath *)indexPath
                                playerSuperViewTag:(NSInteger)playerSuperViewTag
                                     rootTableView:(__unsafe_unretained UITableView *)rootTableView {
    [self _convertingWithBlock:^{
        self->_scrollView = collectionView;
        self->_indexPath = indexPath;
        self->_superviewTag = playerSuperViewTag;
        self->_rootScrollView = rootTableView;
        self->_viewHierarchyStack = SJViewHierarchyStack_NestedInTableHeaderView;
    }];
}

- (void)convertToCellWithIndexPath:(NSIndexPath *)indexPath
                      superviewTag:(NSInteger)superviewTag
           collectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath
                 collectionViewTag:(NSInteger)collectionViewTag
                     rootTableView:(__unsafe_unretained UITableView *)rootTableView {
    [self _convertingWithBlock:^{
        self->_indexPath = indexPath;
        self->_superviewTag = superviewTag;
        self->_scrollView = [[rootTableView cellForRowAtIndexPath:collectionViewIndexPath] viewWithTag:collectionViewTag];
        self->_scrollViewTag = collectionViewTag;
        self->_rootScrollView = rootTableView;
        self->_viewHierarchyStack = SJViewHierarchyStack_NestedInTableView;
    }];
}

- (void)_convertingWithBlock:(void(^)(void))block {
    [self _clearUIKit];
    if ( block ) block();
    [self _scrollViewObserving];
    _converted = YES;
}


#pragma mark -
/**
 ref: YYKit
 UIImage(YYAdd)
 */
static UIImage *getImage(NSData *data, CGFloat scale) {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFTypeRef)(data), NULL);
    if (!source) return nil;
    
    size_t count = CGImageSourceGetCount(source);
    if (count <= 1) {
        CFRelease(source);
        return [UIImage imageWithData:data scale:scale];
    }
    
    NSUInteger frames[count];
    double oneFrameTime = 1 / 50.0; // 50 fps
    NSTimeInterval totalTime = 0;
    NSUInteger totalFrame = 0;
    NSUInteger gcdFrame = 0;
    for (size_t i = 0; i < count; i++) {
        NSTimeInterval delay = _yy_CGImageSourceGetGIFFrameDelayAtIndex(source, i);
        totalTime += delay;
        NSInteger frame = lrint(delay / oneFrameTime);
        if (frame < 1) frame = 1;
        frames[i] = frame;
        totalFrame += frames[i];
        if (i == 0) gcdFrame = frames[i];
        else {
            NSUInteger frame = frames[i], tmp;
            if (frame < gcdFrame) {
                tmp = frame; frame = gcdFrame; gcdFrame = tmp;
            }
            while (true) {
                tmp = frame % gcdFrame;
                if (tmp == 0) break;
                frame = gcdFrame;
                gcdFrame = tmp;
            }
        }
    }
    NSMutableArray *array = [NSMutableArray new];
    for (size_t i = 0; i < count; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (!imageRef) {
            CFRelease(source);
            return nil;
        }
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        if (width == 0 || height == 0) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        // BGRA8888 (premultiplied) or BGRX8888
        // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, space, bitmapInfo);
        CGColorSpaceRelease(space);
        if (!context) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
        CGImageRef decoded = CGBitmapContextCreateImage(context);
        CFRelease(context);
        if (!decoded) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        UIImage *image = [UIImage imageWithCGImage:decoded scale:scale orientation:UIImageOrientationUp];
        CGImageRelease(imageRef);
        CGImageRelease(decoded);
        if (!image) {
            CFRelease(source);
            return nil;
        }
        for (size_t j = 0, max = frames[i] / gcdFrame; j < max; j++) {
            [array addObject:image];
        }
    }
    CFRelease(source);
    UIImage *image = [UIImage animatedImageWithImages:array duration:totalTime];
    return image;
}

/**
 ref: YYKit
 UIImage(YYAdd)
 */
static NSTimeInterval _yy_CGImageSourceGetGIFFrameDelayAtIndex(CGImageSourceRef source, size_t index) {
    NSTimeInterval delay = 0;
    CFDictionaryRef dic = CGImageSourceCopyPropertiesAtIndex(source, index, NULL);
    if (dic) {
        CFDictionaryRef dicGIF = CFDictionaryGetValue(dic, kCGImagePropertyGIFDictionary);
        if (dicGIF) {
            NSNumber *num = CFDictionaryGetValue(dicGIF, kCGImagePropertyGIFUnclampedDelayTime);
            if (num.doubleValue <= __FLT_EPSILON__) {
                num = CFDictionaryGetValue(dicGIF, kCGImagePropertyGIFDelayTime);
            }
            delay = num.doubleValue;
        }
        CFRelease(dic);
    }
    
    // http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility
    if (delay < 0.02) delay = 0.1;
    return delay;
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


#pragma mark -
@interface SJGIFCreator ()
@property (nonatomic) CGImageDestinationRef destination;
@property (nonatomic, strong, readonly) NSDictionary *frameProperties;
@end
@implementation SJGIFCreator
- (instancetype)initWithSavePath:(NSURL *)savePath imagesCount:(int)count {
    self = [super init];
    if ( !self ) return nil;
    [[NSFileManager defaultManager] removeItemAtURL:savePath error:nil];
    _destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)savePath, kUTTypeGIF, count, NULL);
    NSDictionary *fileProperties = @{ (__bridge id)kCGImagePropertyGIFDictionary: @{(__bridge id)kCGImagePropertyGIFLoopCount: @(0)} };
    CGImageDestinationSetProperties(_destination, (__bridge CFDictionaryRef)fileProperties);
    _frameProperties = @{ (__bridge id)kCGImagePropertyGIFDictionary: @{(__bridge id)kCGImagePropertyGIFDelayTime: @(0.25f)} };
    return self;
}
- (void)addImage:(CGImageRef)imageRef {
    if ( !_firstImage ) _firstImage = [UIImage imageWithCGImage:imageRef];
    CGImageDestinationAddImage(_destination, imageRef, (__bridge CFDictionaryRef)_frameProperties);
    //    @autoreleasepool {
    //    }
}
- (BOOL)finalize {
    BOOL result = CGImageDestinationFinalize(_destination);
    CFRelease(_destination);
    _destination = NULL;
    return result;
}

- (void)dealloc {
    if ( _destination != NULL ) CFRelease(_destination);
}
@end
