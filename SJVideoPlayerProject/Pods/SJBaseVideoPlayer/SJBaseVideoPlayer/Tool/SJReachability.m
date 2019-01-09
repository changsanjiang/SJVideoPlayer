//
//  SJReachabilityObserver.m
//  Project
//
//  Created by BlueDancer on 2018/12/28.
//  Copyright © 2018 SanJiang. All rights reserved.
//

#import "SJReachability.h"
#if __has_include(<Reachability/Reachability.h>)
#import <Reachability/Reachability.h>
#else
#import "Reachability.h"
#endif

#if __has_include(<SJObserverHelper/NSObject+SJObserverHelper.h>)
#import <SJObserverHelper/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJReachabilityObserver : NSObject<SJReachabilityObserver>
- (instancetype)initWithReachability:(id<SJReachability>)reachability;
@end

@implementation SJReachabilityObserver
@synthesize networkStatusDidChangeExeBlock = _networkStatusDidChangeExeBlock;
- (instancetype)initWithReachability:(id<SJReachability>)reachability {
    self = [super init];
    if ( !self )
        return nil;
    [(id)reachability sj_addObserver:self forKeyPath:@"networkStatus"];
    return self;
}

- (void)observeValueForKeyPath:(NSString *_Nullable)keyPath ofObject:(id _Nullable)object change:(NSDictionary<NSKeyValueChangeKey,id> *_Nullable)change context:(void *_Nullable)context {
    if ( [change[NSKeyValueChangeOldKey] integerValue] == [change[NSKeyValueChangeNewKey] integerValue] )
        return;
    
    id<SJReachability> mgr = object;
    if ( _networkStatusDidChangeExeBlock )
        _networkStatusDidChangeExeBlock(mgr, mgr.networkStatus);
}
@end

@interface SJReachability ()
@property (nonatomic) SJNetworkStatus networkStatus;
@end

@implementation SJReachability {
    id _notifyToken;
}

+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

static Reachability *_reachability;
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _reachability = [Reachability reachabilityForInternetConnection];
        [_reachability startNotifier];
    });

    __weak typeof(self) _self = self;
    _notifyToken = [NSNotificationCenter.defaultCenter addObserverForName:kReachabilityChangedNotification object:_reachability queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _update];
    }];
    
    [self _update];
    return self;
}

- (id<SJReachabilityObserver>)getObserver {
    return [[SJReachabilityObserver alloc] initWithReachability:self];
}

- (void)_update {
    self.networkStatus = (NSInteger)[_reachability currentReachabilityStatus];
}

- (void)dealloc {
    if ( _notifyToken ) [NSNotificationCenter.defaultCenter removeObserver:_notifyToken];
}
@end
NS_ASSUME_NONNULL_END
