//
//  SJTimerControl.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/6.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJTimerControl.h"


@interface NSTimer (SJTimerControl)
+ (NSTimer *)timer_timerWithTimeInterval:(NSTimeInterval)ti
                                   block:(void(^)(NSTimer *timer))block
                                 repeats:(BOOL)repeats;
@end

@implementation NSTimer (SJTimerControl)
+ (NSTimer *)timer_timerWithTimeInterval:(NSTimeInterval)ti
                                   block:(void(^)(NSTimer *timer))block
                                 repeats:(BOOL)repeats {
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti
                                             target:self
                                           selector:@selector(timer_exeBlock:)
                                           userInfo:block
                                            repeats:repeats];
    return timer;
}

+ (void)timer_exeBlock:(NSTimer *)timer {
    void(^block)(NSTimer *timer) = timer.userInfo;
    if ( block ) block(timer);
}

@end

@interface SJTimerControl ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) short point;
@property (nonatomic, assign) BOOL resetState;

@end

@implementation SJTimerControl

- (instancetype)init {
    self = [super init];
    if ( self ) {
        self.interval = 3;
    }
    return self;
}

- (void)setInterval:(short)interval {
    _interval = interval;
    _point = interval;
}

- (void)start {
    [self clear];
    
    __weak typeof(self) _self = self;
    _timer = [NSTimer timer_timerWithTimeInterval:1 block:^(NSTimer *timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ; 
        if ( 0 == --self.point ) {
            if ( self.exeBlock ) self.exeBlock(self);
            if ( !self.resetState ) [self clear];
            self.resetState = NO;
        }
    } repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

- (void)clear {
    [_timer invalidate];
    _timer = nil;
    _point = _interval;
}

- (void)reset {
    _point = _interval;
    _resetState = YES;
}
@end
