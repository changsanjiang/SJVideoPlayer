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
#import "SJMediaPlaybackProtocol.h"

@protocol SJAVMediaPlayAssetPropertiesObserverDelegate;
@class SJAVMediaPlayAssetPropertiesObserver;

UIKIT_EXTERN NSNotificationName const SJAVMediaDidPlayToEndTimeNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaPlaybackTimeDidChangeNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaPlaybackDurationDidChangeNotificationn;
UIKIT_EXTERN NSNotificationName const SJAVMediaBufferStatusDidChangeNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaBufferLoadedTimeRangesDidChangeNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaBufferWatingTimeDidChangeNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaPresentationSizeDidChangeNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaPlayerItemStatusDidChangeNotification;
UIKIT_EXTERN NSNotificationName const SJAVMediaPlaybackTypeLoadedNotification;


NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlayAsset: NSObject<SJAVMediaPlayAssetProtocol>
- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime;
- (instancetype)initWithAVAsset:(__kindof AVAsset *)asset specifyStartTime:(NSTimeInterval)specifyStartTime;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;

@property (nonatomic, strong, readonly, nullable) NSURL *URL;
@property (nonatomic, readonly) NSTimeInterval specifyStartTime;
@property (nonatomic, readonly) CMTime duration;
@property (nonatomic, readonly) CMTime currentTime;
@property (nonatomic, readonly) SJPlayerBufferStatus bufferStatus;
@property (nonatomic, readonly) NSTimeInterval bufferWatingTime;
@property (nonatomic, readonly) CMTimeRange bufferLoadedTime;
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly) AVPlayerItemStatus playerItemStatus;
@property (nonatomic, readonly) SJMediaPlaybackType playbackType;
- (void)updateBufferStatus;
@end


/// 所有代理回调均在主线程
@interface SJAVMediaPlayAssetPropertiesObserver : NSObject
- (instancetype)initWithPlayerAsset:(__weak SJAVMediaPlayAsset *)playerAsset;

@property (nonatomic, weak, nullable) id<SJAVMediaPlayAssetPropertiesObserverDelegate> delegate;
@property (nonatomic, readonly) AVPlayerItemStatus playerItemStatus;
@property (nonatomic, readonly) SJPlayerBufferStatus bufferStatus;
@property (nonatomic, readonly) NSTimeInterval bufferLoadedTime; // 已缓冲到的时间
@property (nonatomic, readonly) NSTimeInterval bufferWatingTime; // 如果状态为`Unplayable`, 则每等待`1`秒, 此属性的值将`+1`, 当缓冲状态为`Playable`后, 将会被置为 0
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) SJMediaPlaybackType playbackType;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@end

@protocol SJAVMediaPlayAssetPropertiesObserverDelegate<NSObject>
@optional
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer durationDidChange:(NSTimeInterval)duration;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer currentTimeDidChange:(NSTimeInterval)currentTime;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer bufferLoadedTimeDidChange:(NSTimeInterval)bufferLoadedTime;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer bufferWatingTimeDidChange:(NSTimeInterval)bufferWatingTime;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer presentationSizeDidChange:(CGSize)presentationSize;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer playerItemStatusDidChange:(AVPlayerItemStatus)playerItemStatus;
- (void)playDidToEndForObserver:(SJAVMediaPlayAssetPropertiesObserver *)observer;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer playbackTypeLoaded:(SJMediaPlaybackType)playbackType;
@end
NS_ASSUME_NONNULL_END
