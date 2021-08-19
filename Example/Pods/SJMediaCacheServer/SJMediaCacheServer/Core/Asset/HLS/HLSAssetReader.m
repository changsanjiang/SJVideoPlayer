//
//  HLSAssetReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "HLSAssetReader.h"
#import "HLSAssetContentReader.h"
#import "MCSLogger.h"
#import "HLSAsset.h"
#import "MCSError.h"
#import "MCSQueue.h"
#import "MCSResponse.h"
#import "MCSConsts.h"
#import "MCSUtils.h"

@interface HLSAssetReader ()<MCSAssetContentReaderDelegate> {
    MCSDataType mDataType;
    MCSReaderStatus mStatus;
    NSURLRequest *mRequest;
    HLSAsset *mAsset;
    id<MCSAssetContentReader> mReader;
    NSHashTable<id<MCSAssetReaderObserver>> *mObservers;
    UInt64 mOffset;
}
@end

@implementation HLSAssetReader
@synthesize readDataDecoder = _readDataDecoder;
@synthesize response = _response;

- (instancetype)initWithAsset:(__weak HLSAsset *)asset request:(NSURLRequest *)request dataType:(MCSDataType)dataType networkTaskPriority:(float)networkTaskPriority readDataDecoder:(NSData *(^_Nullable)(NSURLRequest *request, NSUInteger offset, NSData *data))readDataDecoder delegate:(id<MCSAssetReaderDelegate>)delegate {
    self = [super init];
    if ( self ) {
#ifdef DEBUG
        MCSAssetReaderDebugLog(@"%@: <%p>.init { URL: %@, asset: %@, headers: %@ };\n", NSStringFromClass(self.class), self, request.URL, asset, request.allHTTPHeaderFields);
#endif

        mAsset = asset;
        mRequest = request;
        _networkTaskPriority = networkTaskPriority;
        _readDataDecoder = readDataDecoder;
        _delegate = delegate;
        mDataType = dataType;
        
        [mAsset readwriteRetain];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { request: %@\n };", NSStringFromClass(self.class), self, mRequest.mcs_description];
}

- (void)dealloc {
    mcs_queue_sync(^{
        _delegate = nil;
        [mObservers removeAllObjects];
        [self _abortWithError:nil];
        MCSAssetReaderDebugLog(@"%@: <%p>.dealloc;\n", NSStringFromClass(self.class), self);
    });
}

- (void)prepare {
    mcs_queue_sync(^{
        switch ( mStatus ) {
            case MCSReaderStatusPreparing:
            case MCSReaderStatusFinished:
            case MCSReaderStatusAborted:
            case MCSReaderStatusReadyToRead:
                /* return */
                return;
            case MCSReaderStatusUnknown:
                break;
        }
        
        mStatus = MCSReaderStatusPreparing;
        MCSAssetReaderDebugLog(@"%@: <%p>.prepare { asset: %@, request: %@ };\n", NSStringFromClass(self.class), self, mAsset.name, mRequest);
        [self _notifyObserversWithStatus:mStatus];
        
        if ( mDataType == MCSDataTypeHLSTs || mDataType == MCSDataTypeHLSAESKey ) {
            if ( mAsset.parser == nil ) {
                [self _abortWithError:[NSError mcs_errorWithCode:MCSUnknownError userInfo:@{
                    MCSErrorUserInfoObjectKey : mRequest,
                    MCSErrorUserInfoReasonKey : @"解析器为空, 索引文件可能未解析!"
                }]];
                return;
            }
        }
        
        switch ( mDataType ) {
            case MCSDataTypeHLSPlaylist: {
                mReader = [HLSAssetIndexContentReader.alloc initWithAsset:mAsset request:mRequest networkTaskPriority:_networkTaskPriority delegate:self];
            }
                break;
            case MCSDataTypeHLSAESKey: {
                mReader = [HLSAssetAESKeyContentReader.alloc initWithAsset:mAsset request:mRequest networkTaskPriority:_networkTaskPriority delegate:self];
            }
                break;
            case MCSDataTypeHLSTs: {
                id<HLSAssetTsContent> content = [mAsset TsContentReadwriteForRequest:mRequest];
                if      ( content == nil ) {
                    mReader = [MCSAssetHTTPContentReader.alloc initWithAsset:mAsset request:mRequest networkTaskPriority:_networkTaskPriority dataType:MCSDataTypeHLSTs delegate:self];
                }
                else if ( content.length == content.totalLength ) {
                    mReader = [MCSAssetFileContentReader.alloc initWithAsset:mAsset fileContent:content rangeInAsset:content.rangeInAsset delegate:self];
                }
                else {
                    mReader = [MCSAssetHTTPContentReader.alloc initWithAsset:mAsset request:mRequest rangeInAsset:content.rangeInAsset contentReadwrite:content networkTaskPriority:_networkTaskPriority dataType:MCSDataTypeHLSTs delegate:self];
                }
            }
                break;
            default: {
                [self _abortWithError:[NSError mcs_errorWithCode:MCSFileError userInfo:@{
                    MCSErrorUserInfoObjectKey : mRequest,
                    MCSErrorUserInfoReasonKey : @"不支持的格式!"
                }]];
            }
                return;
        }
        [mReader prepare];
    });
}

- (NSData *)readDataOfLength:(NSUInteger)length {
    __block NSData *data = nil;
    mcs_queue_sync(^{
        switch ( mStatus ) {
            case MCSReaderStatusUnknown:
            case MCSReaderStatusPreparing:
            case MCSReaderStatusFinished:
            case MCSReaderStatusAborted:
                /* return */
                return;
            case MCSReaderStatusReadyToRead: {
                NSUInteger position = mReader.offset;
                data = [mReader readDataOfLength:length];
                mOffset = mReader.offset;
                
                if ( data != nil && _readDataDecoder != nil ) {
                    data = _readDataDecoder(mRequest, position, data);
                }
                
                if ( mReader.status == MCSReaderStatusFinished ) {
                    [self _finish];
                }
            }
                break;
        }
    });
    return data;
}

- (BOOL)seekToOffset:(NSUInteger)offset {
    __block BOOL result = NO;
    mcs_queue_sync(^{
        switch ( mStatus ) {
            case MCSReaderStatusUnknown:
            case MCSReaderStatusPreparing:
            case MCSReaderStatusFinished:
            case MCSReaderStatusAborted:
                /* return */
                return;
            case MCSReaderStatusReadyToRead: {
                result = [mReader seekToOffset:offset];
                mOffset = mReader.offset;
                if ( mReader.status == MCSReaderStatusFinished ) {
                    [self _finish];
                }
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

- (void)registerObserver:(id<MCSAssetReaderObserver>)observer {
    if ( !observer ) return;
    mcs_queue_sync(^{
        if ( mObservers == nil ) {
            mObservers = NSHashTable.weakObjectsHashTable;
        }
        [mObservers addObject:observer];
    });
}

- (void)removeObserver:(id<MCSAssetReaderObserver>)observer {
    mcs_queue_sync(^{
        [mObservers removeObject:observer];
    });
}

#pragma mark -

- (id<MCSResponse>)response {
    __block id<MCSResponse> response = nil;
    mcs_queue_sync(^{
        response = _response;
    });
    return response;
}
 
- (NSUInteger)availableLength {
    __block NSUInteger availableLength;
    mcs_queue_sync(^{
        availableLength = mReader.availableLength;
    });
    return availableLength;
}

- (NSUInteger)offset {
    __block NSUInteger offset;
    mcs_queue_sync(^{
        offset = mOffset;
    });
    return offset;
}

- (MCSReaderStatus)status {
    __block MCSReaderStatus status;
    mcs_queue_sync(^{
        status = mStatus;
    });
    return status;
}
 
- (id<MCSAsset>)asset {
    return mAsset;
}
#pragma mark -

- (void)_abortWithError:(nullable NSError *)error {
    switch ( mStatus ) {
        case MCSReaderStatusFinished:
        case MCSReaderStatusAborted:
            /* return */
            return;
        case MCSReaderStatusUnknown:
        case MCSReaderStatusPreparing:
        case MCSReaderStatusReadyToRead: {
            mStatus = MCSReaderStatusAborted;
            [self _clean];
            [_delegate reader:self didAbortWithError:error];
            MCSAssetReaderDebugLog(@"%@: <%p>.abort { error: %@ };\n", NSStringFromClass(self.class), self, error);
            [self _notifyObserversWithStatus:mStatus];
        }
            break;
    }
}

- (void)_finish {
    switch ( mStatus ) {
        case MCSReaderStatusFinished:
        case MCSReaderStatusAborted:
            /* return */
            return;
        case MCSReaderStatusUnknown:
        case MCSReaderStatusPreparing:
        case MCSReaderStatusReadyToRead: {
            [self _clean];
            mStatus = MCSReaderStatusFinished;
            MCSAssetReaderDebugLog(@"%@: <%p>.finished;\n", NSStringFromClass(self.class), self);
            [self _notifyObserversWithStatus:mStatus];
        }
            break;
    }
}

- (void)_clean {
    [mReader abortWithError:nil];
    mReader = nil;
    [mAsset readwriteRelease];
    
    MCSAssetReaderDebugLog(@"%@: <%p>.clean;\n", NSStringFromClass(self.class), self);
}

- (void)_notifyObserversWithStatus:(MCSReaderStatus)status {
    for ( id<MCSAssetReaderObserver> observer in MCSAllHashTableObjects(mObservers) ) {
        if ( [observer respondsToSelector:@selector(reader:statusDidChange:)] ) {
            [observer reader:self statusDidChange:mStatus];
        }
    }
}

#pragma mark -

- (void)readerWasReadyToRead:(id<MCSAssetContentReader>)reader {
    mcs_queue_sync(^{
        switch ( mStatus ) {
            default:break;
            case MCSReaderStatusPreparing: {
                mStatus = MCSReaderStatusReadyToRead;
                mOffset = reader.offset;
                switch ( mDataType ) {
                    case MCSDataTypeHLSTs: {
                        id<HLSAssetTsContent> content = reader.content;
                        _response = [MCSResponse.alloc initWithTotalLength:content.totalLength range:reader.range contentType:mAsset.TsContentType];
                    }
                        break;
                    case MCSDataTypeHLSMask:
                    case MCSDataTypeHLSPlaylist:
                    case MCSDataTypeHLSAESKey:
                    case MCSDataTypeHLS:
                    case MCSDataTypeFILEMask:
                    case MCSDataTypeFILE:
                        _response = [MCSResponse.alloc initWithTotalLength:reader.range.length];
                        break;
                }
                [_delegate reader:self didReceiveResponse:_response];
                [self _notifyObserversWithStatus:mStatus];
            }
                break;
        }
    });
}

- (void)reader:(id<MCSAssetContentReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    [_delegate reader:self hasAvailableDataWithLength:length];
}

- (void)reader:(id<MCSAssetContentReader>)reader didAbortWithError:(nullable NSError *)error {
    mcs_queue_sync(^{
        [self _abortWithError:error];
    });
}
@end
