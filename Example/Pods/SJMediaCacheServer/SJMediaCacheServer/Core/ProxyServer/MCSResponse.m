//
//  MCSResponse.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/18.
//

#import "MCSResponse.h"

@implementation MCSResponse
- (instancetype)initWithTotalLength:(NSUInteger)totalLength {
    return [self initWithTotalLength:totalLength range:NSMakeRange(0, totalLength)];
}

- (instancetype)initWithTotalLength:(NSUInteger)totalLength contentType:(nullable NSString *)contentType {
    return [self initWithTotalLength:totalLength range:NSMakeRange(0, totalLength) contentType:contentType];
}

- (instancetype)initWithTotalLength:(NSUInteger)totalLength range:(NSRange)range {
    return [self initWithTotalLength:totalLength range:range contentType:nil];
}

- (instancetype)initWithTotalLength:(NSUInteger)totalLength range:(NSRange)range contentType:(nullable NSString *)contentType {
    self = [super init];
    if ( self ) {
        _totalLength = totalLength;
        _range = range;
        _contentType = contentType ?: @"application/octet-stream";
    }
    return self;
}

@synthesize contentType = _contentType;
- (NSString *)contentType {
    return _contentType ?: @"application/octet-stream";
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { totalLength: %lu, range: %@, contentType: %@ };\n", NSStringFromClass(self.class), self, (unsigned long)_totalLength, NSStringFromRange(_range), _contentType];
}
@end
