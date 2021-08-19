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
#import "MCSURL.h"

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
        MCSProxyTaskDebugLog(@"%@: <%p>.init { URL: %@, proxyURL: %@, headers: %@ };\n", NSStringFromClass(self.class), self, [MCSURL.shared URLWithProxyURL:request.URL], request.URL, request.allHTTPHeaderFields);
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
#ifdef DEBUG
    UInt64 offset = [_reader offset];
#endif
    NSData *data = [_reader readDataOfLength:length];
#ifdef DEBUG
    if ( data.length != 0 ) {
        MCSProxyTaskDebugLog(@"%@: <%p>.read { offset: %llu, length: %lu };\n", NSStringFromClass(self.class), self, offset, (unsigned long)data.length);
        if ( _reader.status == MCSReaderStatusFinished )
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
    switch ( _reader.status ) {
        case MCSReaderStatusUnknown:
        case MCSReaderStatusPreparing:
        case MCSReaderStatusAborted:
            return false;
        case MCSReaderStatusReadyToRead:
        case MCSReaderStatusFinished:
            return true;
    }
}

- (BOOL)isDone {
    return _reader.status == MCSReaderStatusFinished;
}

- (void)close {
#ifdef DEBUG
    MCSProxyTaskDebugLog(@"%@: <%p>.close { after (%lf) seconds };\n\n", NSStringFromClass(self.class), self, MCSEndTime(_startTime));
#endif
    [_reader abortWithError:nil];
}

#pragma mark -

- (void)reader:(id<MCSAssetReader>)reader didReceiveResponse:(id<MCSResponse>)response {
    if ( reader.status != MCSReaderStatusAborted ) [_delegate task:self didReceiveResponse:response];
}

- (void)reader:(id<MCSAssetReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    if ( reader.status != MCSReaderStatusAborted ) [_delegate task:self hasAvailableDataWithLength:length];
}

- (void)reader:(id<MCSAssetReader>)reader didAbortWithError:(nullable NSError *)error {
#ifdef DEBUG
    MCSProxyTaskErrorLog(@"%@: <%p>.error { error: %@ };\n\n", NSStringFromClass(self.class), self, error);
#endif
    [_delegate task:self didAbortWithError:error];
}
@end
