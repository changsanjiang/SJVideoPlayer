//
//  SJAVMediaPlayAsset.h
//  SJVideoPlayerAssetCarrier
//
//  Created by BlueDancer on 2018/6/28.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJAVMediaPlayAssetProtocol.h"
#import "SJPlayerBufferStatus.h"
@class SJAVMediaPlayAssetPropertiesObserver;

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlayAsset: NSObject<SJAVMediaPlayAssetProtocol>
/// 通过URL进行初始化
- (instancetype)initWithAVAsset:(__kindof AVAsset *)asset specifyStartTime:(NSTimeInterval)specifyStartTime;
- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime;
- (instancetype)initWithURL:(NSURL *)URL;

/// 指定开始播放的时间
@property (nonatomic, readonly) NSTimeInterval specifyStartTime;
/// 播放的URL
@property (nonatomic, strong, readonly, nullable) NSURL *URL;
/// 是否已加载完毕
@property (readonly) BOOL loadIsCompleted;
/// 加载
- (void)load;
@end

#pragma mark -

@protocol SJAVMediaPlayAssetPropertiesObserverDelegate<NSObject>

@optional
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer durationDidChange:(NSTimeInterval)duration;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer currentTimeDidChange:(NSTimeInterval)currentTime;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer bufferLoadedTimeDidChange:(NSTimeInterval)bufferLoadedTime;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer presentationSizeDidChange:(CGSize)presentationSize;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer playerItemStatusDidChange:(AVPlayerItemStatus)playerItemStatus;
- (void)assetLoadIsCompletedForObserver:(SJAVMediaPlayAssetPropertiesObserver *)observer;
- (void)playDidToEndForObserver:(SJAVMediaPlayAssetPropertiesObserver *)observer;

@end

/// 确保所有代理回调均在主线程
@interface SJAVMediaPlayAssetPropertiesObserver : NSObject

- (instancetype)initWithPlayerAsset:(__weak SJAVMediaPlayAsset *)playerAsset;

@property (nonatomic, weak, nullable) id<SJAVMediaPlayAssetPropertiesObserverDelegate> delegate;
@property (nonatomic, readonly) AVPlayerItemStatus playerItemStatus;
@property (nonatomic, readonly) SJPlayerBufferStatus bufferStatus;
@property (nonatomic, readonly) NSTimeInterval bufferLoadedTime;
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
