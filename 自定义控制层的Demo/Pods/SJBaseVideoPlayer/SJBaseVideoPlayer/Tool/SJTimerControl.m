//
//  SJTimerControl.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/6.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJTimerControl.h"
#import "NSTimer+SJAssetAdd.h"

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
    _timer = [NSTimer assetAdd_timerWithTimeInterval:1 block:^(NSTimer *timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) {
            [timer invalidate];
            return ;
        }
        if ( 0 == --self.point ) {
            if ( self.exeBlock ) self.exeBlock(self);
            if ( !self.resetState ) [self clear];
            self.resetState = NO;
        }
    } repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer assetAdd_fire];
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
