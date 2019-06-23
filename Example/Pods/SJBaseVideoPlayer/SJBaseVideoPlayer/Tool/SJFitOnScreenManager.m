//
//  SJFitOnScreenManager.m
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2018/12/31.
//

#import "SJFitOnScreenManager.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJFitOnScreenManagerObserver : NSObject<SJFitOnScreenManagerObserver>
- (instancetype)initWithManager:(id<SJFitOnScreenManager>)manager;
@end

@implementation SJFitOnScreenManagerObserver
@synthesize fitOnScreenWillBeginExeBlock = _fitOnScreenWillBeginExeBlock;
@synthesize fitOnScreenDidEndExeBlock = _fitOnScreenDidEndExeBlock;

- (instancetype)initWithManager:(id<SJFitOnScreenManager>)manager {
    self = [super init];
    if ( !self )
        return nil;
    [(id)manager sj_addObserver:self forKeyPath:@"state"];
    return self;
}

- (void)observeValueForKeyPath:(NSString *_Nullable)keyPath ofObject:(id _Nullable)object change:(NSDictionary<NSKeyValueChangeKey,id> *_Nullable)change context:(void *_Nullable)context {
    if ( [change[NSKeyValueChangeOldKey] integerValue] == [change[NSKeyValueChangeNewKey] integerValue] )
        return;
    
    id<SJFitOnScreenManager> mgr = object;
    if ( mgr.state == SJFitOnScreenStateStart ) {
        if ( _fitOnScreenWillBeginExeBlock )
            _fitOnScreenWillBeginExeBlock(mgr);
    }
    else {
        if ( _fitOnScreenDidEndExeBlock )
            _fitOnScreenDidEndExeBlock(mgr);
    }
}
@end


@interface SJFitOnScreenManager ()
@property (nonatomic) SJFitOnScreenState state;
@property (nonatomic) BOOL innerFitOnScreen;
@property (nonatomic, strong, readonly) UIView *target;
@property (nonatomic, strong, readonly) UIView *superview;
@end

@implementation SJFitOnScreenManager
@synthesize duration = _duration;

- (instancetype)initWithTarget:(__strong UIView *)target targetSuperview:(__strong UIView *)superview {
    self = [super init];
    if ( !self )
        return nil;
    _target = target;
    _superview = superview;
    _duration = 0.4;
    _state = SJFitOnScreenStateEnd;
    return self;
}

- (id<SJFitOnScreenManagerObserver>)getObserver {
    return [[SJFitOnScreenManagerObserver alloc] initWithManager:self];
}

- (BOOL)isFitOnScreen {
    return _innerFitOnScreen;
}
- (void)setFitOnScreen:(BOOL)fitOnScreen {
    [self setFitOnScreen:fitOnScreen animated:YES];
}
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated {
    [self setFitOnScreen:fitOnScreen animated:animated completionHandler:nil];
}
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated completionHandler:(nullable void (^)(id<SJFitOnScreenManager>))completionHandler {
    if ( fitOnScreen == self.isFitOnScreen ) { if ( completionHandler ) completionHandler(self); return; }
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.innerFitOnScreen = fitOnScreen;
        self.state = SJFitOnScreenStateStart;
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if ( !window ) return;
        CGRect origin = [window convertRect:self.superview.bounds fromView:self.superview];
        if ( fitOnScreen ) {
            self.target.frame = origin;
            [window addSubview:self.target];
        }
        
        [UIView animateWithDuration:animated?self.duration:0 animations:^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( fitOnScreen ) {
                self.target.frame = window.bounds;
            }
            else {
                self.target.frame = origin;
            }
            [self.target layoutIfNeeded];
        } completion:^(BOOL finished) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( !fitOnScreen ) {
                [self.superview addSubview:self.target];
                self.target.frame = self.superview.bounds;
            }
            
            self.state = SJFitOnScreenStateEnd;

            if ( completionHandler )
                completionHandler(self);
        }];
    });
}

- (void)setInnerFitOnScreen:(BOOL)innerFitOnScreen {
    if ( innerFitOnScreen == _innerFitOnScreen )
        return;
    _innerFitOnScreen = innerFitOnScreen;
}

- (void)setState:(SJFitOnScreenState)state {
    if ( state == _state )
        return;
    _state = state;
}
@end
NS_ASSUME_NONNULL_END
