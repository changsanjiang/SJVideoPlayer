//
//  MCSResponse.m
//  SJMediaCacheServer
//
//  Created by BlueDancer on 2020/11/18.
//

#import "MCSResponse.h"

@implementation MCSResponse
- (instancetype)initWithTotalLength:(NSUInteger)totalLength {
    return [self initWithTotalLength:totalLength range:NSMakeRange(0, 0)];
}

- (instancetype)initWithTotalLength:(NSUInteger)totalLength range:(NSRange)range {
    self = [super init];
    if ( self ) {
        _totalLength = totalLength;
        _range = range;
    }
    return self;
}
@end
