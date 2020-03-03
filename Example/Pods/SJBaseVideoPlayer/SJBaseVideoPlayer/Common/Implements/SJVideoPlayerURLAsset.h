//
//  SJVideoPlayerURLAsset.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/1/29.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJPlayModel.h"
#import "SJVideoPlayerPlaybackControllerDefines.h"

@protocol SJVideoPlayerURLAssetObserver;

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerURLAsset : NSObject<SJMediaModelProtocol>
- (nullable instancetype)initWithURL:(NSURL *)URL startPosition:(NSTimeInterval)startPosition playModel:(__kindof SJPlayModel *)playModel;
- (nullable instancetype)initWithURL:(NSURL *)URL startPosition:(NSTimeInterval)startPosition;
- (nullable instancetype)initWithURL:(NSURL *)URL playModel:(__kindof SJPlayModel *)playModel;
- (nullable instancetype)initWithURL:(NSURL *)URL;

/// 开始播放的位置, 单位秒
@property (nonatomic) NSTimeInterval startPosition;

/// 试用结束的位置, 单位秒
@property (nonatomic) NSTimeInterval trialEndPosition;

@property (nonatomic, strong, null_resettable) SJPlayModel *playModel;
- (id<SJVideoPlayerURLAssetObserver>)getObserver;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@property (nonatomic, readonly) BOOL isM3u8;
@end


@protocol SJVideoPlayerURLAssetObserver <NSObject>
@property (nonatomic, copy, nullable) void(^playModelDidChangeExeBlock)(SJVideoPlayerURLAsset *asset);
@end
NS_ASSUME_NONNULL_END
