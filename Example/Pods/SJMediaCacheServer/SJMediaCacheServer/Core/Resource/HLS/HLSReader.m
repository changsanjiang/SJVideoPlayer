//
//  HLSReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "HLSReader.h"
#import "HLSAsset.h"
#import "HLSContentIndexReader.h"
#import "HLSContentAESKeyReader.h"
#import "HLSContentTSReader.h"
#import "MCSFileManager.h"
#import "MCSLogger.h"
#import "HLSAsset.h"
#import "MCSAssetManager.h"
#import "MCSError.h"
#import "MCSQueue.h"
#import "MCSResponse.h"

@interface HLSReader ()<MCSAssetDataReaderDelegate> 
@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic, weak, nullable) HLSAsset *asset;
@property (nonatomic, strong, nullable) NSURLRequest *request;
@property (nonatomic, strong, nullable) id<MCSAssetDataReader> reader;
@end

@implementation HLSReader
@synthesize readDataDecoder = _readDataDecoder;
@synthesize isClosed = _isClosed;
@synthesize response = _response;

- (instancetype)initWithAsset:(__weak HLSAsset *)asset request:(NSURLRequest *)request {
    self = [super init];
    if ( self ) {
        _networkTaskPriority = 1.0;
        _asset = asset;
        _request = request;
        [_asset readWrite_retain];
        [MCSAssetManager.shared reader:self willReadAsset:asset];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didRemoveAsset:) name:MCSAssetManagerDidRemoveAssetNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(userCancelledReading:) name:MCSAssetManagerUserCancelledReadingNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [_asset readWrite_release];
    [MCSAssetManager.shared reader:self didEndReadAsset:_asset];
    if ( !_isClosed ) [self _close];
    MCSAssetReaderDebugLog(@"%@: <%p>.dealloc;\n", NSStringFromClass(self.class), self);
}

- (void)didRemoveAsset:(NSNotification *)note {
    MCSAsset *asset = note.userInfo[MCSAssetManagerUserInfoAssetKey];
    if ( asset == _asset )  {
        dispatch_barrier_sync(MCSReaderQueue(), ^{
            if ( _isClosed )
                return;
            [self _onError:[NSError mcs_errorWithCode:MCSFileError userInfo:@{
                MCSErrorUserInfoObjectKey : _request,
                MCSErrorUserInfoReasonKey : @"资源已被删除!"
            }]];
        });
    }
}

- (void)userCancelledReading:(NSNotification *)note {
    MCSAsset *asset = note.userInfo[MCSAssetManagerUserInfoAssetKey];
    if ( asset == _asset && !self.isClosed )  {
        dispatch_barrier_sync(MCSReaderQueue(), ^{
           if ( _isClosed )
               return;
            [self _onError:[NSError mcs_errorWithCode:MCSUserCancelledError userInfo:@{
                MCSErrorUserInfoObjectKey : _request,
                MCSErrorUserInfoReasonKey : @"读取操作已被取消!"
            }]];
        });
    }
}

- (void)prepare {
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSAssetReaderDebugLog(@"%@: <%p>.prepare { name: %@, request: %@ };\n", NSStringFromClass(self.class), self, _asset.name, _request);

        NSParameterAssert(_asset);
        
        _isCalledPrepare = YES;
        NSURL *URL = [MCSURLRecognizer.shared URLWithProxyURL:_request.URL];
        NSMutableURLRequest *request = [_request mcs_requestWithRedirectURL:URL];
        if      ( [_request.URL.absoluteString containsString:HLSFileExtensionIndex] ) {
            _reader = [HLSContentIndexReader.alloc initWithAsset:_asset request:request networkTaskPriority:_networkTaskPriority delegate:self];
        }
        else {
            if ( _asset.parser == nil ) {
                [self _onError:[NSError mcs_errorWithCode:MCSUnknownError userInfo:@{
                    MCSErrorUserInfoObjectKey : _request,
                    MCSErrorUserInfoReasonKey : @"解析器为空, 索引文件可能未解析!"
                }]];
                return;
            }
            
            if ( [_request.URL.absoluteString containsString:HLSFileExtensionAESKey] ) {
                _reader = [HLSContentAESKeyReader.alloc initWithAsset:_asset request:request networkTaskPriority:_networkTaskPriority delegate:self];
            }
            else {
                _reader = [HLSContentTSReader.alloc initWithAsset:_asset request:request networkTaskPriority:_networkTaskPriority delegate:self];
            }
        }
        
        [_reader prepare];
    });
}

- (nullable id<MCSAssetDataReader>)reader {
    __block id<MCSAssetDataReader> reader = nil;
    dispatch_sync(MCSReaderQueue(), ^{
        reader = _reader;
    });
    return reader;
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    __block NSData *data = nil;
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        NSUInteger offset = _reader.offset;
        data = [_reader readDataOfLength:length];
        
        if ( data != nil && _readDataDecoder != nil ) {
            data = _readDataDecoder(_request, offset, data);
        }
        
#ifdef DEBUG
        if ( _reader.isDone ) {
            MCSAssetReaderDebugLog(@"%@: <%p>.done;\n", NSStringFromClass(self.class), self);
        }
#endif
    });
    return data;
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    return [self.reader seekToOffset:offset];
}

- (void)close {
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        [self _close];
    });
}

#pragma mark -

- (id<MCSResponse>)response {
    __block id<MCSResponse> response = nil;
    dispatch_sync(MCSReaderQueue(), ^{
        response = _response;
    });
    return response;
}
 
- (NSUInteger)availableLength {
    return self.reader.availableLength;
}

- (NSUInteger)offset {
    return self.reader.offset;
}

- (BOOL)isPrepared {
    return self.reader.isPrepared;
}

- (BOOL)isReadingEndOfData {
    return self.reader.isDone;
}

- (BOOL)isClosed {
    __block BOOL result = NO;
    dispatch_sync(MCSReaderQueue(), ^{
        result = _isClosed;
    });
    return result;
}
 
#pragma mark -

- (void)_close {
    if ( _isClosed )
        return;
    
    [_reader close];
     
    _isClosed = YES;
    
    MCSAssetReaderDebugLog(@"%@: <%p>.close;\n", NSStringFromClass(self.class), self);
}

#pragma mark -

- (void)readerPrepareDidFinish:(id<MCSAssetDataReader>)reader {
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        _response = [MCSResponse.alloc initWithTotalLength:reader.range.length];
    });
    [_delegate reader:self prepareDidFinish:self.response];
}

- (void)reader:(id<MCSAssetDataReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    [_delegate reader:self hasAvailableDataWithLength:length];
}

- (void)reader:(id<MCSAssetDataReader>)reader anErrorOccurred:(NSError *)error {
    dispatch_barrier_sync(MCSReaderQueue(), ^{
        [self _onError:error];
    });
}

- (void)_onError:(NSError *)error {
    if ( _isClosed )
        return;
    [self _close];
    MCSAssetReaderErrorLog(@"%@: <%p>.error { error: %@ };\n", NSStringFromClass(self.class), self, error);
    
    dispatch_async(MCSDelegateQueue(), ^{
        [self->_delegate reader:self anErrorOccurred:error];
    });
}
@end
