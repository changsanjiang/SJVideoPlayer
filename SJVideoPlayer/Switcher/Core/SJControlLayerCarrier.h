//
//  SJControlLayerCarrier.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/6/1.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>
#else
#import "SJVideoPlayerControlLayerProtocol.h"
#endif

typedef long SJControlLayerIdentifier;

extern SJControlLayerIdentifier SJControlLayer_Uninitialized;

@protocol SJControlLayerRestartProtocol,
SJControlLayerExitProtocol,
SJControlLayer;



NS_ASSUME_NONNULL_BEGIN
@interface SJControlLayerCarrier : NSObject
- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                      controlLayer:(id<SJControlLayer>)controlLayer;

@property (nonatomic, strong, readonly) id<SJControlLayer> controlLayer;
@property (nonatomic, readonly) SJControlLayerIdentifier identifier;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype) new NS_UNAVAILABLE;
@end




@protocol SJControlLayerRestartProtocol <NSObject>
@required
@property (nonatomic, readonly) BOOL restarted; // 是否已重新启用
- (void)restartControlLayer;    // 重新启用控制层.  切换器(switcher)切换控制层时, 该方法将会被调用
@end

@protocol SJControlLayerExitProtocol <NSObject>
@required
- (void)exitControlLayer;       // 退出控制层. 切换器(switcher)切换控制层时, 该方法将会被调用
@end

@protocol SJControlLayer <
SJVideoPlayerControlLayerDataSource,
SJVideoPlayerControlLayerDelegate,
SJControlLayerRestartProtocol,
SJControlLayerExitProtocol
>
@end


@interface SJControlLayerCarrier (Deprecated)
- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                        dataSource:(id<SJVideoPlayerControlLayerDataSource>)dataSource
                          delegate:(id<SJVideoPlayerControlLayerDelegate>)delegate
                      exitExeBlock:(void(^)(SJControlLayerCarrier *carrier))exitExeBlock
                   restartExeBlock:(void(^)(SJControlLayerCarrier *carrier))restartExeBlock __deprecated_msg("use `initWithIdentifier:controlLayer:`");
@property (nonatomic, strong, readonly) id <SJVideoPlayerControlLayerDataSource> dataSource __deprecated_msg("use `initWithIdentifier:controlLayer:`");
@property (nonatomic, strong, readonly) id <SJVideoPlayerControlLayerDelegate> delegate __deprecated_msg("use `initWithIdentifier:controlLayer:`");
@property (nonatomic, copy, readonly) void(^exitExeBlock)(SJControlLayerCarrier *carrier) __deprecated_msg("use `initWithIdentifier:controlLayer:`");
@property (nonatomic, copy, readonly) void(^restartExeBlock)(SJControlLayerCarrier *carrier) __deprecated_msg("use `initWithIdentifier:controlLayer:`");
@end
NS_ASSUME_NONNULL_END
