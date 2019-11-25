//
//  NSTimer+SJAssetAdd.m
//  SJVideoPlayerAssetCarrier
//
//  Created by 畅三江 on 2018/5/21.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "NSTimer+SJAssetAdd.h"

NS_ASSUME_NONNULL_BEGIN
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
NS_ASSUME_NONNULL_END
