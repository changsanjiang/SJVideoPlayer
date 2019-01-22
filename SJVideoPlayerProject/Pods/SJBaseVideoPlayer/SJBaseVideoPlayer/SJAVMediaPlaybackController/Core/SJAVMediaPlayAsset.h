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

@protocol SJAVMediaPlayAssetPropertiesObserverDelegate;
@class SJAVMediaPlayAssetPropertiesObserver;

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlayAsset: NSObject<SJAVMediaPlayAssetProtocol>
- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime;
- (instancetype)initWithAVAsset:(__kindof AVAsset *)asset specifyStartTime:(NSTimeInterval)specifyStartTime;

@property (nonatomic, readonly) NSTimeInterval specifyStartTime;
@property (nonatomic, strong, readonly, nullable) NSURL *URL;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@end


/// 所有代理回调均在主线程
@interface SJAVMediaPlayAssetPropertiesObserver : NSObject
- (instancetype)initWithPlayerAsset:(__weak SJAVMediaPlayAsset *)playerAsset;

@property (nonatomic, weak, nullable) id<SJAVMediaPlayAssetPropertiesObserverDelegate> delegate;
@property (nonatomic, readonly) AVPlayerItemStatus playerItemStatus;
@property (nonatomic, readonly) SJPlayerBufferStatus bufferStatus;
@property (nonatomic, readonly) NSTimeInterval bufferLoadedTime;
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly) NSTimeInterval duration;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@end

@protocol SJAVMediaPlayAssetPropertiesObserverDelegate<NSObject>
@optional
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer durationDidChange:(NSTimeInterval)duration;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer currentTimeDidChange:(NSTimeInterval)currentTime;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer bufferLoadedTimeDidChange:(NSTimeInterval)bufferLoadedTime;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer bufferStatusDidChange:(SJPlayerBufferStatus)bufferStatus;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer presentationSizeDidChange:(CGSize)presentationSize;
- (void)observer:(SJAVMediaPlayAssetPropertiesObserver *)observer playerItemStatusDidChange:(AVPlayerItemStatus)playerItemStatus;
- (void)playDidToEndForObserver:(SJAVMediaPlayAssetPropertiesObserver *)observer;
@end
NS_ASSUME_NONNULL_END
