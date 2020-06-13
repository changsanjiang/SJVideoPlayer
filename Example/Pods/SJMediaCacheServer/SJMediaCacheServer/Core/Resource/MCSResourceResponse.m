//
//  MCSResourceResponse.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/4.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSResourceResponse.h"
#import "MCSUtils.h"

@implementation MCSResourceResponse
- (instancetype)initWithResponse:(NSHTTPURLResponse *)response {
    MCSResponseContentRange contentRange = MCSGetResponseContentRange(response);
    return [self initWithServer:MCSGetResponseServer(response) contentType:MCSGetResponseContentType(response) totalLength:contentRange.totalLength contentRange:MCSGetResponseNSRange(contentRange)];
}

- (instancetype)initWithServer:(NSString *)server contentType:(NSString *)contentType totalLength:(NSUInteger)totalLength {
    self = [super init];
    if ( self ) {
        _responseHeaders = @{
            @"Server" : server ?: @"localhost",
            @"Content-Type" : contentType ?: @"",
            @"Accept-Ranges" : @"bytes",
            @"Connection" : @"keep-alive",
            @"Content-Length" : [NSString stringWithFormat:@"%lu", (unsigned long)totalLength],
        };
        
        _server = server.copy;
        _contentType = contentType.copy;
        _totalLength = totalLength;    }
    return self;

}

- (instancetype)initWithServer:(NSString *)server contentType:(NSString *)contentType totalLength:(NSUInteger)totalLength contentRange:(NSRange)contentRange {
    self = [super init];
    if ( self ) {
        _responseHeaders = @{
            @"Server" : server ?: @"localhost",
            @"Content-Type" : contentType ?: @"",
            @"Accept-Ranges" : @"bytes",
            @"Connection" : @"keep-alive",
            
            @"Content-Length" : [NSString stringWithFormat:@"%lu", (unsigned long)contentRange.length],
            @"Content-Range" : [NSString stringWithFormat:@"bytes %lu-%lu/%lu", (unsigned long)contentRange.location, (unsigned long)NSMaxRange(contentRange) - 1, (unsigned long)totalLength],
        };

        _server = server.copy;
        _contentType = contentType.copy;
        _totalLength = totalLength;
        _contentRange = contentRange;
        
//  https://tools.ietf.org/html/rfc7233#section-4.1
//
//        2.3.  Accept-Ranges
//
//        The "Accept-Ranges" header field allows a server to indicate that it
//        supports range requests for the target resource.
//
//          Accept-Ranges     = acceptable-ranges
//          acceptable-ranges = 1#range-unit / "none"
//
//        An origin server that supports byte-range requests for a given target
//        resource MAY send
//
//          Accept-Ranges: bytes
//
//        to indicate what range units are supported.  A client MAY generate
//        range requests without having received this header field for the
//        resource involved.  Range units are defined in Section 2.
//
//        A server that does not support any kind of range request for the
//        target resource MAY send
//
//          Accept-Ranges: none
//
//        to advise the client not to attempt a range request.
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"MCSResourceResponse:<%p> { responseHeaders: %@ };", self, _responseHeaders];
}
@end
