//
//  NSTimer+SJAssetAdd.m
//  SJVideoPlayerAssetCarrier
//
//  Created by 畅三江 on 2018/5/21.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "NSTimer+SJAssetAdd.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation NSTimer (SJAssetAdd)
+ (void)sj_exeUsingBlock:(NSTimer *)timer {
    if ( timer.sj_usingBlock != nil ) timer.sj_usingBlock(timer);
}

+ (NSTimer *)sj_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats {
    return [self sj_timerWithTimeInterval:interval repeats:repeats usingBlock:nil];
}

+ (NSTimer *)sj_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats usingBlock:(void(^_Nullable)(NSTimer *timer))usingBlock {
    NSTimer *timer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(sj_exeUsingBlock:) userInfo:nil repeats:repeats];
    timer.sj_usingBlock = usingBlock;
    return timer;
}

- (void)setSj_usingBlock:(void (^_Nullable)(NSTimer * _Nonnull))sj_usingBlock {
    objc_setAssociatedObject(self, @selector(sj_usingBlock), sj_usingBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^_Nullable)(NSTimer * _Nonnull))sj_usingBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)sj_fire {
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.timeInterval]];
}
@end

@implementation NSTimer (SJDeprecated)
+ (NSTimer *)assetAdd_timerWithTimeInterval:(NSTimeInterval)ti
                                      block:(void(^)(NSTimer *timer))block
                                    repeats:(BOOL)repeats {
    return [self sj_timerWithTimeInterval:ti repeats:repeats usingBlock:block];
}

- (void)assetAdd_fire {
    [self sj_fire];
}
@end
NS_ASSUME_NONNULL_END
