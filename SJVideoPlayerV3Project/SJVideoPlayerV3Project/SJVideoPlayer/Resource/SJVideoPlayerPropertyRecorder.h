//
//  SJVideoPlayerPropertyRecorder.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>

@interface SJVideoPlayerPropertyRecorder : NSObject
- (instancetype)initWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer;
@property (nonatomic) BOOL disableRotation;
@property (nonatomic) SJDisablePlayerGestureTypes disableGestureTypes;
@end
