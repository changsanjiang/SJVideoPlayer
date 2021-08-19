//
//  MCSAsset.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "FILEAsset.h"
#import "FILEAssetContentProvider.h"
#import "MCSUtils.h"
#import "MCSConsts.h"
#import "MCSConfiguration.h"
#import "MCSRootDirectory.h"
#import "NSFileHandle+MCS.h"
#import "MCSQueue.h"

@interface FILEAsset () {
    FILEAssetContentProvider *mProvider;
    NSMutableArray<id<MCSAssetContent>> *mContents;
    BOOL mIsPrepared;
}

@property (nonatomic) NSInteger id; // saveable
@property (nonatomic, copy) NSString *name; // saveable
@property (nonatomic, copy, nullable) NSString *pathExtension; // saveable
@property (nonatomic, copy, nullable) NSString *contentType; // saveable
@property (nonatomic) NSUInteger totalLength;  // saveable
@end

@implementation FILEAsset
@synthesize id = _id;
@synthesize name = _name;
@synthesize configuration = _configuration;
@synthesize isStored = _isStored;

+ (NSString *)sql_primaryKey {
    return @"id";
}

+ (NSArray<NSString *> *)sql_autoincrementlist {
    return @[@"id"];
}

+ (NSArray<NSString *> *)sql_blacklist {
    return @[@"readwriteCount", @"isStored", @"configuration", @"contents", @"provider"];
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if ( self ) {
        _name = name.copy;
    }
    return self;
}

- (void)prepare {
    mcs_queue_sync(^{
        NSParameterAssert(self.name != nil);
        if ( mIsPrepared ) return;
        mIsPrepared = YES;
        NSString *directory = [MCSRootDirectory assetPathForFilename:self.name];
        _configuration = MCSConfiguration.alloc.init;
        mProvider = [FILEAssetContentProvider contentProviderWithDirectory:directory];
        mContents = [(mProvider.contents ?: @[]) mutableCopy];
        [self _mergeContents];
    });
}

- (NSString *)path {
    return [MCSRootDirectory assetPathForFilename:_name];
}

#pragma mark - mark

- (MCSAssetType)type {
    return MCSAssetTypeFILE;
}

- (nullable NSArray<id<MCSAssetContent>> *)contents {
    __block NSArray<id<MCSAssetContent>> *contents;
    mcs_queue_sync(^{
        contents = mContents.copy;
    });
    return contents;
}

- (BOOL)isStored {
    __block BOOL isStored = NO;
    mcs_queue_sync(^{
        isStored = _isStored;
    });
    return isStored;
}

- (nullable NSString *)filepathForContent:(id<MCSAssetContent>)content {
    return [mProvider contentFilepath:content];
}

- (nullable NSString *)pathExtension {
    __block NSString *pathExtension = nil;
    mcs_queue_sync(^{
        pathExtension = _pathExtension;
    });
    return pathExtension;
}

- (nullable NSString *)contentType {
    __block NSString *contentType = nil;
    mcs_queue_sync(^{
        contentType = _contentType;
    });
    return contentType;
}

- (NSUInteger)totalLength {
    __block NSUInteger totalLength = 0;
    mcs_queue_sync(^{
        totalLength = _totalLength;
    });
    return totalLength;
}

/// 该操作将会对 content 进行一次 readwriteRetain, 请在不需要时, 调用一次 readwriteRelease.
- (nullable id<MCSAssetContent>)createContentReadwriteWithDataType:(MCSDataType)dataType response:(id<MCSDownloadResponse>)response {
    switch ( dataType ) {
        case MCSDataTypeHLSMask:
        case MCSDataTypeHLSPlaylist:
        case MCSDataTypeHLSAESKey:
        case MCSDataTypeHLSTs:
        case MCSDataTypeHLS:
        case MCSDataTypeFILEMask:
            /* return */
            return nil;
        case MCSDataTypeFILE:
            break;
    }
    NSString *pathExtension = response.pathExtension;
    NSString *contentType = response.contentType;
    NSUInteger totalLength = response.totalLength;
    NSUInteger offset = response.range.location;
    __block id<MCSAssetContent>content = nil;
    __block BOOL isUpdated = NO;
    mcs_queue_sync(^{
        if ( _totalLength != totalLength || ![_pathExtension isEqualToString:pathExtension] || ![_contentType isEqualToString:contentType] ) {
            _totalLength = totalLength;
            _pathExtension = pathExtension;
            _contentType = contentType;
            isUpdated = YES;
        }
        
        content = [mProvider createContentAtOffset:offset pathExtension:_pathExtension];
        [content readwriteRetain];
        if ( content != nil ) [mContents addObject:content];
    });
    
    if ( isUpdated )
        [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetMetadataDidLoadNotification object:self];
    return content;
}

- (void)readwriteCountDidChange:(NSInteger)count {
    if ( count == 0 )
        [self _mergeContents];
}

// 合并文件
- (void)_mergeContents {
    if ( self.readwriteCount != 0 ) return;
    if ( _isStored ) return;
    if ( mContents.count < 2 ) {
        _isStored = mContents.count == 1 && mContents.lastObject.length == _totalLength;
        return;
    }
     
    NSMutableArray<id<MCSAssetContent>> *contents = [mContents mutableCopy];
    NSMutableArray<id<MCSAssetContent>> *deletes = NSMutableArray.alloc.init;
    [contents sortUsingComparator:^NSComparisonResult(id<MCSAssetContent>obj1, id<MCSAssetContent>obj2) {
        NSRange range1 = NSMakeRange(obj1.startPositionInAsset, obj1.length);
        NSRange range2 = NSMakeRange(obj2.startPositionInAsset, obj2.length);
        
        // 1 包含 2
        if ( MCSNSRangeContains(range1, range2) ) {
            if ( ![deletes containsObject:obj2] ) [deletes addObject:obj2];
        }
        // 2 包含 1
        else if ( MCSNSRangeContains(range2, range1) ) {
            if ( ![deletes containsObject:obj1] ) [deletes addObject:obj1];;
        }
        
        return [@(range1.location) compare:@(range2.location)];
    }];
    
    if ( deletes.count != 0 ) [contents removeObjectsInArray:deletes];
    
    // merge
    UInt64 capacity = 1 * 1024 * 1024;
    for ( NSInteger i = 0 ; i < contents.count - 1; i += 2 ) {
        id<MCSAssetContent>write = contents[i];
        id<MCSAssetContent>read  = contents[i + 1];
        
        NSUInteger maxPosition1 = write.startPositionInAsset + write.length;
        NSUInteger maxPosition2 = read.startPositionInAsset + read.length;
        NSRange readRange = NSMakeRange(0, 0);
        if ( maxPosition1 >= read.startPositionInAsset && maxPosition1 < maxPosition2 ) // 有交集
            readRange = NSMakeRange(maxPosition1, maxPosition2 - maxPosition1); // 读取read中未相交的部分
        
        if ( readRange.length != 0 ) {
            [write readwriteRetain];
            [read readwriteRetain];
            NSError *error = nil;
            UInt64 positon = readRange.location;
            while ( true ) { @autoreleasepool {
                NSData *data = [read readDataAtPosition:positon capacity:capacity error:&error];
                if ( error != nil || data.length == 0 )
                    break;
                if ( ![write writeData:data error:&error] )
                    break;
                positon += data.length;
                if ( positon == NSMaxRange(readRange) ) break;
            }}
            [read readwriteRelease];
            [write readwriteRelease];
            [read closeRead];
            [write closeWrite];
            if ( error == nil ) {
                [deletes addObject:read];
            }
        }
    }
    
    if ( deletes.count != 0 ) {
        for ( id<MCSAssetContent>content in deletes ) { [mProvider removeContent:content]; }
        [mContents removeObjectsInArray:deletes];
    }
    
    _isStored = mContents.count == 1 && mContents.lastObject.length == _totalLength;
}
@end
