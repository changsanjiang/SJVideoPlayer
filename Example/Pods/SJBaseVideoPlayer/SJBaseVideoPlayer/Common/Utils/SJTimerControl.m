//
//  SJTimerControl.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/12/6.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJTimerControl.h"
#import "NSTimer+SJAssetAdd.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJTimerControl ()
@property (nonatomic, strong, nullable) NSTimer *timer;
@property (nonatomic) short point;
@end

@implementation SJTimerControl
- (instancetype)init {
    self = [super init];
    if ( self ) {
        self.interval = 3;
    }
    return self;
}

- (void)setInterval:(NSTimeInterval)interval {
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
        if ( (--self.point) <= 0 ) {
            if ( self.exeBlock ) self.exeBlock(self);
            [self clear];
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
@end
NS_ASSUME_NONNULL_END
