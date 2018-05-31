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
@property (nonatomic, strong) id <SJVideoPlayerControlLayerDataSource> dataSource;
@property (nonatomic, strong) id <SJVideoPlayerControlLayerDelegate> delegate;
@end

@implementation SJControlLayerCarrier
- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                        dataSource:(__strong id <SJVideoPlayerControlLayerDataSource>)dataSource
                          delegate:(__strong id<SJVideoPlayerControlLayerDelegate>)delegate {
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

- (void)appendControlLayer:(SJControlLayerCarrier *)carrier {
    [self.map setObject:carrier forKey:@(carrier.identifier)];
}

- (void)deleteControlLayerForIdentifier:(SJControlLayerIdentifier)identifier {
    [self.map removeObjectForKey:@(identifier)];
}

- (SJControlLayerCarrier *)controlLayerForIdentifier:(SJControlLayerIdentifier)identifier {
    return self.map[@(identifier)];
}

- (void)switchControlLayerForIdentitfier:(SJControlLayerIdentifier)identifier {
    SJControlLayerCarrier *carrier_new = self.map[@(identifier)];
    NSParameterAssert(carrier_new);
    [self controlLayerNeedDisappear];
    
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.controlLayerDataSource = carrier_new.dataSource;
        self.controlLayerDelegate = carrier_new.delegate;
    });
}

@end

SJControlLayerIdentifier SJDefaultControlLayer_edge = LONG_MAX;
SJControlLayerIdentifier SJDefaultControlLayer_DraggingPreview = LONG_MAX - 1;
