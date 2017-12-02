//
//  SJVideoPlayerAssetCarrier.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/1.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerAssetCarrier.h"
#import <UIKit/UIKit.h>

/*!
 *  Refresh interval for timed observations of AVPlayer
 */
#define SJREFRESH_INTERVAL (0.5)

/*!
 *  0.0 - 1.0
 */
#define SJPreImgGenerateInterval (0.05)


@interface SJVideoPlayerAssetCarrier () {
    id _timeObserver;
    id _itemEndObserver;
}

@property (nonatomic, strong, readwrite) AVAssetImageGenerator *imageGenerator;

@end

@implementation SJVideoPlayerAssetCarrier

- (instancetype)initWithAssetURL:(NSURL *)assetURL {
    self = [super init];
    if ( !self ) return nil;
    _asset = [AVURLAsset assetWithURL:assetURL];
    _playerItem = [AVPlayerItem playerItemWithAsset:_asset automaticallyLoadedAssetKeys:@[@"duration"]];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _assetURL = assetURL;
    [self _addTimeObserver];
    [self _addItemPlayEndObserver];
    [self _addPlayerItemObserver];
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

- (void)_addPlayerItemObserver {
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( self.playerItemStateChanged ) self.playerItemStateChanged(self, self.playerItem.status);
}

#pragma mark -
- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize completion:(void (^)(SJVideoPlayerAssetCarrier * _Nonnull, NSArray<SJVideoPreviewModel *> * _Nullable, NSError * _Nullable))block {
    NSMutableArray<NSValue *> *timesM = [NSMutableArray new];
    NSInteger seconds = (long)_asset.duration.value / _asset.duration.timescale;
    if ( 0 == seconds || isnan(seconds) ) return;
    if ( SJPreImgGenerateInterval > 1.0 ) return;
    __block short maxCount = (short)floorf(1.0 / SJPreImgGenerateInterval);
    short interval = (short)floor(seconds * SJPreImgGenerateInterval);
    for ( int i = 0 ; i < maxCount ; i ++ ) {
        CMTime time = CMTimeMake(i * interval, 1);
        NSValue *tV = [NSValue valueWithCMTime:time];
        if ( tV ) [timesM addObject:tV];
    }
    __weak typeof(self) _self = self;
    NSMutableArray <SJVideoPreviewModel *> *imagesM = [NSMutableArray new];
    _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
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
                if ( block ) block(self, imagesM, nil);
            });
            
        }
    }];
}

- (void)dealloc {
    [self.player removeTimeObserver:_timeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    
    // 清空操作
}

@end
