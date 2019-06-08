//
//  NSTimer+SJAssetAdd.m
//  SJVideoPlayerAssetCarrier
//
//  Created by BlueDancer on 2018/5/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "NSTimer+SJAssetAdd.h"

@implementation NSTimer (SJAssetAdd)
+ (NSTimer *)assetAdd_timerWithTimeInterval:(NSTimeInterval)ti
                                      block:(void(^)(NSTimer *timer))block
                                    repeats:(BOOL)repeats {
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti
                                             target:self
                                           selector:@selector(assetAdd_exeBlock:)
                                           userInfo:block
                                            repeats:repeats];
    return timer;
}

+ (void)assetAdd_exeBlock:(NSTimer *)timer {
    void(^block)(NSTimer *timer) = timer.userInfo;
    if ( block ) block(timer);
    else [timer invalidate];
}

- (void)assetAdd_fire {
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.timeInterval]];
}
@end
