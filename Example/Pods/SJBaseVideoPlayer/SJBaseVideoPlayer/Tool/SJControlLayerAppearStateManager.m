//
//  SJControlLayerAppearStateManager.m
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2018/12/28.
//

#import "SJControlLayerAppearStateManager.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif
#import "SJTimerControl.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJControlLayerAppearManagerObserver : NSObject<SJControlLayerAppearManagerObserver>
- (instancetype)initWithManager:(id<SJControlLayerAppearManager>)mgr;
@end

@implementation SJControlLayerAppearManagerObserver
@synthesize appearStateDidChangeExeBlock = _appearStateDidChangeExeBlock;
- (instancetype)initWithManager:(SJControlLayerAppearStateManager *)mgr {
    self = [super init];
    if ( !self )
        return nil;
    [mgr sj_addObserver:self forKeyPath:@"isAppeared"];
    return self;
}

- (void)observeValueForKeyPath:(NSString *_Nullable)keyPath ofObject:(id _Nullable)object change:(NSDictionary<NSKeyValueChangeKey,id> *_Nullable)change context:(void *_Nullable)context {

    if ( _appearStateDidChangeExeBlock )
        _appearStateDidChangeExeBlock(object);
}
@end

@interface SJControlLayerAppearStateManager ()
@property (nonatomic, strong, readonly) SJTimerControl *timer;
@property (nonatomic) BOOL isAppeared;
@end

@implementation SJControlLayerAppearStateManager
@synthesize disabled = _disabled;
@synthesize isAppeared = _isAppeared;
@synthesize canAutomaticallyDisappear = _canAutomaticallyDisappear;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _timer = [[SJTimerControl alloc] init];
    __weak typeof(self) _self = self;
    _timer.exeBlock = ^(SJTimerControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.isDisabled ) {
            [control clear];
            return;
        }
        if ( self.canAutomaticallyDisappear ) {
            if ( !self.canAutomaticallyDisappear(self) )
                return;
        }
        [self needDisappear];
    };
    return self;
}

- (id<SJControlLayerAppearManagerObserver>)getObserver {
    return [[SJControlLayerAppearManagerObserver alloc] initWithManager:self];
}

- (void)setInterval:(NSTimeInterval)interval {
    _timer.interval = interval;
}

- (NSTimeInterval)interval {
    return _timer.interval;
}

- (void)switchAppearState {
    if ( _isAppeared )
        [self needDisappear];
    else
        [self needAppear];
}

- (void)needAppear {
    [self _start];
    self.isAppeared = YES;
}

- (void)needDisappear {
    [self _clear];
    self.isAppeared = NO;
}

- (void)resume {
    if ( _isAppeared ) [self _start];
}

- (void)keepAppearState {
    [self needAppear];
    [self _clear];
}

- (void)keepDisappearState {
    [self needDisappear];
}

#pragma mark -

- (void)setDisabled:(BOOL)disabled {
    if ( disabled == _disabled )
        return;
    _disabled = disabled;

    if ( disabled )
        [self _clear];
    else if ( _isAppeared )
        [self _start];
}

- (void)_start {
    if ( _disabled )
        return;
    [_timer start];
}

- (void)_clear {
    [_timer clear];
}
@end
NS_ASSUME_NONNULL_END

