//
//  SJVideoPlayerPropertyRecorder.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerPropertyRecorder.h"

@implementation SJVideoPlayerPropertyRecorder
- (instancetype)initWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    self = [super init];
    if ( !self ) return nil;
    _disableRotation = videoPlayer.disableRotation;
    _disableGestureTypes = videoPlayer.disableGestureTypes;
    return self;
}
@end
