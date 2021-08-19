//
//  MCSAssetContent.m
//  SJMediaCacheServer
//
//  Created by 畅三江 on 2021/7/19.
//

#import "MCSAssetContent.h"
#import "NSFileHandle+MCS.h"
#import "NSFileManager+MCS.h"
#import "MCSQueue.h"
#import "MCSUtils.h"
 
@implementation MCSAssetContent {
    NSString *mFilepath;
    UInt64 mLength;
    UInt64 mStartPositionInAsset;
    NSHashTable<id<MCSAssetContentObserver>> *_Nullable mObservers;

    NSFileHandle *_Nullable mWriter;
    NSFileHandle *_Nullable mReader;
}

- (instancetype)initWithFilepath:(NSString *)filepath startPositionInAsset:(UInt64)position length:(UInt64)length {
    self = [super init];
    if ( self ) {
        mFilepath = filepath;
        mStartPositionInAsset = position;
        mLength = length;
    }
    return self;
}

- (instancetype)initWithFilepath:(NSString *)filepath startPositionInAsset:(UInt64)position {
    return [self initWithFilepath:filepath startPositionInAsset:position length:0];
}

- (NSString *)description {
    __block NSString *description = nil;
    mcs_queue_sync(^{
        description = [NSString stringWithFormat:@"%@: <%p> { startPosisionInAsset: %llu, lenth: %llu, readwriteCount: %ld, filepath: %@ };\n", NSStringFromClass(self.class), self, mStartPositionInAsset, mLength, (long)self.readwriteCount, mFilepath];
    });
    return description;
}

- (void)dealloc {
    mcs_queue_sync(^{
        [self closeWrite];
        [self closeRead];
    });
}

- (void)registerObserver:(id<MCSAssetContentObserver>)observer {
    if ( !observer ) return;
    mcs_queue_sync(^{
        if ( mObservers == nil ) {
            mObservers = NSHashTable.weakObjectsHashTable;
        }
        [mObservers addObject:observer];
    });
}

- (void)removeObserver:(id<MCSAssetContentObserver>)observer {
    mcs_queue_sync(^{
        [mObservers removeObject:observer];
    });
}

- (nullable NSData *)readDataAtPosition:(UInt64)posInAsset capacity:(UInt64)capacity error:(out NSError **)errorPtr {
    __block NSData *data = nil;
    __block NSError *error = nil;
    mcs_queue_sync(^{
        if ( posInAsset < mStartPositionInAsset )
            return;
        
        UInt64 endPos = mStartPositionInAsset + mLength;
        if ( posInAsset >= endPos )
            return;
        
        if ( mReader == nil )
            mReader = [NSFileHandle mcs_fileHandleForReadingFromURL:[NSURL fileURLWithPath:mFilepath] error:&error];
        if ( mReader == nil )
            return;
        
        if ( ![mReader mcs_seekToOffset:posInAsset - mStartPositionInAsset error:&error] )
            return;
        
        data = [mReader mcs_readDataUpToLength:capacity error:&error];
    });
    
    if ( error != nil && errorPtr != NULL)
        *errorPtr = error;
    return data;
}

- (UInt64)startPositionInAsset {
    return mStartPositionInAsset;
}

- (UInt64)length {
    __block UInt64 length = 0;
    mcs_queue_sync(^{
        length = mLength;
    });
    return length;
}

- (NSString *)filepath {
    return mFilepath;
}

#pragma mark - mark

- (BOOL)writeData:(NSData *)data error:(out NSError **)errorPtr {
    __block NSError *error = nil;
    mcs_queue_sync(^{
        if ( mWriter == nil ) {
            mWriter = [NSFileHandle mcs_fileHandleForWritingToURL:[NSURL fileURLWithPath:mFilepath] error:&error];
            if ( mWriter != nil && ![mWriter mcs_seekToEndReturningOffset:NULL error:&error] ) {
                [mWriter mcs_closeAndReturnError:NULL];
                mWriter = nil;
            }
        }
        
        if ( mWriter == nil )
            return;
        
        if ( ![mWriter mcs_writeData:data error:&error] )
            return;
        
        UInt64 length = data.length;
        mLength += length;
        mcs_queue_async(^{
            for ( id<MCSAssetContentObserver> observer in MCSAllHashTableObjects(self->mObservers)) {
                [observer content:self didWriteDataWithLength:length];
            }
        });
    });
    
    if ( error != nil && errorPtr != NULL)
        *errorPtr = error;
    return error == nil;
}

///
/// 读取计数为0时才会生效
///
- (void)closeWrite {
    mcs_queue_sync(^{
        if ( self.readwriteCount == 0 && mWriter != nil ) {
            [mWriter mcs_synchronizeAndReturnError:NULL];
            [mWriter mcs_closeAndReturnError:NULL];
            mWriter = nil;
        }
    });
}

///
/// 读取计数为0时才会生效
///
- (void)closeRead {
    mcs_queue_sync(^{
        if ( self.readwriteCount == 0 && mReader != nil ) {
            [mReader mcs_closeAndReturnError:NULL];
            mReader = nil;
        }
    });
}

///
/// 读取计数为0时才会生效
///
- (void)close {
    [self closeWrite];
    [self closeRead];
}
@end
