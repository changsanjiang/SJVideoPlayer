//
//  NSTimer+SJExtention.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/23.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "NSTimer+SJExtention.h"

@implementation NSTimer (SJExtention)

+ (instancetype)sj_scheduledTimerWithTimeInterval:(NSTimeInterval)ti exeBlock:(void(^)())block repeats:(BOOL)yesOrNo {
    NSAssert(block, @"block 不可为空");
    return [self scheduledTimerWithTimeInterval:ti target:self selector:@selector(sj_exeTimerEvent:) userInfo:[block copy] repeats:yesOrNo];
}

+ (void)sj_exeTimerEvent:(NSTimer *)timer {
    void(^block)() = timer.userInfo;
    if ( block ) block();
}

@end
