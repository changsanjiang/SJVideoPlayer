//
//  MCSConfiguration.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/7/6.
//

#import "MCSConfiguration.h"

@interface MCSConfiguration ()<NSLocking> {
    dispatch_semaphore_t _semaphore;
    NSMutableDictionary <NSNumber *, NSMutableDictionary<NSString *, NSString *> *> *_map;
}
@end

@implementation MCSConfiguration
- (instancetype)init {
    self = [super init];
    if ( self ) {
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)setValue:(nullable NSString *)value forHTTPAdditionalHeaderField:(NSString *)HTTPHeaderField ofType:(MCSDataType)type {
    [self lock];
    if ( _map == nil ) _map = NSMutableDictionary.dictionary;
    
    BOOL fallThrough = NO;
    switch ( type & MCSDataTypeHLSMask ) {
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
        default: break;
    }
    
    switch ( type & MCSDataTypeVODMask ) {
        case MCSDataTypeVOD: {
            [self _setValue:value forHTTPAdditionalHeaderField:HTTPHeaderField ofType:MCSDataTypeVOD fallThrough:fallThrough];
            break;
        }
        default: break;
    }
    
    [self unlock];
}

- (nullable NSDictionary<NSString *, NSString *> *)HTTPAdditionalHeadersForDataRequestsOfType:(MCSDataType)type {
    [self lock];
    @try {
        return _map[@(type)];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)_setValue:(nullable NSString *)value forHTTPAdditionalHeaderField:(NSString *)HTTPHeaderField ofType:(MCSDataType)type fallThrough:(BOOL)fallThrough {
    NSNumber *key = @(type);
    if ( fallThrough && _map[key][HTTPHeaderField] != nil )
        return;
    
    if ( _map[key] == nil )
        _map[key] = NSMutableDictionary.dictionary;
    
    _map[key][HTTPHeaderField] = value;
}

#pragma mark -

- (void)lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_semaphore);
}
@end
