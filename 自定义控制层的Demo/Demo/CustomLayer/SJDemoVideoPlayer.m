//
//  SJDemoVideoPlayer.m
//  Demo
//
//  Created by BlueDancer on 2018/5/18.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJDemoVideoPlayer.h"
#import "SJDemoVideoPlayerControlLayer.h"

@interface SJDemoVideoPlayer ()
@property (nonatomic, strong) SJDemoVideoPlayerControlLayer *layer;
@end

@implementation SJDemoVideoPlayer

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _layer = [SJDemoVideoPlayerControlLayer new];
    self.controlLayerDataSource = _layer;
    self.controlLayerDelegate = _layer;
    return self;
}
@end
