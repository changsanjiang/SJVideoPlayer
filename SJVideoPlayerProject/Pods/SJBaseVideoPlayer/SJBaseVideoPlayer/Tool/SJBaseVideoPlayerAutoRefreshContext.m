//
//  SJBaseVideoPlayerAutoRefreshContext.m
//  Pods
//
//  Created by BlueDancer on 2019/3/4.
//

#import "SJBaseVideoPlayerAutoRefreshContext.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseVideoPlayerAutoRefreshContext ()
@property (nonatomic) BOOL isPaused;
@property (nonatomic) BOOL isWaiting;
@end

@implementation SJBaseVideoPlayerAutoRefreshContext {
    NSTimeInterval _delay;
}
- (instancetype)initWithAsset:(SJVideoPlayerURLAsset *)asset delay:(NSTimeInterval)delay {
    self = [super init];
    if ( !self ) return nil;
    _asset = asset;
    _delay = delay;
    [self resume];
    return self;
}
- (void)pause {
    self.isPaused = YES;
    self.isWaiting = NO;
}
- (void)resume {
    if ( self.isWaiting ) return;
    self.isWaiting = YES;
    self.isPaused = NO;
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.isPaused ) return;
        if ( self.after )
            self.after(self);
        self.isWaiting = NO;
    });
}
@end
NS_ASSUME_NONNULL_END
