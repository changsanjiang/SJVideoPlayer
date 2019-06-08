//
//  SJResidentThread.m
//  Pods
//
//  Created by 畅三江 on 2019/4/14.
//

#import "SJResidentThread.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJResidentThread () {
    NSThread *_thread;
}
@end

@implementation SJResidentThread
- (instancetype)init {
    self = [super init];
    if (self) {
        _thread = [[NSThread alloc] initWithTarget:[self class] selector:@selector(_run) object:nil];
        _thread.qualityOfService = NSQualityOfServiceUserInteractive;
        [_thread start];
    }
    return self;
}

+ (void)_run {
#ifdef SJMAC
    NSLog(@"--begin--");
#endif
    @autoreleasepool {
        NSThread *thread = [NSThread currentThread];
        [thread setName:@"com.SJUIKit.SJResidentThread"];
        CFRunLoopRef rl = CFRunLoopGetCurrent();
        CFRunLoopSourceContext context = {0};
        CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
        CFRunLoopAddSource(rl, source, kCFRunLoopDefaultMode);
        CFRelease(source);
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, false);
    }
#ifdef SJMAC
    NSLog(@"--end--");
#endif
}

- (void)performBlock:(void(^)(void))block {
    [self performSelector:@selector(_performBlockOnResidentThread:) onThread:_thread withObject:block waitUntilDone:NO];
}

- (void)_performBlockOnResidentThread:(void(^)(void))block {
    if ( block ) block();
}

- (void)_stop {
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)dealloc {
    [self performSelector:@selector(_stop) onThread:_thread withObject:nil waitUntilDone:YES];
}
@end
NS_ASSUME_NONNULL_END
