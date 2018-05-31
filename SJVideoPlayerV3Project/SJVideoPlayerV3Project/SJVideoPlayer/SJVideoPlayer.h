//
//  SJVideoPlayer.h
//  SJVideoPlayerV3Project
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJBaseVideoPlayer.h"

NS_ASSUME_NONNULL_BEGIN
typedef long SJControlLayerIdentifier;
@class SJControlLayerCarrier;

extern SJControlLayerIdentifier SJDefaultControlLayer_edge;
extern SJControlLayerIdentifier SJDefaultControlLayer_DraggingPreview;

@interface SJVideoPlayer : SJBaseVideoPlayer

@property (nonatomic, readonly) SJControlLayerIdentifier currentControlLayerIdentifier;

- (void)appendCarrier:(SJControlLayerCarrier *)carrier;
- (nullable SJControlLayerCarrier *)carrierForIdentifier:(SJControlLayerIdentifier)identifier;
- (void)deleteCarrierForCarrierIdentifier:(SJControlLayerIdentifier)identifier;
- (void)changeControlLayerForCarrierIdentitfier:(SJControlLayerIdentifier)identifier;

@end


#pragma mark
@interface SJControlLayerCarrier : NSObject
- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                        dataSource:(id <SJVideoPlayerControlLayerDataSource>)dataSource
                          delegate:(id<SJVideoPlayerControlLayerDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
