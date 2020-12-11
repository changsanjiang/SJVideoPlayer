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
//#if __has_include(<Reachability/Reachability.h>)
//#import <Reachability/Reachability.h>
//#else
//#import "Reachability.h"
//#endif


#pragma mark - _Reachability

#import <SystemConfiguration/SystemConfiguration.h>


/**
 * Create NS_ENUM macro if it does not exist on the targeted version of iOS or OS X.
 *
 * @see http://nshipster.com/ns_enum-ns_options/
 **/
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

typedef NS_ENUM(NSInteger, NetworkStatus) {
    // Apple NetworkStatus Compatible Names.
    NotReachable = 0,
    ReachableViaWiFi = 2,
    ReachableViaWWAN = 1
};

@class _Reachability;

typedef void (^NetworkReachable) (_Reachability * reachability);
typedef void (^NetworkUnreachable) (_Reachability * reachability);


@interface _Reachability : NSObject

@property (nonatomic, copy) NetworkReachable    reachableBlock;
@property (nonatomic, copy) NetworkUnreachable  unreachableBlock;

@property (nonatomic, assign) BOOL reachableOnWWAN;


+ (_Reachability*)reachabilityWithHostname:(NSString*)hostname;
// This is identical to the function above, but is here to maintain
//compatibility with Apples original code. (see .m)
+ (_Reachability*)reachabilityWithHostName:(NSString*)hostname;
+ (_Reachability*)reachabilityForInternetConnection;
+ (_Reachability*)reachabilityWithAddress:(void *)hostAddress;
+ (_Reachability*)reachabilityForLocalWiFi;

- (_Reachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

-(BOOL)startNotifier;
-(void)stopNotifier;

-(BOOL)isReachable;
-(BOOL)isReachableViaWWAN;
-(BOOL)isReachableViaWiFi;

// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
-(BOOL)isConnectionRequired; // Identical DDG variant.
-(BOOL)connectionRequired; // Apple's routine.
// Dynamic, on demand connection?
-(BOOL)isConnectionOnDemand;
// Is user intervention required?
-(BOOL)isInterventionRequired;

-(NetworkStatus)currentReachabilityStatus;
-(SCNetworkReachabilityFlags)reachabilityFlags;
-(NSString*)currentReachabilityString;
-(NSString*)currentReachabilityFlags;

@end

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>


static NSString *const kReachabilityChangedNotification = @"_kReachabilityChangedNotification";


@interface _Reachability ()

@property (nonatomic, assign) SCNetworkReachabilityRef  reachabilityRef;
@property (nonatomic, strong) dispatch_queue_t          reachabilitySerialQueue;
@property (nonatomic, strong) id                        reachabilityObject;

-(void)reachabilityChanged:(SCNetworkReachabilityFlags)flags;
-(BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags;

@end


static NSString *reachabilityFlags(SCNetworkReachabilityFlags flags)
{
    return [NSString stringWithFormat:@"%c%c %c%c%c%c%c%c%c",
#if    TARGET_OS_IPHONE
            (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
#else
            'X',
#endif
            (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
            (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
            (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
            (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
            (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'];
}

// Start listening for reachability notifications on the current run loop
static void TMReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target)

    _Reachability *reachability = ((__bridge _Reachability*)info);

    // We probably don't need an autoreleasepool here, as GCD docs state each queue has its own autorelease pool,
    // but what the heck eh?
    @autoreleasepool
    {
        [reachability reachabilityChanged:flags];
    }
}


@implementation _Reachability

#pragma mark - Class Constructor Methods

+ (_Reachability*)reachabilityWithHostName:(NSString*)hostname
{
    return [_Reachability reachabilityWithHostname:hostname];
}

+ (_Reachability*)reachabilityWithHostname:(NSString*)hostname
{
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);
    if (ref)
    {
        id reachability = [[self alloc] initWithReachabilityRef:ref];

        return reachability;
    }
    
    return nil;
}

+ (_Reachability *)reachabilityWithAddress:(void *)hostAddress
{
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
    if (ref)
    {
        id reachability = [[self alloc] initWithReachabilityRef:ref];
        
        return reachability;
    }
    
    return nil;
}

+ (_Reachability *)reachabilityForInternetConnection
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress:&zeroAddress];
}

+ (_Reachability*)reachabilityForLocalWiFi
{
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len            = sizeof(localWifiAddress);
    localWifiAddress.sin_family         = AF_INET;
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr    = htonl(IN_LINKLOCALNETNUM);
    
    return [self reachabilityWithAddress:&localWifiAddress];
}


// Initialization methods

- (_Reachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref
{
    self = [super init];
    if (self != nil)
    {
        self.reachableOnWWAN = YES;
        self.reachabilityRef = ref;

        // We need to create a serial queue.
        // We allocate this once for the lifetime of the notifier.

        self.reachabilitySerialQueue = dispatch_queue_create("com.tonymillion.reachability", NULL);
    }
    
    return self;
}

-(void)dealloc
{
    [self stopNotifier];

    if(self.reachabilityRef)
    {
        CFRelease(self.reachabilityRef);
        self.reachabilityRef = nil;
    }

    self.reachableBlock          = nil;
    self.unreachableBlock        = nil;
    self.reachabilitySerialQueue = nil;
}

#pragma mark - Notifier Methods

// Notifier
// NOTE: This uses GCD to trigger the blocks - they *WILL NOT* be called on THE MAIN THREAD
// - In other words DO NOT DO ANY UI UPDATES IN THE BLOCKS.
//   INSTEAD USE dispatch_async(dispatch_get_main_queue(), ^{UISTUFF}) (or dispatch_sync if you want)

-(BOOL)startNotifier
{
    // allow start notifier to be called multiple times
    if(self.reachabilityObject && (self.reachabilityObject == self))
    {
        return YES;
    }


    SCNetworkReachabilityContext    context = { 0, NULL, NULL, NULL, NULL };
    context.info = (__bridge void *)self;

    if(SCNetworkReachabilitySetCallback(self.reachabilityRef, TMReachabilityCallback, &context))
    {
        // Set it as our reachability queue, which will retain the queue
        if(SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue))
        {
            // this should do a retain on ourself, so as long as we're in notifier mode we shouldn't disappear out from under ourselves
            // woah
            self.reachabilityObject = self;
            return YES;
        }
        else
        {
#ifdef DEBUG
            NSLog(@"SCNetworkReachabilitySetDispatchQueue() failed: %s", SCErrorString(SCError()));
#endif

            // UH OH - FAILURE - stop any callbacks!
            SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
        }
    }
    else
    {
#ifdef DEBUG
        NSLog(@"SCNetworkReachabilitySetCallback() failed: %s", SCErrorString(SCError()));
#endif
    }

    // if we get here we fail at the internet
    self.reachabilityObject = nil;
    return NO;
}

-(void)stopNotifier
{
    // First stop, any callbacks!
    SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
    
    // Unregister target from the GCD serial dispatch queue.
    SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, NULL);

    self.reachabilityObject = nil;
}

#pragma mark - reachability tests

// This is for the case where you flick the airplane mode;
// you end up getting something like this:
//Reachability: WR ct-----
//Reachability: -- -------
//Reachability: WR ct-----
//Reachability: -- -------
// We treat this as 4 UNREACHABLE triggers - really apple should do better than this

#define testcase (kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsTransientConnection)

-(BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags
{
    BOOL connectionUP = YES;
    
    if(!(flags & kSCNetworkReachabilityFlagsReachable))
        connectionUP = NO;
    
    if( (flags & testcase) == testcase )
        connectionUP = NO;
    
#if    TARGET_OS_IPHONE
    if(flags & kSCNetworkReachabilityFlagsIsWWAN)
    {
        // We're on 3G.
        if(!self.reachableOnWWAN)
        {
            // We don't want to connect when on 3G.
            connectionUP = NO;
        }
    }
#endif
    
    return connectionUP;
}

-(BOOL)isReachable
{
    SCNetworkReachabilityFlags flags;
    
    if(!SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
        return NO;
    
    return [self isReachableWithFlags:flags];
}

-(BOOL)isReachableViaWWAN
{
#if    TARGET_OS_IPHONE

    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        // Check we're REACHABLE
        if(flags & kSCNetworkReachabilityFlagsReachable)
        {
            // Now, check we're on WWAN
            if(flags & kSCNetworkReachabilityFlagsIsWWAN)
            {
                return YES;
            }
        }
    }
#endif
    
    return NO;
}

-(BOOL)isReachableViaWiFi
{
    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        // Check we're reachable
        if((flags & kSCNetworkReachabilityFlagsReachable))
        {
#if    TARGET_OS_IPHONE
            // Check we're NOT on WWAN
            if((flags & kSCNetworkReachabilityFlagsIsWWAN))
            {
                return NO;
            }
#endif
            return YES;
        }
    }
    
    return NO;
}


// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
-(BOOL)isConnectionRequired
{
    return [self connectionRequired];
}

-(BOOL)connectionRequired
{
    SCNetworkReachabilityFlags flags;
    
    if(SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    
    return NO;
}

// Dynamic, on demand connection?
-(BOOL)isConnectionOnDemand
{
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
                (flags & (kSCNetworkReachabilityFlagsConnectionOnTraffic | kSCNetworkReachabilityFlagsConnectionOnDemand)));
    }
    
    return NO;
}

// Is user intervention required?
-(BOOL)isInterventionRequired
{
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
                (flags & kSCNetworkReachabilityFlagsInterventionRequired));
    }
    
    return NO;
}


#pragma mark - reachability status stuff

-(NetworkStatus)currentReachabilityStatus
{
    if([self isReachable])
    {
        if([self isReachableViaWiFi])
            return ReachableViaWiFi;
        
#if    TARGET_OS_IPHONE
        return ReachableViaWWAN;
#endif
    }
    
    return NotReachable;
}

-(SCNetworkReachabilityFlags)reachabilityFlags
{
    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        return flags;
    }
    
    return 0;
}

-(NSString*)currentReachabilityString
{
    NetworkStatus temp = [self currentReachabilityStatus];
    
    if(temp == ReachableViaWWAN)
    {
        // Updated for the fact that we have CDMA phones now!
        return NSLocalizedString(@"Cellular", @"");
    }
    if (temp == ReachableViaWiFi)
    {
        return NSLocalizedString(@"WiFi", @"");
    }
    
    return NSLocalizedString(@"No Connection", @"");
}

-(NSString*)currentReachabilityFlags
{
    return reachabilityFlags([self reachabilityFlags]);
}

#pragma mark - Callback function calls this method

-(void)reachabilityChanged:(SCNetworkReachabilityFlags)flags
{
    if([self isReachableWithFlags:flags])
    {
        if(self.reachableBlock)
        {
            self.reachableBlock(self);
        }
    }
    else
    {
        if(self.unreachableBlock)
        {
            self.unreachableBlock(self);
        }
    }
    
    // this makes sure the change notification happens on the MAIN THREAD
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification
                                                            object:self];
    });
}

#pragma mark - Debug Description

- (NSString *) description
{
    NSString *description = [NSString stringWithFormat:@"<%@: %#x (%@)>",
                             NSStringFromClass([self class]), (unsigned int) self, [self currentReachabilityFlags]];
    return description;
}

@end


#pragma mark - <#mark#>

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
        self.iBytes = 0;
    }
}

- (void)stop{
    if ( [_timer isValid] ) {
        [_timer invalidate];
        _timer = nil;
        self.iBytes = 0;
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
            if ( speed < 0 ) return;
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

static _Reachability *_reachability;
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
        _reachability = [_Reachability reachabilityForInternetConnection];
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
