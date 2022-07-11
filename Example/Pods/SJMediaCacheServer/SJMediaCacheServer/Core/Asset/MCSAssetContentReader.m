//
//  MCSAssetContentReader.m
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2021/7/19.
//

#import "MCSAssetContentReader.h"
#import "MCSError.h"
#import "MCSLogger.h"
#import "NSFileHandle+MCS.h"
#import "MCSQueue.h"
#import "MCSUtils.h"

/// 子类需要实现的方法
///
@interface MCSAssetContentReader (MCSSubclassHooks)
/// 子类准备内容.
- (void)prepareContent;
- (void)didAbortWithError:(nullable NSError *)error;
@end

/// 子类通知抽象类发生了什么事情
///
@interface MCSAssetContentReader (MCSSubclassNotify)
/// 子类通知抽象类已准备好`content`. 调用前, 请对 `content`做一次 readwriteRetain
- (void)preparationDidFinishWithContentReadwrite:(id<MCSAssetContent>)content range:(NSRange)range;
@end

@interface MCSAssetContentReader()<MCSAssetContentObserver> {
    MCSReaderStatus _mStatus;
    id<MCSAsset> _mAsset;
    id<MCSAssetContent> _Nullable _mContent;
    NSRange _mRange;
    UInt64 _mAvailableLength;
    UInt64 _mReadLength;
}
@end

@implementation MCSAssetContentReader
@synthesize delegate = _delegate;
- (instancetype)initWithAsset:(id<MCSAsset>)asset delegate:(id<MCSAssetContentReaderDelegate>)delegate {
    self = [super init];
    if ( self ) {
        _mAsset = asset;
        _delegate = delegate; 
    }
    return self;
}

- (void)dealloc {
    mcs_queue_sync(^{
        _delegate = nil;
        [self _abortWithError:nil];
        MCSContentReaderDebugLog(@"%@: <%p>.dealloc;\n", NSStringFromClass(self.class), self);
    });
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { range: %@\n };", NSStringFromClass(self.class), self, NSStringFromRange(_mRange)];
}

- (nullable __kindof id<MCSAssetContent>)content {
    __block id<MCSAssetContent> content = nil;
    mcs_queue_sync(^{
        content = _mContent;
    });
    return content;
}

- (void)prepare {
    mcs_queue_sync(^{
        switch ( _mStatus ) {
            case MCSReaderStatusReadyToRead:
            case MCSReaderStatusPreparing:
            case MCSReaderStatusFinished:
            case MCSReaderStatusAborted:
                /* return */
                return;
            case MCSReaderStatusUnknown: {
                _mStatus = MCSReaderStatusPreparing;
                [self prepareContent];
            }
                break;
        }
    });
}

- (nullable NSData *)readDataOfLength:(UInt64)lengthParam {
    __block NSData *data = nil;
    mcs_queue_sync(^{
        switch ( _mStatus ) {
            case MCSReaderStatusUnknown:
            case MCSReaderStatusPreparing:
            case MCSReaderStatusFinished:
            case MCSReaderStatusAborted:
                /* return */
                return;
            case MCSReaderStatusReadyToRead: {
                NSError *error = nil;
                UInt64 capacity = MIN(lengthParam, _mAvailableLength - _mReadLength);
                UInt64 position = _mRange.location + _mReadLength;
                data = [_mContent readDataAtPosition:position capacity:capacity error:&error];
                if ( error != nil ) {
                    [self _abortWithError:error];
                    return;
                }
                
                UInt64 readLength = data.length;
                if ( readLength == 0 )
                    return;
                
                _mReadLength += readLength;
                BOOL isReachedEndPosition = (_mReadLength == _mRange.length);
                
                MCSContentReaderDebugLog(@"%@: <%p>.read { range: %@, offset: %llu, length: %llu };\n", NSStringFromClass(self.class), self, NSStringFromRange(_mRange), position, readLength);

                if ( isReachedEndPosition ) [self _finish];
            }
                break;
        }
    });
    return data;
}

- (BOOL)seekToOffset:(UInt64)offset {
    __block BOOL result = NO;
    mcs_queue_sync(^{
        switch ( _mStatus ) {
            case MCSReaderStatusUnknown:
            case MCSReaderStatusPreparing:
            case MCSReaderStatusFinished:
            case MCSReaderStatusAborted:
                /* return */
                return;
            case MCSReaderStatusReadyToRead: {
                NSRange range = NSMakeRange(_mRange.location, _mAvailableLength);
                if ( !NSLocationInRange(offset - 1, range) )
                    return;
                
                // offset     = range.location + readLength;
                // readLength = offset - range.location
                UInt64 readLength = offset - _mRange.location;
                if ( readLength != _mReadLength ) {
                    _mReadLength = readLength;
                    BOOL isReachedEndPosition = (_mReadLength == _mRange.length);
                    if ( isReachedEndPosition ) {
                        [self _finish];
                    }
                }
                result = YES;
            }
                break;
        }
    });
    return result;
}

- (void)abortWithError:(nullable NSError *)error {
    mcs_queue_sync(^{
        [self _abortWithError:error];
    });
}

#pragma mark -

- (NSRange)range {
    __block NSRange range;
    mcs_queue_sync(^{
        range = _mRange;
    });
    return range;
}

- (UInt64)availableLength {
    __block UInt64 availableLength;
    mcs_queue_sync(^{
        availableLength = _mAvailableLength;
    });
    return availableLength;
}

- (UInt64)offset {
    __block UInt64 offset = 0;
    mcs_queue_sync(^{
        offset = _mRange.location + _mReadLength;
    });
    return offset;
}

- (MCSReaderStatus)status {
    __block MCSReaderStatus status;
    mcs_queue_sync(^{
        status = _mStatus;
    });
    return status;
}

#pragma mark - subclass

- (void)prepareContent {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)didAbortWithError:(nullable NSError *)error {
    // nothing
    // 子类可以重写该方法去清理相关资源
}

/// 子类在完成准备后的回调
///
///     调用前, 请对 `content`做一次 readwriteRetain
///
- (void)preparationDidFinishWithContentReadwrite:(id<MCSAssetContent>)content range:(NSRange)range {
    mcs_queue_sync(^{
        switch ( _mStatus ) {
            case MCSReaderStatusFinished:
            case MCSReaderStatusAborted:
            case MCSReaderStatusReadyToRead:
                /* reutrn */
                return;
            case MCSReaderStatusUnknown:
            case MCSReaderStatusPreparing: {
                _mStatus = MCSReaderStatusReadyToRead;
                _mRange = range;
                _mContent = content;
                [_mContent registerObserver:self];
                NSRange contentRange = NSMakeRange(_mContent.startPositionInAsset, (NSInteger)_mContent.length);
                _mAvailableLength = NSIntersectionRange(contentRange, _mRange).length;
                [_delegate readerWasReadyToRead:self];
                if ( _mAvailableLength != 0 && _mReadLength < _mAvailableLength )
                    [_delegate reader:self hasAvailableDataWithLength:(NSInteger)(_mAvailableLength - _mReadLength)];
            }
                break;
        }
    });
}

#pragma mark - MCSAssetContentObserver

- (void)content:(id<MCSAssetContent>)content didWriteDataWithLength:(NSUInteger)length {
    mcs_queue_sync(^{
        NSRange contentRange = NSMakeRange(_mContent.startPositionInAsset, content.length);
        _mAvailableLength = NSIntersectionRange(contentRange, _mRange).length;
        [_delegate reader:self hasAvailableDataWithLength:length];
    });
}

#pragma mark -

- (void)_abortWithError:(nullable NSError *)error {
    switch ( _mStatus ) {
        case MCSReaderStatusFinished:
        case MCSReaderStatusAborted:
            /* return */
            return;
        case MCSReaderStatusUnknown:
        case MCSReaderStatusPreparing:
        case MCSReaderStatusReadyToRead: {
            _mStatus = MCSReaderStatusAborted;
            [self _clean];
            [self didAbortWithError:error];
            [_delegate reader:self didAbortWithError:error];
            MCSContentReaderDebugLog(@"%@: <%p>.abort { error: %@ };\n", NSStringFromClass(self.class), self, error);
        }
            break;
    }
}

- (void)_finish {
    switch ( _mStatus ) {
        case MCSReaderStatusFinished:
        case MCSReaderStatusAborted:
            /* return */
            return;
        case MCSReaderStatusUnknown:
        case MCSReaderStatusPreparing:
        case MCSReaderStatusReadyToRead: {
            _mStatus = MCSReaderStatusFinished;
            [self _clean];
            MCSContentReaderDebugLog(@"%@: <%p>.finished { range: %@ , file: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(_mRange), _mContent);
        }
            break;
    }
}

- (void)_clean {
    [_mContent removeObserver:self];
    [_mContent readwriteRelease];
    [_mContent closeRead];
}
@end


@implementation MCSAssetFileContentReader {
    id<MCSAssetContent> mFileContent;
    NSRange mReadRange;
}

- (instancetype)initWithAsset:(id<MCSAsset>)asset fileContent:(id<MCSAssetContent>)content rangeInAsset:(NSRange)range delegate:(id<MCSAssetContentReaderDelegate>)delegate {
    self = [super initWithAsset:asset delegate:delegate];
    if ( self ) {
        mFileContent = content;
        mReadRange = range;
    }
    return self;
}
 
- (void)prepareContent {
    MCSContentReaderDebugLog(@"%@: <%p>.prepareContent { range: %@, file: %@ };\n", NSStringFromClass(self.class), self, NSStringFromRange(mReadRange), mFileContent);
    
    if ( mReadRange.location < mFileContent.startPositionInAsset || NSMaxRange(mReadRange) > (mFileContent.startPositionInAsset + mFileContent.length) ) {
        [self abortWithError:[NSError mcs_errorWithCode:MCSInvalidParameterError userInfo:@{
            MCSErrorUserInfoObjectKey : self,
            MCSErrorUserInfoReasonKey : @"请求范围错误, 请求范围未在内容范围中!"
        }]];
        return;
    }
    
    [mFileContent readwriteRetain];
    [self preparationDidFinishWithContentReadwrite:mFileContent range:mReadRange];
}
@end

#import "NSFileHandle+MCS.h"
#import "MCSError.h"
#import "MCSDownload.h"
#import "MCSLogger.h"
#import "MCSUtils.h"
#import "MCSQueue.h"
 
@interface MCSAssetHTTPContentReader ()<MCSDownloadTaskDelegate> {
    id<MCSAsset> mAsset;
    NSURLRequest *mRequest;
    MCSDataType mDataType;
    NSRange mReadRange;
    id<MCSAssetContent>_Nullable mHTTPContent;
    id<MCSDownloadTask>_Nullable mTask;
    float mNetworkTaskPriority;
}
@end

@implementation MCSAssetHTTPContentReader
- (instancetype)initWithAsset:(id<MCSAsset>)asset request:(NSURLRequest *)request networkTaskPriority:(float)priority dataType:(MCSDataType)dataType delegate:(id<MCSAssetContentReaderDelegate>)delegate {
    return [self initWithAsset:asset request:request rangeInAsset:NSMakeRange(0, 0) contentReadwrite:nil networkTaskPriority:priority dataType:dataType delegate:delegate];
}

- (instancetype)initWithAsset:(id<MCSAsset>)asset request:(NSURLRequest *)request rangeInAsset:(NSRange)range contentReadwrite:(nullable id<MCSAssetContent>)content /* 如果content不存在将会通过asset进行创建 */ networkTaskPriority:(float)priority dataType:(MCSDataType)dataType delegate:(id<MCSAssetContentReaderDelegate>)delegate {
    self = [super initWithAsset:asset delegate:delegate];
    if ( self ) {
        mAsset = asset;
        mRequest = request;
        mDataType = dataType;
        mHTTPContent = content;
        mReadRange = range;
        mNetworkTaskPriority = priority;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: <%p> { request: %@ };\n", NSStringFromClass(self.class), self, mRequest.mcs_description];
}

- (void)prepareContent {
    MCSContentReaderDebugLog(@"%@: <%p>.prepareContent { request: %@ };\n", NSStringFromClass(self.class), self, mRequest);
    
    if ( mHTTPContent != nil ) {
        // broken point download
        if ( mReadRange.length > mHTTPContent.length ) {
            NSUInteger start = mReadRange.location + mHTTPContent.length;
            NSUInteger length = NSMaxRange(mReadRange) - start;
            NSRange newRange = NSMakeRange(start, length);
            NSMutableURLRequest *newRequest = [[mRequest mcs_requestWithRange:newRange] mcs_requestWithHTTPAdditionalHeaders:[mAsset.configuration HTTPAdditionalHeadersForDataRequestsOfType:mDataType]];
            mTask = [MCSDownload.shared downloadWithRequest:newRequest priority:mNetworkTaskPriority delegate:self];
        }
        [self preparationDidFinishWithContentReadwrite:mHTTPContent range:mReadRange];
    }
    // download ts all content
    else {
        mTask = [MCSDownload.shared downloadWithRequest:[mRequest mcs_requestWithHTTPAdditionalHeaders:[mAsset.configuration HTTPAdditionalHeadersForDataRequestsOfType:mDataType]] priority:mNetworkTaskPriority delegate:self];
    }
}

#pragma mark - MCSDownloadTaskDelegate

- (void)downloadTask:(id<MCSDownloadTask>)task willPerformHTTPRedirectionWithNewRequest:(NSURLRequest *)request { }

- (void)downloadTask:(id<MCSDownloadTask>)task didReceiveResponse:(id<MCSDownloadResponse>)response {
    mcs_queue_sync(^{
        switch ( self.status ) {
            case MCSReaderStatusFinished:
            case MCSReaderStatusAborted:
            case MCSReaderStatusReadyToRead:
                /* return */
                return;
            case MCSReaderStatusUnknown:
            case MCSReaderStatusPreparing: {
                if ( mHTTPContent == nil ) {
                    mHTTPContent = [mAsset createContentReadwriteWithDataType:mDataType response:response];
                    
                    if ( mHTTPContent == nil ) {
                        [self abortWithError:[NSError mcs_errorWithCode:MCSInvalidResponseError userInfo:@{
                            MCSErrorUserInfoObjectKey : response,
                            MCSErrorUserInfoReasonKey : @"创建content失败!"
                        }]];
                        return;
                    }
                    
                    [self preparationDidFinishWithContentReadwrite:mHTTPContent range:response.statusCode == 206 ? response.range : NSMakeRange(0, response.totalLength)];
                }
            }
                break;
        }
    });
}

- (void)downloadTask:(id<MCSDownloadTask>)task didReceiveData:(NSData *)data {
    mcs_queue_sync(^{
        switch ( self.status ) {
            case MCSReaderStatusFinished:
            case MCSReaderStatusAborted:
                /* return */
                return;
            case MCSReaderStatusUnknown:
            case MCSReaderStatusPreparing:
            case MCSReaderStatusReadyToRead: {
                NSError *error = nil;
                if ( ![mHTTPContent writeData:data error:&error] ) {
                    [self abortWithError:error];
                }
            }
                break;
        }
    });
}

- (void)downloadTask:(id<MCSDownloadTask>)task didCompleteWithError:(NSError *)error {
    mcs_queue_sync(^{
        switch ( self.status ) {
            case MCSReaderStatusFinished:
            case MCSReaderStatusAborted:
                /* return */
                return;
            case MCSReaderStatusUnknown:
            case MCSReaderStatusPreparing:
            case MCSReaderStatusReadyToRead: {
                if ( error != nil ) {
                    [self abortWithError:error];
                }
                //    else {
                //        // finished download
                //    }
            }
                break;
        }
    });
}

- (void)didAbortWithError:(nullable NSError *)error {
    [mTask cancel];
    mTask = nil;
}
@end
