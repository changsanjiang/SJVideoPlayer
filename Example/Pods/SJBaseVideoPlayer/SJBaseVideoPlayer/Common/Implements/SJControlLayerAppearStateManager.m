//
//  SJControlLayerAppearStateManager.m
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2018/12/28.
//

#import "SJControlLayerAppearStateManager.h"
#import "SJTimerControl.h"

NS_ASSUME_NONNULL_BEGIN
static NSNotificationName const SJControlLayerAppearStateDidChangeNotification = @"SJControlLayerAppearStateDidChangeNotification";

@interface SJControlLayerAppearManagerObserver : NSObject<SJControlLayerAppearManagerObserver>
- (instancetype)initWithManager:(id<SJControlLayerAppearManager>)mgr;
@end

@implementation SJControlLayerAppearManagerObserver
@synthesize appearStateDidChangeExeBlock = _appearStateDidChangeExeBlock;
- (instancetype)initWithManager:(SJControlLayerAppearStateManager *)mgr {
    self = [super init];
    if ( !self )
        return nil;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appearStateDidChange:) name:SJControlLayerAppearStateDidChangeNotification object:mgr];
    
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)appearStateDidChange:(NSNotification *)note {
    SJControlLayerAppearStateManager *mgr = note.object;
    if ( _appearStateDidChangeExeBlock )
        _appearStateDidChangeExeBlock(mgr);
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

- (void)setIsAppeared:(BOOL)isAppeared {
    _isAppeared = isAppeared;
    [NSNotificationCenter.defaultCenter postNotificationName:SJControlLayerAppearStateDidChangeNotification object:self];
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

