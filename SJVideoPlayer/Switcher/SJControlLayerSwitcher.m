//
//  SJControlLayerSwitcher.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/6/1.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJControlLayerSwitcher.h"


NS_ASSUME_NONNULL_BEGIN

@interface SJControlLayerSwitcher ()

@property (nonatomic, strong, readonly) NSMutableDictionary *map;
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *videoPlayer;

@end

@implementation SJControlLayerSwitcher

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _map = [NSMutableDictionary dictionary];
    _previousIdentifier = SJControlLayer_Uninitialized;
    _currentIdentifier = SJControlLayer_Uninitialized;
    return self;
}

- (void)switchControlLayerForIdentitfier:(SJControlLayerIdentifier)identifier toVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    SJControlLayerCarrier *carrier_new = self.map[@(identifier)];
    NSParameterAssert(carrier_new);
    
    SJControlLayerCarrier *carrier_old = self.map[@(self.currentIdentifier)];
    if ( carrier_old.exitExeBlock ) carrier_old.exitExeBlock(carrier_old);
    
    videoPlayer.controlLayerDataSource = carrier_new.dataSource;
    videoPlayer.controlLayerDelegate = carrier_new.delegate;
    
    _previousIdentifier = _currentIdentifier;
    _currentIdentifier = carrier_new.identifier;
    _videoPlayer = videoPlayer;
    
    if ( carrier_new.restartExeBlock ) carrier_new.restartExeBlock(carrier_new);
}

- (BOOL)switchToPreviousControlLayer {
    if ( self.previousIdentifier == SJControlLayer_Uninitialized ) return NO;
    if ( !self.videoPlayer ) return NO;
    [self switchControlLayerForIdentitfier:self.previousIdentifier toVideoPlayer:self.videoPlayer];
    return YES;
}

- (void)addControlLayer:(SJControlLayerCarrier *)carrier {
    [self.map setObject:carrier forKey:@(carrier.identifier)];
}

- (void)deleteControlLayerForIdentifier:(SJControlLayerIdentifier)identifier {
    [self.map removeObjectForKey:@(identifier)];
}

- (nullable SJControlLayerCarrier *)controlLayerForIdentifier:(SJControlLayerIdentifier)identifier {
    return self.map[@(identifier)];
}
@end


SJControlLayerIdentifier SJControlLayer_Uninitialized = LONG_MAX;

NS_ASSUME_NONNULL_END
