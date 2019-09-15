//
//  SJVideoDefinitionSwitchingInfo.h
//  Pods
//
//  Created by 畅三江 on 2019/7/12.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerURLAsset.h"
#import "SJVideoPlayerPlaybackControllerDefines.h"
@class SJVideoDefinitionSwitchingInfoObserver;

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoDefinitionSwitchingInfo : NSObject

- (SJVideoDefinitionSwitchingInfoObserver *)getObserver;

@property (nonatomic, weak, readonly, nullable) SJVideoPlayerURLAsset *currentPlayingAsset;

@property (nonatomic, weak, readonly, nullable) SJVideoPlayerURLAsset *switchingAsset;

@property (nonatomic, readonly) SJDefinitionSwitchStatus status;

@end



@interface SJVideoDefinitionSwitchingInfoObserver: NSObject

@property (nonatomic, copy, nullable) void(^statusDidChangeExeBlock)(SJVideoDefinitionSwitchingInfo *info);

@end

NS_ASSUME_NONNULL_END
