//
//  MCSProxyTask.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSProxyTask.h"
#import "MCSAssetManager.h"
#import "MCSUtils.h"
#import "MCSLogger.h"
#import "NSURLRequest+MCS.h"
#import "MCSURLRecognizer.h"

@interface MCSProxyTask ()<MCSAssetReaderDelegate>
@property (nonatomic, weak) id<MCSProxyTaskDelegate> delegate;
@property (nonatomic, strong) NSURLRequest * request;
@property (nonatomic, strong) id<MCSAsset> asset;
@property (nonatomic, strong) id<MCSAssetReader> reader;
#ifdef DEBUG
@property (nonatomic) uint64_t startTime;
#endif
@end

@implementation MCSProxyTask
- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id<MCSProxyTaskDelegate>)delegate {
    NSParameterAssert(request.URL.absoluteString.length != 0);
    
    self = [super init];
    if ( self ) {
#ifdef DEBUG
        MCSProxyTaskDebugLog(@"%@: <%p>.init { URL: %@, proxyURL: %@, headers: %@ };\n", NSStringFromClass(self.class), self, [MCSURLRecognizer.shared URLWithProxyURL:request.URL], request.URL, request.allHTTPHeaderFields);
#endif
        
        _request = request;
        _delegate = delegate;
    }
    return self;
}

- (void)prepare {
#ifdef DEBUG
    MCSProxyTaskDebugLog(@"%@: <%p>.prepare;\n", NSStringFromClass(self.class), self);
    _startTime = MCSStartTime();
#endif

    _reader = [MCSAssetManager.shared readerWithRequest:_request networkTaskPriority:1.0 delegate:self];
    @autoreleasepool {
        [_reader prepare];
    }
}
 
- (nullable NSData *)readDataOfLength:(NSUInteger)length {
    NSData *data = [_reader readDataOfLength:length];
#ifdef DEBUG
    if ( data.length != 0 ) {
        MCSProxyTaskDebugLog(@"%@: <%p>.read { length: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)data.length);
        if ( _reader.isReadingEndOfData )
            MCSProxyTaskDebugLog(@"%@: <%p>.done { after (%lf) seconds };\n", NSStringFromClass(self.class), self, MCSEndTime(_startTime));
    }
#endif
    return data;
}

- (NSUInteger)offset {
    return _reader.offset;
}

- (id<MCSResponse>)response {
    return _reader.response;
}

- (BOOL)isPrepared {
    return _reader.isPrepared;
}

- (BOOL)isDone {
    return _reader.isReadingEndOfData;
}

- (void)close {
#ifdef DEBUG
    MCSProxyTaskDebugLog(@"%@: <%p>.close { after (%lf) seconds };\n\n", NSStringFromClass(self.class), self, MCSEndTime(_startTime));
#endif
    [_reader close];
}

#pragma mark -

- (void)reader:(id<MCSAssetReader>)reader prepareDidFinish:(id<MCSResponse>)response {
    if ( !reader.isClosed ) [_delegate taskPrepareDidFinish:self];
}

- (void)reader:(id<MCSAssetReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    if ( !reader.isClosed ) [_delegate taskHasAvailableData:self];
}

- (void)reader:(id<MCSAssetReader>)reader anErrorOccurred:(NSError *)error {
#ifdef DEBUG
    MCSProxyTaskErrorLog(@"%@: <%p>.error { error: %@ };\n\n", NSStringFromClass(self.class), self, error);
#endif
    [reader close];
    [_delegate task:self anErrorOccurred:error];
}
@end
