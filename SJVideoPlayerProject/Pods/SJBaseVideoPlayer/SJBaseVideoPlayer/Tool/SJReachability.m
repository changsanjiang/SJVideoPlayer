//
//  SJReachabilityObserver.m
//  Project
//
//  Created by BlueDancer on 2018/12/28.
//  Copyright © 2018 SanJiang. All rights reserved.
//

#import "SJReachability.h"
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "SJVideoPlayerRegistrar.h"

#import "NSTimer+SJAssetAdd.h"
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
static NSNotificationName const GSDownloadNetworkSpeedNotificationKey = @"__GSDownloadNetworkSpeedNotificationKey";
static NSNotificationName const GSUploadNetworkSpeedNotificationKey = @"__GSUploadNetworkSpeedNotificationKey";

///
/// Thanks @18138870200
/// https://github.com/18138870200/SGNetworkSpeed.git
///
@interface __DJNetworkSpeedObserver : NSObject {
    // 总网速
    uint32_t _iBytes;
    uint32_t _oBytes;
    uint32_t _allFlow;
    
    // wifi网速
    uint32_t _wifiIBytes;
    uint32_t _wifiOBytes;
    uint32_t _wifiFlow;
    
    // 3G网速
    uint32_t _wwanIBytes;
    uint32_t _wwanOBytes;
    uint32_t _wwanFlow;
    
    // refresh timer
    NSTimer *_Nullable _timer;
    
    SJVideoPlayerRegistrar *_registrar;
    @public
    NSString *_networkSpeedStr;
    NSString *_updloadSpeedStr;
}
@end

@implementation __DJNetworkSpeedObserver
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _networkSpeedStr = @"0KB/s";
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_registrar = [SJVideoPlayerRegistrar new];
        __weak typeof(self) _self = self;
        self->_registrar.willEnterForeground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self start];
        };
        self->_registrar.didEnterBackground = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self stop];
        };
    });
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)start {
    if ( !_timer ) {
        __weak typeof(self) _self = self;
        _timer = [NSTimer assetAdd_timerWithTimeInterval:1 block:^(NSTimer *timer) {
            __strong typeof(_self) self = _self;
            if ( !self ) {
                [timer invalidate];
                return;
            }
            [self checkNetworkSpeed];
        } repeats:YES];
        [_timer assetAdd_fire];
        [NSRunLoop.mainRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stop{
    if ( [_timer isValid] ) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (NSString*)stringWithbytes:(int)bytes{
    // B
    if ( bytes < 1024 )
        return @"0KB";
    // KB
    else if (bytes >= 1024 && bytes < 1024 * 1024)
        return [NSString stringWithFormat:@"%.fKB", (double)bytes / 1024];
    // MB
    else if (bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024)
        return [NSString stringWithFormat:@"%.1fMB", (double)bytes / (1024 * 1024)];
    // GB
    else
        return [NSString stringWithFormat:@"%.1fGB", (double)bytes / (1024 * 1024 * 1024)];
}

- (void)checkNetworkSpeed{
    struct ifaddrs *ifa_list = 0, *ifa;
    if ( getifaddrs(&ifa_list) == -1 )
        return;
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    uint32_t allFlow = 0;
    uint32_t wifiIBytes = 0;
    uint32_t wifiOBytes = 0;
    uint32_t wifiFlow = 0;
    uint32_t wwanIBytes = 0;
    uint32_t wwanOBytes = 0;
    uint32_t wwanFlow = 0;
    for ( ifa = ifa_list ; ifa ; ifa = ifa->ifa_next ) {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        if (ifa->ifa_data == 0)
            continue;
        // network
        if (strncmp(ifa->ifa_name, "lo", 2)) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
            allFlow = iBytes + oBytes;
        }
        //wifi
        if (!strcmp(ifa->ifa_name, "en0")) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            wifiIBytes += if_data->ifi_ibytes;
            wifiOBytes += if_data->ifi_obytes;
            wifiFlow = wifiIBytes + wifiOBytes;
        }
        
        //3G or gprs
        if (!strcmp(ifa->ifa_name, "pdp_ip0")) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            wwanIBytes += if_data->ifi_ibytes;
            wwanOBytes += if_data->ifi_obytes;
            wwanFlow = wwanIBytes + wwanOBytes;
        }
    }
    freeifaddrs(ifa_list);
    
    if ( _iBytes != 0 ) {
        _networkSpeedStr = [[self stringWithbytes:iBytes - _iBytes] stringByAppendingString:@"/s"];
        [[NSNotificationCenter defaultCenter] postNotificationName:GSDownloadNetworkSpeedNotificationKey object:self];
    }
    
    _iBytes = iBytes;
    if ( _oBytes != 0 ) {
        _updloadSpeedStr = [[self stringWithbytes:oBytes - _oBytes] stringByAppendingString:@"/s"];
        [[NSNotificationCenter defaultCenter] postNotificationName:GSUploadNetworkSpeedNotificationKey object:self];
    }
    _oBytes = oBytes;
}
@end

@interface SJReachabilityObserver : NSObject<SJReachabilityObserver>
- (instancetype)initWithReachability:(SJReachability *)reachability;
@end

@interface SJReachability ()
@property (nonatomic) SJNetworkStatus networkStatus;
@property (nonatomic, strong, readonly) __DJNetworkSpeedObserver *networkSpeedObserver;
@end

@implementation SJReachability
+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (id<SJReachabilityObserver>)getObserver {
    return [[SJReachabilityObserver alloc] initWithReachability:self];
}

static Reachability *_reachability;
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self _initializeReachability];
    [self _initializeSpeedObserver];
    [self _startOrStopSpeedObserver];
    return self;
}

- (NSString *)networkSpeedStr {
    return _networkSpeedObserver->_networkSpeedStr;
}

- (void)_initializeReachability {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _reachability = [Reachability reachabilityForInternetConnection];
        [_reachability startNotifier];
    });
    
    [self _updateNetworkStatus];
    [self sj_observeWithNotification:kReachabilityChangedNotification target:_reachability usingBlock:^(SJReachability *self, NSNotification * _Nonnull note) {
        [self _updateNetworkStatus];
        [self _startOrStopSpeedObserver];
    }];
}

- (void)_updateNetworkStatus {
    self.networkStatus = (NSInteger)[_reachability currentReachabilityStatus];
}

- (void)_startOrStopSpeedObserver {
    if ( _networkStatus == SJNetworkStatus_NotReachable ) {
        [_networkSpeedObserver stop];
    }
    else {
        [_networkSpeedObserver start];
    }
}

- (void)_initializeSpeedObserver {
    _networkSpeedObserver = [[__DJNetworkSpeedObserver alloc] init];
}
@end

@implementation SJReachabilityObserver
@synthesize networkStatusDidChangeExeBlock = _networkStatusDidChangeExeBlock;
@synthesize networkSpeedDidChangeExeBlock = _networkSpeedDidChangeExeBlock;
- (instancetype)initWithReachability:(SJReachability *)reachability {
    self = [super init];
    if ( !self ) return nil;
    [(id)reachability sj_addObserver:self forKeyPath:@"networkStatus"];
    __weak typeof(reachability) _reachability = reachability;
    [self sj_observeWithNotification:GSDownloadNetworkSpeedNotificationKey target:reachability.networkSpeedObserver usingBlock:^(SJReachabilityObserver *self, NSNotification * _Nonnull note) {
        if ( self.networkSpeedDidChangeExeBlock ) self.networkSpeedDidChangeExeBlock(_reachability, _reachability.networkSpeedStr);
    }];
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
NS_ASSUME_NONNULL_END
