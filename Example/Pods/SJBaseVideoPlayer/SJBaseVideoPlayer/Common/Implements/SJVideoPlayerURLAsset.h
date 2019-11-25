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
- (nullable instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime playModel:(__kindof SJPlayModel *)playModel;
- (nullable instancetype)initWithURL:(NSURL *)URL specifyStartTime:(NSTimeInterval)specifyStartTime;
- (nullable instancetype)initWithURL:(NSURL *)URL playModel:(__kindof SJPlayModel *)playModel;
- (nullable instancetype)initWithURL:(NSURL *)URL;

@property (nonatomic, strong, readonly, nullable) SJVideoPlayerURLAsset *originAsset;
- (nullable instancetype)initWithOtherAsset:(SJVideoPlayerURLAsset *)otherAsset playModel:(nullable __kindof SJPlayModel *)playModel;

@property (nonatomic) NSTimeInterval specifyStartTime;

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
