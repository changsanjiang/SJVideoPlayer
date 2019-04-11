//
//  SJVideoPlayerURLAsset+SJAVMediaPlaybackAdd.h
//  Project
//
//  Created by 畅三江 on 2018/8/12.
//  Copyright © 2018 SanJiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset.h"
#import <AVFoundation/AVFoundation.h>
#import "SJPlayModel.h"
#import "SJMediaPlaybackControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerURLAsset (SJAVMediaPlaybackAdd)<SJAVMediaModelProtocol>
- (instancetype)initWithAVAsset:(__kindof AVAsset *)asset;
- (instancetype)initWithAVAsset:(__kindof AVAsset *)asset playModel:(__kindof SJPlayModel *)playModel;
- (instancetype)initWithAVAsset:(__kindof AVAsset *)asset specifyStartTime:(NSTimeInterval)specifyStartTime playModel:(__kindof SJPlayModel *)playModel;
@property (nonatomic, strong, readonly, nullable) __kindof AVAsset *avAsset;
@end
NS_ASSUME_NONNULL_END
