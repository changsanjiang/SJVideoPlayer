//
//  SJPlayAsset.h
//  SJVideoPlayerAssetCarrier
//
//  Created by BlueDancer on 2018/6/28.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJPlayAssetProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class SJPlayAssetPropertiesObserver;

typedef NS_ENUM(NSUInteger, SJPlayerBufferStatus) {
    SJPlayerBufferStatusUnknown,
    SJPlayerBufferStatusEmpty,
    SJPlayerBufferStatusFull,
};

@interface SJPlayAsset: NSObject<SJPlayAsset>

/// 通过URL进行初始化
- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime;
- (instancetype)initWithURL:(NSURL *)URL;

/// 通过其他资源进行初始化
- (instancetype)initWithOtherAsset:(SJPlayAsset *)other;

/// 指定开始播放的时间
@property (nonatomic, readonly) NSTimeInterval specifyStartTime;
/// 播放的URL
@property (nonatomic, strong, readonly) NSURL *URL;
/// 是否是通过其他资源进行的初始化
@property (nonatomic, readonly) BOOL isOtherAsset;

@end

#pragma mark -

@protocol SJPlayAssetPropertiesObserverDelegate<NSObject>

@optional
- (void)observer:(SJPlayAssetPropertiesObserver *)observer durationDidChange:(NSTimeInterval)duration;
- (void)observer:(SJPlayAssetPropertiesObserver *)observer currentTimeDidChange:(NSTimeInterval)currentTime;
- (void)observer:(SJPlayAssetPropertiesObserver *)observer bufferLoadedTimeDidChange:(NSTimeInterval)bufferLoadedTime;
- (void)observer:(SJPlayAssetPropertiesObserver *)observer bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus;
- (void)observer:(SJPlayAssetPropertiesObserver *)observer presentationSizeDidChange:(CGSize)presentationSize;
- (void)observer:(SJPlayAssetPropertiesObserver *)observer playerItemStatusDidChange:(AVPlayerItemStatus)playerItemStatus;
- (void)assetLoadIsCompletedForObserver:(SJPlayAssetPropertiesObserver *)observer;
- (void)playDidToEndForObserver:(SJPlayAssetPropertiesObserver *)observer;

@end

@interface SJPlayAssetPropertiesObserver : NSObject

- (instancetype)initWithPlayerAsset:(SJPlayAsset *)playerAsset;

@property (nonatomic, weak, nullable) id<SJPlayAssetPropertiesObserverDelegate> delegate;
@property (nonatomic, readonly) AVPlayerItemStatus playerItemStatus;
@property (nonatomic, readonly) SJPlayerBufferStatus bufferStatus;
@property (nonatomic, readonly) NSTimeInterval bufferLoadedTime;
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
