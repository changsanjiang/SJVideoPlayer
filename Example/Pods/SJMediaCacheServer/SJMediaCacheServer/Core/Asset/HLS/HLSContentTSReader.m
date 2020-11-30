//
//  HLSContentTSReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "HLSContentTSReader.h"
#import "MCSLogger.h"
#import "HLSAsset.h"
#import "MCSAssetFileRead.h"
#import "MCSDownload.h"
#import "MCSUtils.h"
#import "MCSError.h"
#import "NSFileHandle+MCS.h"
#import "MCSQueue.h"
#import "NSURLRequest+MCS.h"
#import "HLSContentTs.h"
#import "NSFileManager+MCS.h"

static dispatch_queue_t mcs_queue;

@interface HLSContentTSReader ()<MCSDownloadTaskDelegate>
@property (nonatomic, weak, nullable) HLSAsset *asset;
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic) BOOL isCalledPrepare;
@property (nonatomic) BOOL isPrepared;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isDone;
@property (nonatomic) BOOL isSought;

@property (nonatomic, strong, nullable) HLSContentTs *content;
@property (nonatomic) NSUInteger availableLength;
@property (nonatomic) NSUInteger offset;

@property (nonatomic, strong, nullable) NSURLSessionTask *task;
@property (nonatomic, strong, nullable) NSFileHandle *reader;
@property (nonatomic, strong, nullable) NSFileHandle *writer;
@property (nonatomic) float networkTaskPriority;
@end

@implementation HLSContentTSReader
@synthesize delegate = _delegate;
@synthesize range = _range;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mcs_queue = dispatch_queue_create("queue.HLSContentTSReader", DISPATCH_QUEUE_CONCURRENT);
    });
}

- (instancetype)initWithAsset:(HLSAsset *)asset request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(id<MCSAssetDataReaderDelegate>)delegate {
    self = [super init];
    if ( self ) {
        _networkTaskPriority = networkTaskPriority;
        _asset = asset;
        _request = request;
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
    return [NSString stringWithFormat:@"%@:<%p> { request: %@\n };", NSStringFromClass(self.class), self, _request.mcs_description];
}

- (void)prepare {
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _isClosed || _isCalledPrepare )
            return;
        
        MCSContentReaderDebugLog(@"%@: <%p>.prepare { request: %@\n };\n", NSStringFromClass(self.class), self, _request.mcs_description);

        _isCalledPrepare = YES;
        
        HLSContentTs *content = [_asset TsContentForURL:_request.URL];
        
        if ( content != nil ) {
            // go to read the content
            [self _prepareForContent:content];
            return;
        }
        
        MCSContentReaderDebugLog(@"%@: <%p>.download { request: %@\n };\n", NSStringFromClass(self.class), self, _request.mcs_description);
        
        // download the content
        _task = [MCSDownload.shared downloadWithRequest:[_request mcs_requestWithHTTPAdditionalHeaders:[_asset.configuration HTTPAdditionalHeadersForDataRequestsOfType:MCSDataTypeHLSTs]] priority:_networkTaskPriority delegate:self];
    });
}

- (NSData *)readDataOfLength:(NSUInteger)lengthParam {
    __block NSData *data = nil;
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _isClosed || _isDone || !_isPrepared )
            return;
        
        if ( _isSought ) {
            _isSought = NO;
            NSError *error = nil;
            [_reader mcs_seekToOffset:_offset error:&error];
            if ( error != nil ) {
                [self _onError:error];
                return;
            }
        }
        
        if ( _offset < _availableLength ) {
            NSUInteger length = MIN(lengthParam, _availableLength - _offset);
            if ( length > 0 ) {
                NSError *error = nil;
                data = [_reader mcs_readDataUpToLength:length error:&error];
                if ( error != nil ) {
                    [self _onError:error];
                    return;
                }
                _offset += data.length;
                _isDone = (_offset == NSMaxRange(_range));
                MCSContentReaderDebugLog(@"%@: <%p>.read { offset: %lu, length: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)_offset, (unsigned long)data.length);
            }
        }
        
#ifdef DEBUG
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
        if ( _isClosed || !_isPrepared || offset > _availableLength )
            return;
        
        if ( offset != _offset ) {
            _isSought = YES;
            _offset = offset;
            _isDone = (_offset == NSMaxRange(_range));
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

- (NSRange)range {
    __block NSRange range = NSMakeRange(0, 0);
    dispatch_sync(mcs_queue, ^{
        range = _range;
    });
    return range;
}

- (NSUInteger)availableLength {
    __block NSUInteger availableLength = 0;
    dispatch_sync(mcs_queue, ^{
        availableLength = _availableLength;
    });
    return availableLength;
}

- (NSUInteger)offset {
    __block NSUInteger offset = 0;
    dispatch_sync(mcs_queue, ^{
        offset = _offset;
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
        
        HLSContentTs *content = [_asset createTsContentWithResponse:response];
        [self _prepareForContent:content];
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
        else {
            // finished download
        }
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

- (void)_prepareForContent:(HLSContentTs *)content {
    _content = content;
    [_content readwriteRetain];
    NSString *filePath = [_asset TsContentFilePathForFilename:content.filename];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSError *error = nil;
    _range = NSMakeRange(0, _content.totalLength);
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
    
    NSUInteger availableLength = (NSUInteger)[NSFileManager.defaultManager mcs_fileSizeAtPath:filePath];
    _availableLength = availableLength;
        
    _isPrepared = YES;
    
    dispatch_async(MCSDelegateQueue(), ^{
        [self->_delegate readerPrepareDidFinish:self];
        
        if ( availableLength != 0 ) {
            [self->_delegate reader:self hasAvailableDataWithLength:availableLength];
        }
    });
}

- (void)_close {
    if ( _isClosed )
        return;

    // task
    [_task cancel];
    _task = nil;

    // file handles
    [_writer mcs_synchronizeAndReturnError:NULL];
    [_writer mcs_closeAndReturnError:NULL];
    _writer = nil;

    [_reader mcs_closeAndReturnError:NULL];
    _reader = nil;
    
    _isClosed = YES;
    
    MCSContentReaderDebugLog(@"%@: <%p>.close;\n", NSStringFromClass(self.class), self);
}
@end
