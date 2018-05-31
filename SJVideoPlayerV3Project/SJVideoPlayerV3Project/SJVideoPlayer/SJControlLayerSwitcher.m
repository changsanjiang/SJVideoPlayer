//
//  SJControlLayerSwitcher.m
//  SJVideoPlayerV3Project
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJControlLayerSwitcher.h"

@interface SJControlLayerSwitcher ()
@property (nonatomic, weak, readonly) SJBaseVideoPlayer *videoPlayer;
@property (nonatomic, strong, readonly) NSMutableDictionary *map;
@end

@implementation SJControlLayerSwitcher

- (instancetype)initWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    self = [super init];
    if ( !self ) return nil;
    _videoPlayer = videoPlayer;
    _map = [NSMutableDictionary dictionary];
    return self;
}

- (void)registerWithIdentifier:(SJControlLayerIdentifier)identifier
                  controlLayer:(__kindof UIView * _Nonnull (^)(SJControlLayerSwitcher * _Nonnull, SJControlLayerIdentifier))controlLayer {
    NSParameterAssert(controlLayer);
    [_map setObject:[controlLayer copy] forKey:@(identifier)];
}

- (void)switchControlLayerForIdentifier:(SJControlLayerIdentifier)identifier {

}
@end
