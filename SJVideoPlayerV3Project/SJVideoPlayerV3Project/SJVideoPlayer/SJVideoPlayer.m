//
//  SJVideoPlayer.m
//  SJVideoPlayerV3Project
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJVideoPlayer.h"

@interface SJControlLayerCarrier ()
@property (nonatomic) SJControlLayerIdentifier identifier;
@property (nonatomic, weak) id <SJVideoPlayerControlLayerDataSource> dataSource;
@property (nonatomic, weak) id <SJVideoPlayerControlLayerDelegate> delegate;
@end

@implementation SJControlLayerCarrier
- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                        dataSource:(id<SJVideoPlayerControlLayerDataSource>)dataSource
                          delegate:(id<SJVideoPlayerControlLayerDelegate>)delegate {
    self = [super init];
    if ( !self ) return nil;
    _identifier = identifier;
    _dataSource = dataSource;
    _delegate = delegate;
    return self;
}
@end


@interface SJVideoPlayer ()
@property (nonatomic, strong, readonly) NSMutableDictionary *map;
@end

@implementation SJVideoPlayer

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _map = [NSMutableDictionary dictionary];
    return self;
}

- (void)appendCarrier:(SJControlLayerCarrier *)carrier {
    [self.map setObject:carrier forKey:@(carrier.identifier)];
}

- (void)deleteCarrierForCarrierIdentifier:(SJControlLayerIdentifier)identifier {
    [self.map removeObjectForKey:@(identifier)];
}

- (nullable SJControlLayerCarrier *)carrierForIdentifier:(SJControlLayerIdentifier)identifier {
    return self.map[@(identifier)];
}

- (void)changeControlLayerForCarrierIdentitfier:(SJControlLayerIdentifier)identifier {
    SJControlLayerCarrier *carrier = self.map[@(identifier)];
    NSParameterAssert(carrier);
    self.controlLayerDataSource = carrier.dataSource;
    self.controlLayerDelegate = carrier.delegate;
}

@end

SJControlLayerIdentifier SJDefaultControlLayer_edge = LONG_MAX;
SJControlLayerIdentifier SJDefaultControlLayer_DraggingPreview = LONG_MAX - 1;
