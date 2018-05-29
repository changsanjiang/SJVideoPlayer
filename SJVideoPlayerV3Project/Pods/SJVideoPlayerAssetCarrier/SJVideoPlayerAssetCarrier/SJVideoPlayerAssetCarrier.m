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
#import "NSTimer+SJAssetAdd.h"

#import "SJPlayerScrollViewCarrier.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerAssetCarrier ()<SJPlayerAVCarrierDelegate, SJPlayerScrollViewCarrierDelegate>
@property (nonatomic, strong, nullable) SJPlayerScrollViewCarrier *scrollViewCarrier;
@property (nonatomic, strong, nullable) SJPlayerAVCarrier *AVCarrier;
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
    self = [super init];
    if ( !self ) return nil;
    _AVCarrier = [[SJPlayerAVCarrier alloc] initWithURL:assetURL beginTime:beginTime];
    _AVCarrier.delegate = self;
    return self;
}

#pragma mark - Cell

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                      scrollView:(__unsafe_unretained UIScrollView * __nullable)scrollView
                       indexPath:(NSIndexPath * __nullable)indexPath
                    superviewTag:(NSInteger)superviewTag {
    return [self initWithAssetURL:assetURL
                        beginTime:0
                       scrollView:scrollView
                        indexPath:indexPath
                     superviewTag:superviewTag];
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
                      scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag {
    return [self initWithAssetURL:assetURL
                        beginTime:beginTime
                        indexPath:indexPath
                     superviewTag:superviewTag
              scrollViewIndexPath:nil
                    scrollViewTag:0
                       scrollView:scrollView
                   rootScrollView:nil];
}

#pragma mark - Table Header View.

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
    playerSuperViewOfTableHeader:(__weak UIView *)superView
                       tableView:(UITableView *)tableView {
    self = [self initWithAssetURL:assetURL beginTime:beginTime];
    if ( !self ) return nil;
    _scrollViewCarrier = [[SJPlayerScrollViewCarrier alloc] initWithPlayerSuperViewOfTableHeader:superView
                                                                                       tableView:tableView];
    _scrollViewCarrier.delegate = self;
    return self;
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
     collectionViewOfTableHeader:(__weak UICollectionView *)collectionView
         collectionCellIndexPath:(NSIndexPath *)indexPath
              playerSuperViewTag:(NSInteger)playerSuperViewTag
                   rootTableView:(UITableView *)rootTableView {
    self = [self initWithAssetURL:assetURL beginTime:beginTime];
    if ( !self ) return nil;
    _scrollViewCarrier = [[SJPlayerScrollViewCarrier alloc] initWithPlayerSuperViewTag:playerSuperViewTag
                                                                             indexPath:indexPath
                                                           collectionViewOfTableHeader:collectionView
                                                                         rootTableView:rootTableView];
    _scrollViewCarrier.delegate = self;
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
    return [self initWithAssetURL:assetURL
                        beginTime:beginTime
                        indexPath:indexPath
                     superviewTag:superviewTag
              scrollViewIndexPath:scrollViewIndexPath
                    scrollViewTag:scrollViewTag
                       scrollView:scrollView
                   rootScrollView:rootScrollView];
    
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL
                       beginTime:(NSTimeInterval)beginTime
                       indexPath:(NSIndexPath *__nullable)indexPath
                    superviewTag:(NSInteger)superviewTag
             scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                   scrollViewTag:(NSInteger)scrollViewTag
                      scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                  rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView {
    self = [self initWithAssetURL:assetURL beginTime:beginTime];
    if ( !self ) return nil;
    _scrollViewCarrier = [[SJPlayerScrollViewCarrier alloc] initWithPlayerSuperViewTag:superviewTag
                                                                             indexPath:indexPath
                                                                            scrollView:scrollView
                                                                         scrollViewTag:scrollViewTag
                                                                   scrollViewIndexPath:scrollViewIndexPath
                                                                        rootScrollView:rootScrollView];
    _scrollViewCarrier.delegate = self;
    return self;
}
- (instancetype)initWithOtherAsset:(__weak SJVideoPlayerAssetCarrier *)asset {
    self = [super init];
    if ( !self ) return nil;
    _AVCarrier = [[SJPlayerAVCarrier alloc] initWithOtherCarrier:asset.AVCarrier];
    _AVCarrier.delegate = self;
    return self;
}
- (instancetype)initWithOtherAsset:(__weak SJVideoPlayerAssetCarrier *)asset
                        scrollView:(__unsafe_unretained UIScrollView * __nullable)tableOrCollectionView
                         indexPath:(NSIndexPath * __nullable)indexPath
                      superviewTag:(NSInteger)superviewTag {
    return [self initWithOtherAsset:asset
                          indexPath:indexPath
                       superviewTag:superviewTag
                scrollViewIndexPath:nil
                      scrollViewTag:0
                         scrollView:tableOrCollectionView
                     rootScrollView:nil];
}
- (instancetype)initWithOtherAsset:(__weak SJVideoPlayerAssetCarrier *)asset
      playerSuperViewOfTableHeader:(__unsafe_unretained UIView *)superView
                         tableView:(__unsafe_unretained UITableView *)tableView {
    self = [self initWithOtherAsset:asset];
    if ( !self ) return nil;
    _scrollViewCarrier = [[SJPlayerScrollViewCarrier alloc] initWithPlayerSuperViewOfTableHeader:superView
                                                                                       tableView:tableView];
    _scrollViewCarrier.delegate = self;
    return self;
}
- (instancetype)initWithOtherAsset:(__weak SJVideoPlayerAssetCarrier *)asset
       collectionViewOfTableHeader:(__unsafe_unretained UICollectionView *)collectionView
           collectionCellIndexPath:(NSIndexPath *)indexPath
                playerSuperViewTag:(NSInteger)playerSuperViewTag
                     rootTableView:(__unsafe_unretained UITableView *)rootTableView {
    self = [self initWithOtherAsset:asset];
    if ( !self ) return nil;
    _scrollViewCarrier = [[SJPlayerScrollViewCarrier alloc] initWithPlayerSuperViewTag:playerSuperViewTag
                                                                             indexPath:indexPath
                                                           collectionViewOfTableHeader:collectionView
                                                                         rootTableView:rootTableView];
    _scrollViewCarrier.delegate = self;
    return self;
    
}
- (instancetype)initWithOtherAsset:(__weak SJVideoPlayerAssetCarrier *)asset
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
    return [self initWithOtherAsset:asset
                          indexPath:indexPath
                       superviewTag:superviewTag
                scrollViewIndexPath:scrollViewIndexPath
                      scrollViewTag:scrollViewTag
                         scrollView:scrollView
                     rootScrollView:rootScrollView];
}
- (instancetype)initWithOtherAsset:(__weak SJVideoPlayerAssetCarrier *)asset
                         indexPath:(NSIndexPath *__nullable)indexPath
                      superviewTag:(NSInteger)superviewTag
               scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                     scrollViewTag:(NSInteger)scrollViewTag
                        scrollView:(__unsafe_unretained UIScrollView *__nullable)scrollView
                    rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView {
    self = [self initWithOtherAsset:asset];
    if ( !self ) return nil;
    _scrollViewCarrier = [[SJPlayerScrollViewCarrier alloc] initWithPlayerSuperViewTag:superviewTag
                                                                             indexPath:indexPath
                                                                            scrollView:scrollView
                                                                         scrollViewTag:superviewTag
                                                                   scrollViewIndexPath:scrollViewIndexPath
                                                                        rootScrollView:rootScrollView];
    _scrollViewCarrier.delegate = self;
    return self;
}

#pragma mark -
- (void)dealloc {
    if ( _deallocExeBlock ) _deallocExeBlock(self);
}

#pragma mark - 1.1.5后 将UI和AV层从该类中分开抽离
/// 播放器初始化完成的时候调用
- (void)playerInitializedForAVCarrier:(SJPlayerAVCarrier *)carrier {
    if ( self.loadedPlayerExeBlock ) self.loadedPlayerExeBlock(self);
}
/// 资源的缓冲进度
- (void)AVCarrier:(SJPlayerAVCarrier *)carrier loadedTimeProgress:(float)progress {
    if ( self.loadedTimeProgress ) self.loadedTimeProgress(progress);
}
/// item的状态改变的时候调用
- (void)AVCarrier:(SJPlayerAVCarrier *)carrier playerItemStatusChanged:(AVPlayerItemStatus)status {
    if ( self.playerItemStateChanged ) self.playerItemStateChanged(self, status);
}
/// 开始缓冲的时候调用
- (void)startBufferForAVCarrier:(SJPlayerAVCarrier *)carrier {
    if ( self.startBuffering ) self.startBuffering(self);
}
/// 完成缓冲的时候调用
- (void)completeBufferForAVCarrier:(SJPlayerAVCarrier *)carrier {
    if ( self.completeBuffer ) self.completeBuffer(self);
}
/// 视频呈现的size
- (void)AVCarrier:(SJPlayerAVCarrier *)carrier presentationSize:(CGSize)size {
    if ( self.presentationSize ) self.presentationSize(self, size);
}
/// rate 改变的时候调用
- (void)AVCarrier:(SJPlayerAVCarrier *)carrier rateChanged:(float)rate {
    if ( self.rateChanged ) self.rateChanged(self, rate);
}
/// 播放时间
- (void)AVCarrier:(SJPlayerAVCarrier *)carrier currentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    if ( self.playTimeChanged ) self.playTimeChanged(self, currentTime, duration);
}
/// 播放结束的时候调用
- (void)playDidToEndForAVCarrier:(SJPlayerAVCarrier *)carrier {
    if ( self.playDidToEnd ) self.playDidToEnd(self);
}

#pragma mark - 1.1.5后 将UI和AV层从该类中分开抽离
/// touched`scrollView`时调用
- (void)scrollViewCarrier:(SJPlayerScrollViewCarrier *)carrier touchedScrollView:(BOOL)touched {
    if ( self.touchedScrollView ) self.touchedScrollView(self, touched);
}
/// 播放器视图即将出现的时候调用
- (void)playerWillAppearForScrollViewCarrier:(SJPlayerScrollViewCarrier *)carrier superview:(UIView *)superview {
    if ( self.scrollIn ) self.scrollIn(self, superview);
}
/// 播放器视图即将消失的时候调用
- (void)playerWillDisappearForScrollViewCarrier:(SJPlayerScrollViewCarrier *)carrier {
    if ( self.scrollOut ) self.scrollOut(self);
}


#pragma mark -

- (void)refreshAVPlayer {
    if ( _AVCarrier.bufferingFlag ) {
        [_AVCarrier cancelBuffering];
        if ( self.cancelledBuffer ) self.cancelledBuffer(self);
    }
    _AVCarrier = [[SJPlayerAVCarrier alloc] initWithURL:_AVCarrier.assetURL beginTime:0];
    _AVCarrier.delegate = self;
}

- (void)play {
    [self.AVCarrier play];
}

- (void)pause {
    [self.AVCarrier pause];
}

#pragma mark - 下面的属性是为了 1.1.4 以下版本的接口.   1.1.5以后, 将UI层与AV层分开处理了.
- (void)setRate:(float)rate {
    _AVCarrier.rate = rate;
}
- (float)rate {
    return _AVCarrier.rate;
}
- (float)loadedTimeProgressValue {
    return _AVCarrier.loadedTimeProgress;
}
- (BOOL)isLoadedPlayer {
    return _AVCarrier.isLoadedPlayer;
}
- (AVURLAsset *)asset {
    return _AVCarrier.asset;
}
- (AVPlayerItem *)playerItem {
    return _AVCarrier.playerItem;
}
- (AVPlayer *)player {
    return _AVCarrier.player;
}
- (NSURL *)assetURL {
    return _AVCarrier.assetURL;
}
- (NSTimeInterval)duration {
    return _AVCarrier.duration;
}
- (NSTimeInterval)currentTime {
    return _AVCarrier.currentTime;
}
- (float)progress {
    return _AVCarrier.progress;
}
- (NSIndexPath *)indexPath {
    return _scrollViewCarrier.indexPath;
}
- (NSInteger)superviewTag {
    return _scrollViewCarrier.superviewTag;
}
- (UIScrollView *)scrollView {
    return _scrollViewCarrier.scrollView;
}
- (NSIndexPath *)scrollViewIndexPath {
    return _scrollViewCarrier.scrollViewIndexPath;
}
- (UIScrollView *)rootScrollView {
    return _scrollViewCarrier.rootScrollView;
}
- (UIView *)tableHeaderSubView {
    return _scrollViewCarrier.tableHeaderSubView;
}
- (BOOL)isOtherAsset {
    return _AVCarrier.isOtherAsset;
}

- (NSString *)timeString:(NSInteger)secs {
    return [_AVCarrier timeString:secs];
}


- (UIImage * __nullable)screenshot {
    return [_AVCarrier screenshot];
}

- (UIImage * __nullable)screenshotWithTime:(CMTime)time {
    return [_AVCarrier screenshotWithTime:time];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(SJVideoPlayerAssetCarrier *asset, SJVideoPreviewModel * __nullable images, NSError *__nullable error))block {
    __weak typeof(self) _self = self;
    [_AVCarrier screenshotWithTime:time completion:^(SJPlayerAVCarrier * _Nonnull carrier, SJVideoPreviewModel * _Nullable images, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self, images, error);
    }];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(SJVideoPlayerAssetCarrier *asset, SJVideoPreviewModel * __nullable images, NSError *__nullable error))block {
    __weak typeof(self) _self = self;
    [_AVCarrier screenshotWithTime:time size:size completion:^(SJPlayerAVCarrier * _Nonnull carrier, SJVideoPreviewModel * _Nullable images, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self, images, error);
    }];
}


#pragma mark - preview images
- (BOOL)hasBeenGeneratedPreviewImages {
    return _AVCarrier.hasBeenGeneratedPreviewImages;
}
- (NSArray<SJVideoPreviewModel *> *)generatedPreviewImages {
    return _AVCarrier.generatedPreviewImages;
}
- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(SJVideoPlayerAssetCarrier *asset, NSArray<SJVideoPreviewModel *> *__nullable images, NSError *__nullable error))block {
    __weak typeof(self) _self = self;
    [_AVCarrier generatedPreviewImagesWithMaxItemSize:itemSize completion:^(SJPlayerAVCarrier * _Nonnull carrier, NSArray<SJVideoPreviewModel *> * _Nullable images, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self, images, error);
    }];
}

- (void)cancelPreviewImagesGeneration {
    [_AVCarrier cancelPreviewImagesGeneration];
}


#pragma mark - export

/**
 preset name default is `AVAssetExportPresetMediumQuality`.
 */
- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    endTime:(NSTimeInterval)endTime
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(SJVideoPlayerAssetCarrier *asset, float progress))progressBlock
                 completion:(void(^)(SJVideoPlayerAssetCarrier *asset, AVAsset * __nullable sandboxAsset, NSURL * __nullable fileURL, UIImage * __nullable thumbImage))completion
                    failure:(void(^)(SJVideoPlayerAssetCarrier *asset, NSError * __nullable error))failure {
    __weak typeof(self) _self = self;
    [_AVCarrier exportWithBeginTime:beginTime endTime:endTime presetName:presetName progress:^(SJPlayerAVCarrier * _Nonnull carrier, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( progressBlock ) progressBlock(self, progress);
    } completion:^(SJPlayerAVCarrier * _Nonnull carrier, AVAsset * _Nullable sandboxAsset, NSURL * _Nullable fileURL, UIImage * _Nullable thumbImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completion ) completion(self, sandboxAsset, fileURL, thumbImage);
    } failure:^(SJPlayerAVCarrier * _Nonnull carrier, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failure ) failure(self, error);
    }];
}
- (void)cancelExportOperation {
    [_AVCarrier cancelExportOperation];
}
/**
 generate gif
 @param interval        The interval at which the image is captured, Recommended setting 0.1f.
 */
- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(SJVideoPlayerAssetCarrier *asset, float progress))progressBlock
                      completion:(void(^)(SJVideoPlayerAssetCarrier *asset, UIImage *imageGIF, UIImage *thumbnailImage))completion
                         failure:(void(^)(SJVideoPlayerAssetCarrier *asset, NSError *error))failure {
    __weak typeof(self) _self = self;
    [_AVCarrier generateGIFWithBeginTime:beginTime duration:duration maximumSize:maximumSize interval:interval gifSavePath:gifSavePath progress:^(SJPlayerAVCarrier * _Nonnull carrier, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( progressBlock ) progressBlock(self, progress);
    } completion:^(SJPlayerAVCarrier * _Nonnull carrier, UIImage * _Nonnull imageGIF, UIImage * _Nonnull thumbnailImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completion ) completion(self, imageGIF, thumbnailImage);
    } failure:^(SJPlayerAVCarrier * _Nonnull carrier, NSError * _Nonnull error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failure ) failure(self, error);
    }];
}
- (void)cancelGenerateGIFOperation {
    [_AVCarrier cancelGenerateGIFOperation];
}

#pragma mark - seek to time
- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    [_AVCarrier jumpedToTime:time completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    [_AVCarrier seekToTime:time completionHandler:completionHandler];
}

@end
