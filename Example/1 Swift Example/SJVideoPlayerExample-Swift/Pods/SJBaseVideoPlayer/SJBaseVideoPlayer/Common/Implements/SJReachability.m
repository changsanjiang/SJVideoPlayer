//
//  SJReachabilityObserver.m
//  Project
//
//  Created by 畅三江 on 2018/12/28.
//  Copyright © 2018 changsanjiang. All rights reserved.
//

#import "SJReachability.h"
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "NSTimer+SJAssetAdd.h"
#if __has_include(<Reachability/Reachability.h>)
#import <Reachability/Reachability.h>
#else
#import "Reachability.h"
#endif

NS_ASSUME_NONNULL_BEGIN
static NSNotificationName const GSDownloadNetworkSpeedNotificationKey = @"__GSDownloadNetworkSpeedNotificationKey";
static NSNotificationName const GSUploadNetworkSpeedNotificationKey = @"__GSUploadNetworkSpeedNotificationKey";

static NSNotificationName const SJReachabilityNetworkStatusDidChangeNotification = @"SJReachabilityNetworkStatusDidChange";

///
/// Thanks @18138870200
/// https://github.com/18138870200/SGNetworkSpeed.git
///
@interface __DJNetworkSpeedObserver : NSObject {
    // refresh timer
    NSTimer *_Nullable _timer;
     
    @public
    uint32_t _speed;
}

- (NSString *)speedString;
@end

@interface __DJNetworkSpeedObserver ()
// 总网速
@property uint32_t iBytes;
@end

@implementation __DJNetworkSpeedObserver
- (void)dealloc {
    [self stop];
}

- (void)start {
    if ( _timer == nil ) {
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

- (NSString*)speedString {
    // B
    if ( _speed < 1024 )
        return @"0KB";
    // KB
    else if (_speed >= 1024 && _speed < 1024 * 1024)
        return [NSString stringWithFormat:@"%.fKB/s", (double)_speed / 1024];
    // MB
    else if (_speed >= 1024 * 1024 && _speed < 1024 * 1024 * 1024)
        return [NSString stringWithFormat:@"%.1fMB/s", (double)_speed / (1024 * 1024)];
    // GB
    else
        return [NSString stringWithFormat:@"%.1fGB/s", (double)_speed / (1024 * 1024 * 1024)];
}

- (void)checkNetworkSpeed{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        struct ifaddrs *ifa_list = 0, *ifa;
        if ( getifaddrs(&ifa_list) == -1 )
            return;
        uint32_t iBytes = 0;
        
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
            }
        }
        freeifaddrs(ifa_list);
        
        uint32_t __iBytes = self.iBytes;
        if ( __iBytes != 0 ) {
            
            uint32_t speed = iBytes - __iBytes;
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_speed = speed;
                [[NSNotificationCenter defaultCenter] postNotificationName:GSDownloadNetworkSpeedNotificationKey object:self];
            });
        }
        self.iBytes = iBytes;
    });
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
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (NSString *)networkSpeedStr {
    return [_networkSpeedObserver speedString];
}

- (void)_initializeReachability {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _reachability = [Reachability reachabilityForInternetConnection];
        [_reachability startNotifier];
    });
    
    [self _updateNetworkStatus];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(reachabilityChanged) name:kReachabilityChangedNotification object:_reachability];
}

- (void)reachabilityChanged {
    [self _updateNetworkStatus];
}

- (void)_updateNetworkStatus {
    self.networkStatus = (NSInteger)[_reachability currentReachabilityStatus];
}

- (void)_initializeSpeedObserver {
    _networkSpeedObserver = [[__DJNetworkSpeedObserver alloc] init];
}

- (void)startRefresh {
    [_networkSpeedObserver start];
}

- (void)stopRefresh {
    [_networkSpeedObserver stop];
}

- (void)setNetworkStatus:(SJNetworkStatus)networkStatus {
    _networkStatus = networkStatus;
    [NSNotificationCenter.defaultCenter postNotificationName:SJReachabilityNetworkStatusDidChangeNotification object:self];
}
@end

@implementation SJReachabilityObserver {
    __weak SJReachability *_reachability;
}
@synthesize networkStatusDidChangeExeBlock = _networkStatusDidChangeExeBlock;
@synthesize networkSpeedDidChangeExeBlock = _networkSpeedDidChangeExeBlock;
- (instancetype)initWithReachability:(SJReachability *)reachability {
    self = [super init];
    if ( !self ) return nil;
    _reachability = reachability;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(networkStatusDidChange:) name:SJReachabilityNetworkStatusDidChangeNotification object:reachability];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(networkSpeedDidChange:) name:GSDownloadNetworkSpeedNotificationKey object:reachability.networkSpeedObserver];
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)networkStatusDidChange:(NSNotification *)note {
    id<SJReachability> mgr = note.object;
    if ( _networkStatusDidChangeExeBlock )
        _networkStatusDidChangeExeBlock(mgr);
}
- (void)networkSpeedDidChange:(NSNotification *)note {
    if ( _networkSpeedDidChangeExeBlock ) _networkSpeedDidChangeExeBlock(_reachability);
}
@end
NS_ASSUME_NONNULL_END
