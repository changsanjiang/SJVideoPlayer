//
//  SJControlLayerCarrier.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/6/1.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SJVideoPlayerControlLayerDataSource, SJVideoPlayerControlLayerDelegate;

NS_ASSUME_NONNULL_BEGIN

typedef long SJControlLayerIdentifier;

extern SJControlLayerIdentifier SJControlLayer_Uninitialized;


@interface SJControlLayerCarrier : NSObject
- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                        dataSource:(id<SJVideoPlayerControlLayerDataSource>)dataSource
                          delegate:(id<SJVideoPlayerControlLayerDelegate>)delegate
                      exitExeBlock:(void(^)(SJControlLayerCarrier *carrier))exitExeBlock
                   restartExeBlock:(void(^)(SJControlLayerCarrier *carrier))restartExeBlock;

@property (nonatomic, strong, readonly) id <SJVideoPlayerControlLayerDataSource> dataSource;
@property (nonatomic, strong, readonly) id <SJVideoPlayerControlLayerDelegate> delegate;
@property (nonatomic, readonly) SJControlLayerIdentifier identifier;

@property (nonatomic, copy, readonly) void(^exitExeBlock)(SJControlLayerCarrier *carrier);
@property (nonatomic, copy, readonly) void(^restartExeBlock)(SJControlLayerCarrier *carrier);
@end

NS_ASSUME_NONNULL_END
