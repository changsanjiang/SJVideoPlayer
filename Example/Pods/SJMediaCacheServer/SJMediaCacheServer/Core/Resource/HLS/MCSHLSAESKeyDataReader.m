//
//  MCSHLSAESKeyDataReader.m
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2020/6/23.
//

#import "MCSHLSAESKeyDataReader.h"
#import "MCSHLSResource.h"
#import "MCSFileManager.h"
#import "MCSError.h"
#import "MCSResourceResponse.h"
#import "MCSLogger.h"
#import "MCSData.h"
#import "MCSUtils.h"
#import "MCSURLRecognizer.h"
#import "MCSResourceFileDataReader.h"
#import "MCSQueue.h"

@interface MCSHLSAESKeyDataReader ()<MCSResourceDataReaderDelegate>
@property (nonatomic, weak) MCSHLSResource *resource;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic) float networkTaskPriority;

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isClosed;

@property (nonatomic, strong, nullable) MCSResourceFileDataReader *reader;
@end

@implementation MCSHLSAESKeyDataReader
@synthesize delegate = _delegate;
@synthesize response = _response;

- (instancetype)initWithResource:(MCSHLSResource *)resource request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSResourceDataReaderDelegate>)delegate {
    self = [super init];
    if ( self ) {
        _resource = resource;
        _request = request;
        _networkTaskPriority = networkTaskPriority;
        _delegate = delegate;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { URL: %@\n };", NSStringFromClass(self.class), self, _request.URL];
}

- (void)prepare {
    dispatch_barrier_sync(MCSHLSAESDataReaderQueue(), ^{
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSLog(@"%@: <%p>.prepare { URL: %@ };\n", NSStringFromClass(self.class), self, _request.URL);
        
        _isCalledPrepare = YES;
        
        NSString *name = [MCSURLRecognizer.shared nameWithUrl:_request.URL.absoluteString extension:MCSHLSAESKeyFileExtension];
        NSString *filePath = [MCSFileManager hls_AESKeyFilePathInResource:_resource.name AESKeyName:name];
        
        if ( [MCSFileManager fileExistsAtPath:filePath] ) {
            // go to read the content
            [self _prepare:filePath];
            return;
        }
        
        MCSLog(@"%@: <%p>.request { URL: %@ };\n", NSStringFromClass(self.class), self, _request.URL);
        
        // download the content
        
        NSError *error = nil;
        
        // Wait until the download is complete
        NSData *data = [MCSData dataWithContentsOfRequest:[_request mcs_requestWithHTTPAdditionalHeaders:[_resource.configuration HTTPAdditionalHeadersForDataRequestsOfType:MCSDataTypeHLSAESKey]] networkTaskPriority:_networkTaskPriority error:&error];
        
        if ( error != nil ) {
            [self _onError:error];
            return;
        }
        
        [MCSFileManager lockWithBlock:^{
            if ( ![MCSFileManager fileExistsAtPath:filePath] ) {
                if ( ![data writeToFile:filePath atomically:YES] ) {
                    [self _onError:[NSError mcs_HLSAESKeyWriteFailedError:self->_request.URL]];
                    return;
                }
            }
        }];
        
        [self _prepare:filePath];
    });
}

- (nullable MCSResourceFileDataReader *)reader {
    __block MCSResourceFileDataReader *reader = nil;
    dispatch_sync(MCSHLSAESDataReaderQueue(), ^{
        reader = _reader;
    });
    return reader;
}

- (nullable NSData *)readDataOfLength:(NSUInteger)lengthParam {
    return [self.reader readDataOfLength:lengthParam];
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    return [self.reader seekToOffset:offset];
}

- (void)close {
    dispatch_barrier_sync(MCSHLSAESDataReaderQueue(), ^{
        [self _close];
    });
}

#pragma mark -

- (NSRange)range {
    return self.reader.range;
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

- (BOOL)isDone {
    return self.reader.isDone;
}

- (id<MCSResourceResponse>)response {
    __block id<MCSResourceResponse> response = nil;
    dispatch_sync(MCSHLSAESDataReaderQueue(), ^{
        response = _response;
    });
    return response;
}

#pragma mark - MCSResourceDataReaderDelegate

- (void)readerPrepareDidFinish:(id<MCSResourceDataReader>)reader {
    [self.delegate readerPrepareDidFinish:self];
}

- (void)reader:(id<MCSResourceDataReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    [self.delegate reader:self hasAvailableDataWithLength:length];
}

- (void)reader:(id<MCSResourceDataReader>)reader anErrorOccurred:(NSError *)error {
    dispatch_barrier_sync(MCSHLSAESDataReaderQueue(), ^{
        [self _onError:error];
    });
}

#pragma mark -

- (void)_onError:(NSError *)error {
    if ( _isClosed )
        return;
    
    [self _close];
    
    dispatch_async(MCSDelegateQueue(), ^{
        [self->_delegate reader:self anErrorOccurred:error];
    });
}

- (void)_prepare:(NSString *)filePath {
    NSUInteger fileSize = [MCSFileManager fileSizeAtPath:filePath];
    NSRange range = NSMakeRange(0, fileSize);
    
    _response = [MCSResourceResponse.alloc initWithServer:@"localhost" contentType:@"application/octet-stream" totalLength:fileSize];
    _reader = [MCSResourceFileDataReader.alloc initWithResource:_resource range:range path:filePath readRange:range delegate:self];
    [_reader prepare];
}

- (void)_close {
    if ( _isClosed )
        return;
    
    [_reader close];
    _isClosed = YES;
    
    MCSLog(@"%@: <%p>.close;\n", NSStringFromClass(self.class), self);
}

@end
