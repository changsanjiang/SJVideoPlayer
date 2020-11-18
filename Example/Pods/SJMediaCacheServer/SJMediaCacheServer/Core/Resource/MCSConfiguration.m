//
//  MCSConfiguration.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/7/6.
//

#import "MCSConfiguration.h"

@interface MCSConfiguration () {
    dispatch_queue_t _queue;
    NSMutableDictionary <NSNumber *, NSMutableDictionary<NSString *, NSString *> *> *_map;
}
@end

@implementation MCSConfiguration
- (instancetype)init {
    self = [super init];
    if ( self ) {
        _queue = dispatch_get_global_queue(0, 0);
    }
    return self;
}

- (void)setValue:(nullable NSString *)value forHTTPAdditionalHeaderField:(NSString *)HTTPHeaderField ofType:(MCSDataType)type {
    dispatch_barrier_sync(_queue, ^{
        if ( self->_map == nil ) self->_map = NSMutableDictionary.dictionary;
        
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
    });
}

- (nullable NSDictionary<NSString *, NSString *> *)HTTPAdditionalHeadersForDataRequestsOfType:(MCSDataType)type {
    __block NSDictionary<NSString *, NSString *> *headers = nil;
    dispatch_sync(_queue, ^{
        headers = _map[@(type)];
    });
    return headers;
}

- (void)_setValue:(nullable NSString *)value forHTTPAdditionalHeaderField:(NSString *)HTTPHeaderField ofType:(MCSDataType)type fallThrough:(BOOL)fallThrough {
    NSNumber *key = @(type);
    if ( fallThrough && _map[key][HTTPHeaderField] != nil )
        return;
    
    if ( _map[key] == nil )
        _map[key] = NSMutableDictionary.dictionary;
    
    _map[key][HTTPHeaderField] = value;
}

@end
