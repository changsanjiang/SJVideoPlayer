//
//  SJTimerControl.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/6.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJTimerControl.h"

@interface SJTimerControl ()

@property (nonatomic, copy, readwrite) void(^block)(SJTimerControl *control);

@end

@implementation SJTimerControl

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _interval = 3.0;
    }
    return self;
}

- (void)_exeBlock {
    if ( _block ) _block(self);
    _block = nil;
}

- (void)start:(void(^)(SJTimerControl *control))block {
    _block = block;
    [self performSelector:@selector(_exeBlock) withObject:nil afterDelay:_interval];
}

- (void)reset {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_exeBlock) object:nil];
}

@end
