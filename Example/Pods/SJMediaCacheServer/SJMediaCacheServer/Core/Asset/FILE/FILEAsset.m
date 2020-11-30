//
//  MCSAsset.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/2.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "FILEAsset.h"
#import "FILEContentProvider.h"
#import "MCSUtils.h"
#import "MCSConsts.h"
#import "MCSConfiguration.h"
#import "MCSRootDirectory.h"

static NSString *kLength = @"length";
static NSString *kReadwriteCount = @"readwriteCount";
static dispatch_queue_t mcs_queue;

@interface FILEAsset () {
    FILEContentProvider *_provider;
    NSMutableArray<FILEContent *> *_contents;
}
@property (nonatomic) NSInteger id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy, nullable) NSString *pathExtension;
@property (nonatomic, copy, nullable) NSString *contentType;
@property (nonatomic) NSUInteger totalLength;
@end

@implementation FILEAsset
@synthesize id = _id;
@synthesize name = _name;
@synthesize readwriteCount = _readwriteCount;
@synthesize configuration = _configuration;
@synthesize isStored = _isStored;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mcs_queue = dispatch_queue_create("queue.FILEAsset", DISPATCH_QUEUE_CONCURRENT);
    });
}

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
    NSParameterAssert(self.name != nil);
    NSString *directory = [MCSRootDirectory assetPathForFilename:self.name];
    _configuration = MCSConfiguration.alloc.init;
    _provider = [FILEContentProvider contentProviderWithDirectory:directory];
    _contents = [(_provider.contents ?: @[]) mutableCopy];
    [self _mergeContents];
}

- (NSString *)path {
    return [MCSRootDirectory assetPathForFilename:_name];
}

#pragma mark - mark

- (MCSAssetType)type {
    return MCSAssetTypeFILE;
}

- (nullable NSArray<FILEContent *> *)contents {
    __block NSArray<FILEContent *> *contents;
    dispatch_sync(mcs_queue, ^{
        contents = _contents;
    });
    return contents;
}

- (BOOL)isStored {
    __block BOOL isStored = NO;
    dispatch_sync(mcs_queue, ^{
        isStored = _isStored;
    });
    return isStored;
}

- (nullable NSString *)pathExtension {
    __block NSString *pathExtension = nil;
    dispatch_sync(mcs_queue, ^{
        pathExtension = _pathExtension;
    });
    return pathExtension;
}

- (nullable NSString *)contentType {
    __block NSString *contentType = nil;
    dispatch_sync(mcs_queue, ^{
        contentType = _contentType;
    });
    return contentType;
}

- (NSUInteger)totalLength {
    __block NSUInteger totalLength = 0;
    dispatch_sync(mcs_queue, ^{
        totalLength = _totalLength;
    });
    return totalLength;
}

- (nullable FILEContent *)createContentWithResponse:(NSHTTPURLResponse *)response {
    NSString *pathExtension = MCSSuggestedFilePathExtension(response);
    NSString *contentType = MCSGetResponseContentType(response);
    MCSResponseContentRange range = MCSGetResponseContentRange(response);
    NSUInteger totalLength = range.totalLength;
    NSUInteger offset = range.start;
    __block FILEContent *content = nil;
    __block BOOL isUpdated = NO;
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _totalLength != totalLength || ![_pathExtension isEqualToString:pathExtension] || ![_contentType isEqualToString:contentType] ) {
            _totalLength = totalLength;
            _pathExtension = pathExtension;
            _contentType = contentType;
            isUpdated = YES;
        }
        
        content = [_provider createContentAtOffset:offset pathExtension:_pathExtension];
        [_contents addObject:content];
    });
    
    if ( isUpdated )
        [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetMetadataDidLoadNotification object:self];
    return content;
}

- (nullable NSString *)contentFilePathForFilename:(NSString *)filename {
    return [_provider contentFilePathForFilename:filename];
}

#pragma mark - readwrite

- (NSInteger)readwriteCount {
    __block NSInteger readwriteCount = 0;
    dispatch_sync(mcs_queue, ^{
        readwriteCount = _readwriteCount;
    });
    return readwriteCount;
}

- (void)readwriteRetain {
    [self willChangeValueForKey:kReadwriteCount];
    dispatch_barrier_sync(mcs_queue, ^{
        _readwriteCount += 1;
    });
    [self didChangeValueForKey:kReadwriteCount];
}

- (void)readwriteRelease {
    [self willChangeValueForKey:kReadwriteCount];
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _readwriteCount > 0 ) {
            _readwriteCount -= 1;
        }
    });
    [self didChangeValueForKey:kReadwriteCount];
    [self _mergeContents];
}

// 合并文件
- (void)_mergeContents {
    dispatch_barrier_sync(mcs_queue, ^{
        if ( _readwriteCount != 0 ) return;
        if ( _isStored ) return;
        if ( _contents.count < 2 ) {
            _isStored = _contents.count == 1 && _contents.lastObject.length == _totalLength;
            return;
        }
        
        NSMutableArray<FILEContent *> *contents = NSMutableArray.alloc.init;
        for ( FILEContent *content in _contents ) { if ( content.readwriteCount == 0 ) [contents addObject:content]; }
        
        if ( contents.count == 0 ) return;
        
        NSMutableArray<FILEContent *> *deletes = NSMutableArray.alloc.init;
        [contents sortUsingComparator:^NSComparisonResult(FILEContent *obj1, FILEContent *obj2) {
            NSRange range1 = NSMakeRange(obj1.offset, obj1.length);
            NSRange range2 = NSMakeRange(obj2.offset, obj2.length);
            
            // 1 包含 2
            if ( MCSNSRangeContains(range1, range2) ) {
                if ( ![deletes containsObject:obj2] ) [deletes addObject:obj2];
            }
            // 2 包含 1
            else if ( MCSNSRangeContains(range2, range1) ) {
                if ( ![deletes containsObject:obj1] ) [deletes addObject:obj1];;
            }
            
            return range1.location < range2.location ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        if ( deletes.count != 0 ) [contents removeObjectsInArray:deletes];
        
        // merge
        for ( NSInteger i = 0 ; i < contents.count - 1; i += 2 ) {
            FILEContent *write = contents[i];
            FILEContent *read  = contents[i + 1];
            
            NSUInteger maxRange1 = write.offset + write.length;
            NSUInteger maxRange2 = read.offset + read.length;
            NSRange readRange = NSMakeRange(0, 0);
            if ( maxRange1 >= read.offset && maxRange1 < maxRange2 ) // 有交集
                readRange = NSMakeRange(maxRange1 - read.offset, maxRange2 - maxRange1); // 读取read中未相交的部分
            
            if ( readRange.length != 0 ) {
                NSFileHandle *writer = nil;
                NSFileHandle *reader = nil;
                @try {
                    writer = [NSFileHandle fileHandleForWritingAtPath:[self contentFilePathForFilename:write.filename]];
                    reader = [NSFileHandle fileHandleForReadingAtPath:[self contentFilePathForFilename:read.filename]];
                    [writer seekToEndOfFile];
                    [reader seekToFileOffset:readRange.location];
                    while (true) {
                        @autoreleasepool {
                            NSData *data = [reader readDataOfLength:1024 * 1024 * 1];
                            if ( data.length == 0 )
                                break;
                            [writer writeData:data];
                        }
                    }
                    [write didWriteDataWithLength:readRange.length];
                    [deletes addObject:read];
                } @catch (__unused NSException *exception) {
                    
                }
                @finally {
                    if ( reader != nil ) {
                        [reader closeFile];
                    }
                    
                    if ( writer != nil ) {
                        [writer synchronizeFile];
                        [writer closeFile];
                    }
                }
            }
        }
        
        if ( deletes.count != 0 ) {
            for ( FILEContent *content in deletes ) { [_provider removeContentForFilename:content.filename]; }
            [_contents removeObjectsInArray:deletes];
        }
        
        _isStored = _contents.count == 1 && _contents.lastObject.length == _totalLength;
    });
}
@end
