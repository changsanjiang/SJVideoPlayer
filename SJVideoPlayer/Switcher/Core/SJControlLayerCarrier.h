//
//  SJControlLayerCarrier.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/6/1.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJControlLayerDefines.h"

// - Deprecated -

NS_ASSUME_NONNULL_BEGIN
@interface SJControlLayerCarrier : NSObject
- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                      controlLayer:(id<SJControlLayer>)controlLayer;

@property (nonatomic, strong, readonly) id<SJControlLayer> controlLayer;
@property (nonatomic, readonly) SJControlLayerIdentifier identifier;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype) new NS_UNAVAILABLE;
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
