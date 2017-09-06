//
//  NSTimer+SJExtension.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/6.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "NSTimer+SJExtension.h"

@implementation NSTimer (SJExtension)

+ (instancetype)sj_scheduledTimerWithTimeInterval:(NSTimeInterval)ti exeBlock:(void(^)())block repeats:(BOOL)yesOrNo {
    NSAssert(block, @"block 不可为空");
    return [self scheduledTimerWithTimeInterval:ti target:self selector:@selector(sj_exeTimerEvent:) userInfo:[block copy] repeats:yesOrNo];
}

+ (void)sj_exeTimerEvent:(NSTimer *)timer {
    void(^block)() = timer.userInfo;
    if ( block ) block();
}

@end
