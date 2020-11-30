//
//  FILEContentReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "FILEContentReader.h"
#import "FILEAsset.h"
#import "NSFileHandle+MCS.h"
#import "MCSError.h"
#import "MCSDownload.h" 
#import "MCSLogger.h"
#import "MCSUtils.h"
#import "MCSQueue.h"

static dispatch_queue_t mcs_queue;

@interface FILEContentReader ()<MCSDownloadTaskDelegate>
@property (nonatomic, weak, nullable) FILEAsset *asset;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic) NSRange range;

@property (nonatomic, strong, nullable) NSURLSessionTask *task;

@property (nonatomic, strong, nullable) NSFileHandle *reader;
@property (nonatomic, strong, nullable) NSFileHandle *writer;

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;
@property (nonatomic) BOOL isSought;

@property (nonatomic, strong, nullable) id<MCSAssetContent> content;
@property (nonatomic) NSUInteger availableLength;
@property (nonatomic) NSUInteger readLength;

@property (nonatomic) float networkTaskPriority;
@end

@implementation FILEContentReader
@synthesize delegate = _delegate;
@synthesize isPrepared = _isPrepared;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mcs_queue = dispatch_queue_create("queue.FILEContentReader", DISPATCH_QUEUE_CONCURRENT);
    });
}

- (instancetype)initWithAsset:(__weak FILEAsset *)asset request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSAssetDataReaderDelegate>)delegate {
    self = [super init];
    if ( self ) {
        _asset = asset;
        _request = request;
        _networkTaskPriority = networkTaskPriority;
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    if ( !_isClosed ) [self _close];
    if ( _content != nil ) [_content readwriteRelease];
    MCSContentReaderDebugLog(@"%@: <%p>.dealloc;\n", NSStringFromClass(self.class), self);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: <%p> { request: %@ };\n", NSStringFromClass(self.class), self, _request.mcs_description];
}

- (void)prepare {
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSContentReaderDebugLog(@"%@: <%p>.prepare { request: %@ };\n", NSStringFromClass(self.class), self, _request.mcs_description);
        
        _isCalledPrepare = YES;
        
        _task = [MCSDownload.shared downloadWithRequest:[_request mcs_requestWithHTTPAdditionalHeaders:[_asset.configuration HTTPAdditionalHeadersForDataRequestsOfType:MCSDataTypeFILE]] priority:_networkTaskPriority delegate:self];
    });
}

- (nullable NSData *)readDataOfLength:(NSUInteger)lengthParam {
    __block NSData *data = nil;
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _isClosed || _isDone || !_isPrepared )
            return;
        
        NSError *error = nil;
        if ( _isSought ) {
            _isSought = NO;
            if ( ![_reader mcs_seekToOffset:_readLength error:&error] ) {
                [self _onError:error];
                return;
            }
        }
        
        data = [_reader mcs_readDataUpToLength:lengthParam error:&error];
        if ( error != nil ) {
            [self _onError:error];
            return;
        }
        
        NSUInteger readLength = data.length;
        if ( readLength == 0 )
            return;
        
        _readLength += readLength;
        _isDone = (_readLength == _range.length);
        
#ifdef DEBUG
        MCSContentReaderDebugLog(@"%@: <%p>.read { offset: %lu, length: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)(_range.location + _readLength), (unsigned long)readLength);
        if ( _isDone ) {
            MCSContentReaderDebugLog(@"%@: <%p>.done;\n", NSStringFromClass(self.class), self);
        }
#endif
        
        if ( _isDone ) [self _close];
    });
    return data;
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    __block BOOL result = NO;
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _isClosed || !_isPrepared )
            return;
        
        NSRange range = NSMakeRange(_range.location, _availableLength);
        if ( !NSLocationInRange(offset - 1, range) )
            return;
        
        // offset   = range.location + readLength;
        NSUInteger readLength = offset - range.location;
        if ( readLength != _readLength ) {
            _isSought = YES;
            _readLength = readLength;
            _isDone = (_readLength == _range.length);
            if ( _isDone ) [self _close];
        }
        result = YES;
    });
    return result;
}

- (void)close {
    dispatch_barrier_sync(mcs_queue, ^{
        [self _close];
    });
}

#pragma mark -

- (NSUInteger)offset {
    __block NSUInteger offset = 0;
    dispatch_sync(mcs_queue, ^{
        offset = _range.location + _readLength;
    });
    return offset;
}

- (BOOL)isPrepared {
    __block BOOL isPrepared = NO;
    dispatch_sync(mcs_queue, ^{
        isPrepared = _isPrepared;
    });
    return isPrepared;
}

- (BOOL)isDone {
    __block BOOL isDone = NO;
    dispatch_sync(mcs_queue, ^{
        isDone = _isDone;
    });
    return isDone;
}

#pragma mark - MCSDownloadTaskDelegate

- (void)downloadTask:(NSURLSessionTask *)task didReceiveResponse:(NSHTTPURLResponse *)response {
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _isClosed )
            return;
        _range = MCSGetResponseNSRange(MCSGetResponseContentRange(response));
        _content = [_asset createContentWithResponse:response];
        [_content readwriteRetain];
        
        NSString *filePath = [_asset contentFilePathForFilename:_content.filename];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        NSError *error = nil;
        _reader = [NSFileHandle mcs_fileHandleForReadingFromURL:fileURL error:&error];
        if ( error != nil ) {
            [self _onError:error];
            return;
        }
        
        _writer = [NSFileHandle mcs_fileHandleForWritingToURL:fileURL error:&error];
        if ( error != nil ) {
            [self _onError:error];
            return;
        }
        
        _isPrepared = YES;
        
        dispatch_async(MCSDelegateQueue(), ^{
            [self->_delegate readerPrepareDidFinish:self];
        });
    });
}

- (void)downloadTask:(NSURLSessionTask *)task didReceiveData:(NSData *)data {
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _isClosed )
            return;
        
        if ( _asset == nil ) {
            [self _close];
            return;
        }
        
        NSError *error = nil;
        [_writer mcs_writeData:data error:&error];
        if ( error != nil ) {
            [self _onError:error];
            return;
        }
        
        NSUInteger length = data.length;
        _availableLength += length;
        [_content didWriteDataWithLength:length];
        
        dispatch_async(MCSDelegateQueue(), ^{
            [self->_delegate reader:self hasAvailableDataWithLength:length];
        });
    });
}

- (void)downloadTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _isClosed )
            return;
        
        if ( error != nil ) {
            [self _onError:error];
        }
        //    else {
        //        // finished download
        //    }
    });
}

#pragma mark -

- (void)_onError:(NSError *)error {
    if ( _isClosed )
        return;
    
    MCSContentReaderErrorLog(@"%@: <%p>.error { error: %@ };\n", NSStringFromClass(self.class), self, error);

    [self _close];
    
    dispatch_async(MCSDelegateQueue(), ^{
        [self->_delegate reader:self anErrorOccurred:error];
    });
}

- (void)_close {
    if ( _isClosed )
        return;

    [_task cancel];
    _task = nil;
    
    [_writer mcs_synchronizeAndReturnError:NULL];
    [_writer mcs_closeAndReturnError:NULL];
    _writer = nil;
    
    [_reader mcs_closeAndReturnError:NULL];
    _reader = nil;
    _isClosed = YES;

    MCSContentReaderDebugLog(@"%@: <%p>.close;\n", NSStringFromClass(self.class), self);
}
@end
