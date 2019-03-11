//
//  SJBaseVideoPlayer+SetPlaybackRateAdd.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/3/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJBaseVideoPlayer+SetPlaybackRateAdd.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJBaseVideoPlayer (SetPlaybackRateAdd)
- (SJPlaybackRateLevels *)rateLevels {
    SJPlaybackRateLevels *s = objc_getAssociatedObject(self, _cmd);
    if ( s ) return s;
    s = [SJPlaybackRateLevels new];
    objc_setAssociatedObject(self, _cmd, s, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return s;
}
@end
NS_ASSUME_NONNULL_END
