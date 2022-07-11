//
//  FILEAssetReader.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "FILEAssetReader.h"
#import "FILEAsset.h"
#import "MCSError.h"
#import "MCSLogger.h"
#import "MCSQueue.h"
#import "MCSResponse.h"
#import "MCSConsts.h"
#import "MCSUtils.h"
#import "MCSAssetContentReader.h"

@interface FILEAssetReader ()<MCSAssetContentReaderDelegate> {
    NSHashTable<id<MCSAssetReaderObserver>> *mObservers;
    MCSReaderStatus mStatus;
    FILEAsset *mAsset;
    NSInteger mCurrentIndex;
    NSURLRequest *mRequest;
    NSArray<id<MCSAssetContentReader>> *_Nullable mSubreaders;
    UInt64 mReadLength;
    id<MCSResponse> mResponse;
    __weak id<MCSAssetReaderDelegate> mDelegate;
    NSData *(^mReadDataDecoder)(NSURLRequest *request, NSUInteger offset, NSData *data);
    float mNetworkTaskPriority;
    NSRange mFixedRange;
}
 
@property (nonatomic, readonly, nullable) id<MCSAssetContentReader> current;
@end

@implementation FILEAssetReader
- (instancetype)initWithAsset:(FILEAsset *)asset request:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority readDataDecoder:(NSData *(^_Nullable)(NSURLRequest *request, NSUInteger offset, NSData *data))readDataDecoder delegate:(id<MCSAssetReaderDelegate>)delegate {
    self = [super init];
    if ( self ) {
#ifdef DEBUG
        MCSAssetReaderDebugLog(@"%@: <%p>.init { URL: %@, asset: %@, headers: %@ };\n", NSStringFromClass(self.class), self, request.URL, asset, request.allHTTPHeaderFields);
#endif
        mAsset = asset;
        mRequest = request;
        mDelegate = delegate;
        mNetworkTaskPriority = networkTaskPriority;
        mReadDataDecoder = readDataDecoder;
        mCurrentIndex = NSNotFound;
        mFixedRange = MCSNSRangeUndefined;
        [mAsset readwriteRetain];
    }
    return self;
}

- (void)dealloc {
    mcs_queue_sync(^{
        mDelegate = nil;
        [mObservers removeAllObjects];
        [self _abortWithError:nil];
        MCSAssetReaderDebugLog(@"%@: <%p>.dealloc;\n", NSStringFromClass(self.class), self);
    });
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:<%p> { request: %@\n };", NSStringFromClass(self.class), self, mRequest.mcs_description];
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
            case MCSReaderStatusUnknown: {
                mStatus = MCSReaderStatusPreparing;
                MCSAssetReaderDebugLog(@"%@: <%p>.prepare { asset: %@ };\n", NSStringFromClass(self.class), self, mAsset.name);
                [self _notifyObserversWithStatus:mStatus];
                [self _prepare];
            }
                break;
        }
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
                id<MCSAssetContentReader> current = self.current;
                if ( current.status != MCSReaderStatusReadyToRead )
                    return;
                data = [current readDataOfLength:length];
                NSUInteger readLength = data.length;
                if ( mReadDataDecoder != nil )
                    data = mReadDataDecoder(mRequest, mSubreaders.firstObject.range.location + mReadLength, data);
                mReadLength += readLength;
                
                if ( current.status == MCSReaderStatusFinished )
                    [self _prepareNextReader];
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
                for ( NSInteger i = 0 ; i < mSubreaders.count ; ++ i ) {
                    id<MCSAssetContentReader> reader = mSubreaders[i];
                    if ( NSLocationInRange(offset - 1, reader.range) ) {
                        mCurrentIndex = i;
                        result = [reader seekToOffset:offset];
                        if ( result ) {
                            mReadLength = offset - mResponse.range.location;
                            if ( reader.status == MCSReaderStatusFinished ) [self _prepareNextReader];
                        }
                        break;
                    }
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
        response = mResponse;
    });
    return response;
}
 
- (NSUInteger)availableLength {
    __block NSUInteger availableLength;
    mcs_queue_sync(^{
        id<MCSAssetContentReader> current = self.current;
        availableLength = current.range.location + current.availableLength;
    });
    return availableLength;
}
 
- (NSUInteger)offset {
    __block NSUInteger offset = 0;
    mcs_queue_sync(^{
        offset = mResponse.range.location + mReadLength;
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

- (float)networkTaskPriority {
    return mNetworkTaskPriority;
}

- (nullable id<MCSAssetReaderDelegate>)delegate {
    return mDelegate;
}
#pragma mark -

- (void)_prepare {
    NSUInteger totalLength = mAsset.totalLength;
    if ( totalLength == 0 ) {
        // create single sub reader to load asset total length
        NSURL *URL = mRequest.URL;
        NSMutableURLRequest *request = [mRequest mcs_requestWithRedirectURL:URL];
        mSubreaders = @[
            [MCSAssetHTTPContentReader.alloc initWithAsset:mAsset request:request networkTaskPriority:mNetworkTaskPriority dataType:MCSDataTypeFILE delegate:self]
        ];
    }
    else {
        MCSRequestContentRange requestRange = MCSRequestGetContentRange(mRequest.mcs_headers);
        NSRange fixed = NSMakeRange(0, 0);
        // 200
        if      ( requestRange.start == NSNotFound && requestRange.end == NSNotFound ) {
            fixed = NSMakeRange(0, totalLength);
        }
        // bytes=100-500
        else if ( requestRange.start != NSNotFound && requestRange.end != NSNotFound ) {
            NSUInteger location = requestRange.start;
            NSUInteger length = (totalLength > requestRange.end ? (requestRange.end + 1) : totalLength) - location;
            fixed = NSMakeRange(location, length);
        }
        // bytes=-500
        else if ( requestRange.start == NSNotFound && requestRange.end != NSNotFound ) {
            NSUInteger length = totalLength > requestRange.end ? (requestRange.end + 1) : 0;
            NSUInteger location = totalLength - length;
            fixed = NSMakeRange(location, length);
        }
        // bytes=500-
        else if ( requestRange.start != NSNotFound && requestRange.end == NSNotFound ) {
            NSUInteger location = requestRange.start;
            NSUInteger length = totalLength > location ? (totalLength - location) : 0;
            fixed = NSMakeRange(location, length);
        }
        
        if ( fixed.length == 0 ) {
            [self _abortWithError:[NSError mcs_errorWithCode:MCSInvalidRequestError userInfo:@{
                MCSErrorUserInfoObjectKey : mRequest,
                MCSErrorUserInfoReasonKey : @"请求range参数错误!"
            }]];
            return;
        }
        
        __block NSRange curr = fixed;
        NSMutableArray<id<MCSAssetContentReader>> *subreaders = NSMutableArray.array;
        [mAsset enumerateContentNodesUsingBlock:^(id<FILEAssetContentNode>  _Nonnull node, BOOL * _Nonnull stop) {
            id<MCSAssetContent> content = node.longestContent;
            NSRange available = NSMakeRange(content.startPositionInAsset, content.length);
            NSRange intersection = NSIntersectionRange(curr, available);
            if ( intersection.length != 0 ) {
                // undownloaded part
                NSRange leftRange = NSMakeRange(curr.location, intersection.location - curr.location);
                if ( leftRange.length != 0 ) {
                    MCSAssetHTTPContentReader *reader = [self _HTTPContentReaderWithRange:leftRange];
                    [subreaders addObject:reader];
                }
                
                // downloaded part
                NSRange matchedRange = NSMakeRange(NSMaxRange(leftRange), intersection.length);
                MCSAssetFileContentReader *reader = [MCSAssetFileContentReader.alloc initWithAsset:mAsset fileContent:content rangeInAsset:matchedRange delegate:self];
                [subreaders addObject:reader];
                
                // next part
                curr = NSMakeRange(NSMaxRange(intersection), NSMaxRange(fixed) - NSMaxRange(intersection));
            }
            
            // stop
            if ( curr.length == 0 || available.location > NSMaxRange(curr) ) {
                *stop = YES;
            }
        }];
        
        if ( curr.length != 0 ) {
            // undownloaded part
            MCSAssetHTTPContentReader *reader = [self _HTTPContentReaderWithRange:curr];
            [subreaders addObject:reader];
        }
         
        mSubreaders = subreaders.copy;
        mFixedRange = fixed;
    }
     
    MCSAssetReaderDebugLog(@"%@: <%p>.createSubreaders { count: %lu };\n", NSStringFromClass(self.class), self, (unsigned long)mSubreaders.count);

    [self _prepareNextReader];
}

- (void)_prepareNextReader {
    if ( self.current == mSubreaders.lastObject ) {
        [self _finish];
        return;
    }
    
    if ( mCurrentIndex == NSNotFound )
        mCurrentIndex = 0;
    else
        mCurrentIndex += 1;
    
    MCSAssetReaderDebugLog(@"%@: <%p>.subreader.prepare { index: %ld, sub: %@, count: %lu };\n", NSStringFromClass(self.class), self, (long)mCurrentIndex, self.current, (unsigned long)mSubreaders.count);

    [self.current prepare];
}

- (nullable id<MCSAssetContentReader>)current {
    if ( mCurrentIndex != NSNotFound && mCurrentIndex < mSubreaders.count ) {
        return mSubreaders[mCurrentIndex];
    }
    return nil;
}

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
            [mDelegate reader:self didAbortWithError:error];
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
    [mSubreaders makeObjectsPerformSelector:@selector(abortWithError:) withObject:nil];
    mSubreaders = nil;

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
  
#pragma mark - MCSAssetContentReaderDelegate

- (void)readerWasReadyToRead:(id<MCSAssetContentReader>)reader {
    mcs_queue_sync(^{
        switch ( mStatus ) {
            default:break;
                // first reader
            case MCSReaderStatusPreparing: {
                id<MCSAssetContentReader> first = reader;
                NSRange range = mSubreaders.count == 1 ? first.range : mFixedRange;
                mResponse = [MCSResponse.alloc initWithTotalLength:mAsset.totalLength range:range contentType:mAsset.contentType];
                mStatus = MCSReaderStatusReadyToRead;
                [mDelegate reader:self didReceiveResponse:mResponse];
                [self _notifyObserversWithStatus:mStatus];
            }
                break;
        }
    });
}

- (void)reader:(id<MCSAssetContentReader>)reader hasAvailableDataWithLength:(NSUInteger)length {
    [mDelegate reader:self hasAvailableDataWithLength:length];
}

- (void)reader:(id<MCSAssetContentReader>)reader didAbortWithError:(NSError *)error {
    mcs_queue_sync(^{
        [self _abortWithError:error];
    });
}

- (MCSAssetHTTPContentReader *)_HTTPContentReaderWithRange:(NSRange)range {
    NSMutableURLRequest *request = [mRequest mcs_requestWithRange:range];
    return [MCSAssetHTTPContentReader.alloc initWithAsset:mAsset request:request networkTaskPriority:mNetworkTaskPriority dataType:MCSDataTypeFILE delegate:self];
}
@end
