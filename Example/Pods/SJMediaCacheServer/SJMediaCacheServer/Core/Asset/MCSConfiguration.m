//
//  MCSConfiguration.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/7/6.
//

#import "MCSConfiguration.h"

@interface MCSConfiguration () {
    dispatch_semaphore_t _lock;
    NSMutableDictionary <NSNumber *, NSMutableDictionary<NSString *, NSString *> *> *_map;
}
@end

@implementation MCSConfiguration
- (instancetype)init {
    self = [super init];
    if ( self ) {
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)setValue:(nullable NSString *)value forHTTPAdditionalHeaderField:(NSString *)HTTPHeaderField ofType:(MCSDataType)type {
    BOOL fallThrough = NO;
    switch ( (MCSDataType)(type & MCSDataTypeHLSMask) ) {
        case MCSDataTypeHLSMask:
        case MCSDataTypeFILEMask:
        case MCSDataTypeFILE:
            break;
        case MCSDataTypeHLS: {
            [self _setValue:value forHTTPAdditionalHeaderField:HTTPHeaderField ofType:MCSDataTypeHLS fallThrough:fallThrough];
            fallThrough = YES;
        }
        case MCSDataTypeHLSPlaylist: {
            [self _setValue:value forHTTPAdditionalHeaderField:HTTPHeaderField ofType:MCSDataTypeHLSPlaylist fallThrough:fallThrough];
            if ( !fallThrough ) break;
        }
        case MCSDataTypeHLSAESKey: {
            [self _setValue:value forHTTPAdditionalHeaderField:HTTPHeaderField ofType:MCSDataTypeHLSAESKey fallThrough:fallThrough];
            if ( !fallThrough ) break;
        }
        case MCSDataTypeHLSTs: {
            [self _setValue:value forHTTPAdditionalHeaderField:HTTPHeaderField ofType:MCSDataTypeHLSTs fallThrough:fallThrough];
            if ( !fallThrough ) break;
        }
    }
    
    switch ( (MCSDataType)(type & MCSDataTypeFILEMask) ) {
        case MCSDataTypeHLSMask:
        case MCSDataTypeHLSPlaylist:
        case MCSDataTypeHLSAESKey:
        case MCSDataTypeHLSTs:
        case MCSDataTypeHLS:
        case MCSDataTypeFILEMask:
            break;
        case MCSDataTypeFILE: {
            [self _setValue:value forHTTPAdditionalHeaderField:HTTPHeaderField ofType:MCSDataTypeFILE fallThrough:fallThrough];
            break;
        }
    }
}

- (nullable NSDictionary<NSString *, NSString *> *)HTTPAdditionalHeadersForDataRequestsOfType:(MCSDataType)type {
    NSDictionary<NSString *, NSString *> *headers = nil;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    headers = _map[@(type)];
    dispatch_semaphore_signal(_lock);
    return headers;
}

- (void)_setValue:(nullable NSString *)value forHTTPAdditionalHeaderField:(NSString *)HTTPHeaderField ofType:(MCSDataType)type fallThrough:(BOOL)fallThrough {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ( _map == nil ) _map = NSMutableDictionary.dictionary;

    NSNumber *key = @(type);
    if ( _map[key][HTTPHeaderField] == nil || !fallThrough ) {
        if ( _map[key] == nil ) _map[key] = NSMutableDictionary.dictionary;
        _map[key][HTTPHeaderField] = value;
    }
    dispatch_semaphore_signal(_lock);
}

@end
