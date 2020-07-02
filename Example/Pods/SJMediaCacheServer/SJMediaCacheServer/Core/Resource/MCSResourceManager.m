//
//  MCSResourceManager.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSResourceManager.h"
#import "MCSResource.h"
#import "MCSResourceSubclass.h"
#import "MCSResourceUsageLog.h"

#import "MCSResourcePartialContent.h"
#import "MCSVODReader.h"
#import "MCSVODResource.h"
 
#import "MCSHLSReader.h"
#import "MCSHLSResource.h"
#import "MCSFileManager.h"

#import <SJUIKit/SJSQLite3.h>
#import <SJUIKit/SJSQLite3+Private.h>
#import <SJUIKit/SJSQLite3+QueryExtended.h>
#import <SJUIKit/SJSQLite3+RemoveExtended.h>

NSNotificationName const MCSResourceManagerDidRemoveResourceNotification = @"MCSResourceManagerDidRemoveResourceNotification";
NSNotificationName const MCSResourceManagerUserCancelledReadingNotification = @"MCSResourceManagerUserCancelledReadingNotification";
NSString *MCSResourceManagerUserInfoResourceKey = @"resource";

typedef NS_ENUM(NSUInteger, MCSLimit) {
    MCSLimitNone,
    MCSLimitCount,
    MCSLimitCacheDiskSpace,
    MCSLimitFreeDiskSpace,
    MCSLimitExpires,
};

@interface MCSResourceUsageLog (MCSPrivate)
@property (nonatomic) NSInteger id;
@property (nonatomic) NSUInteger usageCount;

@property (nonatomic) NSTimeInterval updatedTime;
@property (nonatomic) NSTimeInterval createdTime;

@property (nonatomic) NSInteger resource;
@property (nonatomic) MCSResourceType resourceType;
@end

@interface MCSResourceUsageLog (MCSResourceManagerExtended)<SJSQLiteTableModelProtocol>
@end

@implementation MCSResourceUsageLog (MCSResourceManagerExtended)
- (instancetype)initWithResource:(MCSResource *)resource {
    self = [super init];
    if ( self ) {
        self.resource = resource.id;
        self.resourceType = resource.type;
        self.updatedTime = self.createdTime = NSDate.date.timeIntervalSince1970;
    }
    return self;
}

+ (NSString *)sql_primaryKey {
    return @"id";
}

+ (NSArray<NSString *> *)sql_autoincrementlist {
    return @[@"id"];
}
@end


@interface MCSResource (MCSResourceManagerExtended)<SJSQLiteTableModelProtocol>
@end

@implementation MCSResource (MCSResourceManagerExtended)
+ (NSString *)sql_primaryKey {
    return @"id";
}

+ (NSArray<NSString *> *)sql_autoincrementlist {
    return @[@"id"];
}

+ (NSArray<NSString *> *)sql_blacklist {
    return @[@"readWriteCount", @"isCacheFinished", @"playbackURLForCache"];
}
@end


@interface SJSQLite3Condition (MCSResourceManagerExtended)
+ (instancetype)mcs_conditionWithColumn:(NSString *)column notIn:(NSArray *)values;
@end

@implementation SJSQLite3Condition (MCSResourceManagerExtended)
+ (instancetype)mcs_conditionWithColumn:(NSString *)column notIn:(NSArray *)values {
    NSMutableString *conds = NSMutableString.new;
    [conds appendFormat:@"\"%@\" NOT IN (", column];
    id last = values.lastObject;
    for ( id value in values ) {
        [conds appendFormat:@"'%@'%@", sj_sqlite3_obj_filter_obj_value(value), last!=value?@",":@""];
    }
    [conds appendString:@")"];
    return [[SJSQLite3Condition alloc] initWithCondition:conds];
}
@end


#pragma mark -

@interface MCSResourceManager ()<NSLocking> {
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic, strong) NSMutableDictionary<NSString *, MCSResource *> *resources;
@property (nonatomic, strong) SJSQLite3 *sqlite3;
@property (nonatomic) NSUInteger count;

@property (nonatomic) NSUInteger freeDiskSpace;
@property (nonatomic) NSUInteger cacheDiskSpace;
@end

@implementation MCSResourceManager
+ (instancetype)shared {
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _semaphore = dispatch_semaphore_create(1);
        _sqlite3 = [SJSQLite3.alloc initWithDatabasePath:[MCSFileManager databasePath]];
        _count = [_sqlite3 countOfObjectsForClass:MCSResourceUsageLog.class conditions:nil error:NULL];
        _resources = NSMutableDictionary.dictionary;
        // 获取磁盘剩余空间, 以及所有资源已占空间大小
        _freeDiskSpace = [MCSFileManager systemFreeSize];
        _cacheDiskSpace = [MCSFileManager rootDirectorySize];
    }
    return self;
}

#pragma mark -

@synthesize cacheCountLimit = _cacheCountLimit;
- (void)setCacheCountLimit:(NSUInteger)cacheCountLimit {
    [self lock];
    @try {
        if ( _cacheCountLimit != cacheCountLimit ) {
            _cacheCountLimit = cacheCountLimit;
            if ( cacheCountLimit != 0 ) {
                [self _removeResourcesForLimit:MCSLimitCount];
            }
        }
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSUInteger)cacheCountLimit {
    [self lock];
    @try {
        return _cacheCountLimit;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

@synthesize maxDiskAgeForCache = _maxDiskAgeForCache;
- (void)setMaxDiskAgeForCache:(NSTimeInterval)maxDiskAgeForCache {
    [self lock];
    @try {
        if ( maxDiskAgeForCache != _maxDiskAgeForCache ) {
            _maxDiskAgeForCache = maxDiskAgeForCache;
            if ( maxDiskAgeForCache != 0 ) {
                [self _removeResourcesForLimit:MCSLimitExpires];
            }
        }
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSTimeInterval)maxDiskAgeForCache {
    [self lock];
    @try {
        return _maxDiskAgeForCache;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

@synthesize maxDiskSizeForCache = _maxDiskSizeForCache;
- (void)setMaxDiskSizeForCache:(NSUInteger)maxDiskSizeForCache {
    [self lock];
    @try {
        if ( _maxDiskSizeForCache != maxDiskSizeForCache ) {
            _maxDiskSizeForCache = maxDiskSizeForCache;
            if ( maxDiskSizeForCache != 0 ) {
                [self _removeResourcesForLimit:MCSLimitCacheDiskSpace];
            }
        }
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}
- (NSUInteger)maxDiskSizeForCache {
    [self lock];
    @try {
        return _maxDiskSizeForCache;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

@synthesize reservedFreeDiskSpace = _reservedFreeDiskSpace;
- (void)setReservedFreeDiskSpace:(NSUInteger)reservedFreeDiskSpace {
    [self lock];
    @try {
        if ( reservedFreeDiskSpace != _reservedFreeDiskSpace ) {
            _reservedFreeDiskSpace = reservedFreeDiskSpace;
            if ( reservedFreeDiskSpace != 0 ) {
                [self _removeResourcesForLimit:MCSLimitFreeDiskSpace];
            }
        }
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSUInteger)reservedFreeDiskSpace {
    [self lock];
    @try {
        return _reservedFreeDiskSpace;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

#pragma mark -

- (__kindof MCSResource *)resourceWithURL:(NSURL *)URL {
    [self lock];
    @try {
        MCSResourceType type = [MCSURLRecognizer.shared resourceTypeForURL:URL];
        NSString *name = [MCSURLRecognizer.shared resourceNameForURL:URL];
        if ( _resources[name] == nil ) {
            Class cls = [self resourceClassForType:type];
            // query
            MCSResource *resource = (id)[_sqlite3 objectsForClass:cls conditions:@[
                [SJSQLite3Condition conditionWithColumn:@"name" value:name]
            ] orderBy:nil error:NULL].firstObject;
            
            // create
            if ( resource == nil ) {
                resource = [cls.alloc init];
                resource.name = name;
                [self _update:resource]; // save resource
                resource.log = [MCSResourceUsageLog.alloc initWithResource:resource];
                [self _update:resource]; // save log
                _count += 1;
            }
            
            // directory
            [MCSFileManager checkoutResourceWithName:name error:NULL];
            
            // contents
            [resource addContents:[MCSFileManager getContentsInResource:name]];
            _resources[name] = resource;
        }
        return _resources[name];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)saveMetadata:(MCSResource *)resource {
    [self lock];
    [self _update:resource];
    [self unlock];
}

- (void)cancelCurrentReadsForResource:(MCSResource *)resource {
    if ( resource.readWriteCount != 0 ) {
        [NSNotificationCenter.defaultCenter postNotificationName:MCSResourceManagerUserCancelledReadingNotification object:self userInfo:@{ MCSResourceManagerUserInfoResourceKey : resource }];
    }
}

- (id<MCSResourceReader>)readerWithRequest:(NSURLRequest *)request {
    MCSResource *resource = [self resourceWithURL:request.URL];
    id<MCSResourceReader> reader = [resource readerWithRequest:request];
    reader.readDataDecoder = _readDataDecoder;
    return reader;
}

- (void)reader:(id<MCSResourceReader>)reader willReadResource:(MCSResource *)resource {
    [self lock];
    // update
    resource.log.usageCount += 1;
    resource.log.updatedTime = NSDate.date.timeIntervalSince1970;
    [_sqlite3 update:resource.log forKeys:@[@"usageCount", @"updatedTime"] error:NULL];
    [self unlock];
}

// 读取结束, 清理剩余的超出个数限制的资源
- (void)reader:(id<MCSResourceReader>)reader didEndReadResource:(MCSResource *)resource {
    [self lock];
    @try {
        if ( _cacheCountLimit == 0 || _count < _cacheCountLimit )
            return;
        [self _removeResourcesForLimit:MCSLimitCount];
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

// 剩余磁盘空间在发生变化
- (void)didWriteDataForResource:(MCSResource *)resource length:(NSUInteger)length {
    [self lock];
    @try {
        if ( _reservedFreeDiskSpace == 0 && _maxDiskSizeForCache == 0 )
            return;
        _cacheDiskSpace += length;
        _freeDiskSpace -= length;
        [self _removeResourcesForLimit:MCSLimitFreeDiskSpace];
        [self _removeResourcesForLimit:MCSLimitCacheDiskSpace];
    } @catch (__unused NSException *exception) {

    } @finally {
        [self unlock];
    }
}

- (void)didRemoveDataForResource:(MCSResource *)resource length:(NSUInteger)length {
    [self lock];
    _cacheDiskSpace -= length;
    _freeDiskSpace += length;
    [self unlock];
}

- (void)removeAllResources {
    [self lock];
    @try {
        NSArray<MCSVODResource *> *VODResources = [_sqlite3 objectsForClass:MCSVODResource.class conditions:nil orderBy:nil error:NULL];
        [self _removeResources:VODResources];
        NSArray<MCSHLSResource *> *HLSResources = [_sqlite3 objectsForClass:MCSHLSResource.class conditions:nil orderBy:nil error:NULL];
        [self _removeResources:HLSResources];
        
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)removeResourceForURL:(NSURL *)URL {
    if ( URL == nil )
        return;
    MCSResource *resource = [self resourceWithURL:URL];
    [self lock];
    [self _removeResources:@[resource]];
    [self unlock];
}

- (NSUInteger)cachedSizeForResources {
    return [MCSFileManager rootDirectorySize];
}

#pragma mark -

- (void)_removeResourcesForLimit:(MCSLimit)limit {
    switch ( limit ) {
        case MCSLimitNone:
            break;
        case MCSLimitCount: {
            if ( _cacheCountLimit == 0 )
                return;
            
            if ( _count == 1 )
                return;
            
            // 资源数量少于限制的个数
            if ( _cacheCountLimit > _count )
                return;
        }
            break;
        case MCSLimitFreeDiskSpace: {
            if ( _reservedFreeDiskSpace == 0 )
                return;
            
            if ( _freeDiskSpace > _reservedFreeDiskSpace )
                return;
        }
            break;
        case MCSLimitExpires: {
            if ( _maxDiskAgeForCache == 0 )
                return;
        }
            break;
        case MCSLimitCacheDiskSpace: {
            if ( _maxDiskSizeForCache == 0 )
                return;
            
            // 获取已缓存的数据大小
            if ( _maxDiskSizeForCache > _cacheDiskSpace )
                return;
        }
            break;
    }
    
    NSMutableArray<NSNumber *> *usingResources = NSMutableArray.alloc.init;
    [_resources enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MCSResource * _Nonnull obj, BOOL * _Nonnull stop) {
        if ( obj.readWriteCount > 0 )
            [usingResources addObject:@(obj.id)];
    }];

    // 全部处于使用中
    if ( usingResources.count == _count )
        return;

    NSArray<MCSResourceUsageLog *> *logs = nil;
    switch ( limit ) {
        case MCSLimitNone:
            break;
        case MCSLimitCount:
        case MCSLimitCacheDiskSpace:
        case MCSLimitFreeDiskSpace: {
            // 清理60s之前的
            NSTimeInterval before = NSDate.date.timeIntervalSince1970 - 60;
            // 清理一半
            NSInteger length = (NSInteger)ceil((_count - usingResources.count) * 0.5);
            logs = [_sqlite3 objectsForClass:MCSResourceUsageLog.class conditions:@[
                // 检索60s之前未被使用的资源
                [SJSQLite3Condition mcs_conditionWithColumn:@"resource" notIn:usingResources],
                [SJSQLite3Condition conditionWithColumn:@"updatedTime" relatedBy:SJSQLite3RelationLessThanOrEqual value:@(before)],
            ] orderBy:@[
                // 按照更新的时间与使用次数进行排序
                [SJSQLite3ColumnOrder orderWithColumn:@"updatedTime" ascending:YES],
                [SJSQLite3ColumnOrder orderWithColumn:@"usageCount" ascending:YES],
            ] range:NSMakeRange(0, length) error:NULL];
        }
            break;
        case MCSLimitExpires: {
            NSTimeInterval time = NSDate.date.timeIntervalSince1970 - _maxDiskAgeForCache;
            logs = [_sqlite3 objectsForClass:MCSResourceUsageLog.class conditions:@[
                [SJSQLite3Condition mcs_conditionWithColumn:@"resource" notIn:usingResources],
                [SJSQLite3Condition conditionWithColumn:@"updatedTime" relatedBy:SJSQLite3RelationLessThanOrEqual value:@(time)],
            ] orderBy:nil error:NULL];
        }
            break;
    }

    if ( logs.count == 0 )
        return;

    // 删除
    NSMutableArray<MCSResource *> *results = NSMutableArray.array;
    [logs enumerateObjectsUsingBlock:^(MCSResourceUsageLog * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MCSResource *resource = [self.sqlite3 objectForClass:[self resourceClassForType:obj.resourceType] primaryKeyValue:@(obj.resource) error:NULL];
        if ( resource != nil ) [results addObject:resource];
    }];
    
    [self _removeResources:results];
}

- (void)_removeResources:(NSArray<MCSResource *> *)resources {
    if ( resources.count == 0 )
        return;

    [resources enumerateObjectsUsingBlock:^(MCSResource * _Nonnull r, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger length = [MCSFileManager fileSizeAtPath:[MCSFileManager getResourcePathWithName:r.name]];
        self->_cacheDiskSpace -= length;
        self->_freeDiskSpace += length;

        [MCSFileManager removeResourceWithName:r.name error:NULL];
        [self.resources removeObjectForKey:r.name];
        [self.sqlite3 removeObjectForClass:r.class primaryKeyValue:@(r.id) error:NULL];
        [self.sqlite3 removeAllObjectsForClass:MCSResourceUsageLog.class conditions:@[
            [SJSQLite3Condition conditionWithColumn:@"resource" value:@(r.id)],
            [SJSQLite3Condition conditionWithColumn:@"resourceType" value:@(r.type)],
        ] error:NULL];
        dispatch_async(r.readerOperationQueue, ^{
            [NSNotificationCenter.defaultCenter postNotificationName:MCSResourceManagerDidRemoveResourceNotification object:self userInfo:@{ MCSResourceManagerUserInfoResourceKey : r }];
        });
    }];
    
    _count -= resources.count;
}

- (void)_update:(MCSResource *)resource {
    if ( resource.log != nil ) resource.log.updatedTime = NSDate.date.timeIntervalSince1970;
    if ( resource != nil ) [_sqlite3 save:resource error:NULL];
}

#pragma mark -

- (void)lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(_semaphore);
}

- (Class)resourceClassForType:(MCSResourceType)type {
    return type == MCSResourceTypeVOD ? MCSVODResource.class : MCSHLSResource.class;
}
@end
