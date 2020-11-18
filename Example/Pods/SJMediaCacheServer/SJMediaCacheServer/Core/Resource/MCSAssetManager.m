//
//  MCSAssetManager.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSAssetManager.h"
#import "MCSAsset.h"
#import "MCSAssetSubclass.h"
#import "MCSAssetUsageLog.h"

#import "MCSAssetContent.h"
#import "FILEReader.h"
#import "FILEAsset.h"
 
#import "HLSReader.h"
#import "HLSAsset.h"
#import "MCSFileManager.h"

#import <SJUIKit/SJSQLite3.h>
#import <SJUIKit/SJSQLite3+Private.h>
#import <SJUIKit/SJSQLite3+QueryExtended.h>
#import <SJUIKit/SJSQLite3+RemoveExtended.h>

NSNotificationName const MCSAssetManagerDidRemoveAssetNotification = @"MCSAssetManagerDidRemoveAssetNotification";
NSNotificationName const MCSAssetManagerUserCancelledReadingNotification = @"MCSAssetManagerUserCancelledReadingNotification";
NSString *MCSAssetManagerUserInfoAssetKey = @"asset";

typedef NS_ENUM(NSUInteger, MCSLimit) {
    MCSLimitNone,
    MCSLimitCount,
    MCSLimitCacheDiskSpace,
    MCSLimitFreeDiskSpace,
    MCSLimitExpires,
};

@interface MCSAssetUsageLog (MCSPrivate)
@property (nonatomic) NSInteger id;
@property (nonatomic) NSUInteger usageCount;

@property (nonatomic) NSTimeInterval updatedTime;
@property (nonatomic) NSTimeInterval createdTime;

@property (nonatomic) NSInteger asset;
@property (nonatomic) MCSAssetType assetType;
@end

@interface MCSAssetUsageLog (MCSAssetManagerExtended)<SJSQLiteTableModelProtocol>
@end

@implementation MCSAssetUsageLog (MCSAssetManagerExtended)
- (instancetype)initWithAsset:(MCSAsset *)asset {
    self = [super init];
    if ( self ) {
        self.asset = asset.id;
        self.assetType = asset.type;
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


@interface MCSAsset (MCSAssetManagerExtended)<SJSQLiteTableModelProtocol>
@end

@implementation MCSAsset (MCSAssetManagerExtended)
+ (NSString *)sql_primaryKey {
    return @"id";
}

+ (NSArray<NSString *> *)sql_autoincrementlist {
    return @[@"id"];
}

+ (NSArray<NSString *> *)sql_blacklist {
    return @[@"readWriteCount", @"isCacheFinished", @"playbackURLForCache", @"queue"];
}
@end

#pragma mark -

@interface MCSAssetManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, MCSAsset *> *assets;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MCSAssetUsageLog *> *usageLogs;
@property (nonatomic, strong) SJSQLite3 *sqlite3;
@property (nonatomic) NSUInteger count;

@property (nonatomic) NSUInteger freeDiskSpace;
@property (nonatomic) NSUInteger cacheDiskSpace;

@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation MCSAssetManager
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
        _queue = dispatch_queue_create(NSStringFromClass(self.class).UTF8String, DISPATCH_QUEUE_CONCURRENT);
        _sqlite3 = [SJSQLite3.alloc initWithDatabasePath:[MCSFileManager databasePath]];
        _count = [_sqlite3 countOfObjectsForClass:MCSAssetUsageLog.class conditions:nil error:NULL];
        _assets = NSMutableDictionary.dictionary;
        _usageLogsSaveInterval = 30;
        // 获取磁盘剩余空间, 以及所有资源已占空间大小
        _freeDiskSpace = [MCSFileManager systemFreeSize];
        _cacheDiskSpace = [MCSFileManager rootDirectorySize];
        [self _saveRecursively];
    }
    return self;
}

#pragma mark -

@synthesize cacheCountLimit = _cacheCountLimit;
- (void)setCacheCountLimit:(NSUInteger)cacheCountLimit {
    dispatch_barrier_async(_queue, ^{
        if ( cacheCountLimit != self->_cacheCountLimit ) {
            self->_cacheCountLimit = cacheCountLimit;
            if ( cacheCountLimit != 0 ) {
                [self _removeAssetsForLimit:MCSLimitCount];
            }
        }
    });
}

- (NSUInteger)cacheCountLimit {
    __block NSUInteger cacheCountLimit = 0;
    dispatch_sync(_queue, ^{
        cacheCountLimit = self->_cacheCountLimit;
    });
    return cacheCountLimit;
}

@synthesize maxDiskAgeForCache = _maxDiskAgeForCache;
- (void)setMaxDiskAgeForCache:(NSTimeInterval)maxDiskAgeForCache {
    dispatch_barrier_async(_queue, ^{
        if ( maxDiskAgeForCache != self->_maxDiskAgeForCache ) {
            self->_maxDiskAgeForCache = maxDiskAgeForCache;
            if ( maxDiskAgeForCache != 0 ) {
                [self _removeAssetsForLimit:MCSLimitExpires];
            }
        }
    });
}

- (NSTimeInterval)maxDiskAgeForCache {
    __block NSTimeInterval maxDiskAgeForCache = 0;
    dispatch_sync(_queue, ^{
        maxDiskAgeForCache = _maxDiskAgeForCache;
    });
    return maxDiskAgeForCache;
}

@synthesize maxDiskSizeForCache = _maxDiskSizeForCache;
- (void)setMaxDiskSizeForCache:(NSUInteger)maxDiskSizeForCache {
    dispatch_barrier_async(_queue, ^{
        if ( maxDiskSizeForCache != self->_maxDiskSizeForCache ) {
            self->_maxDiskSizeForCache = maxDiskSizeForCache;
            if ( maxDiskSizeForCache != 0 ) {
                [self _removeAssetsForLimit:MCSLimitCacheDiskSpace];
            }
        }
    });
}
- (NSUInteger)maxDiskSizeForCache {
    __block NSUInteger maxDiskSizeForCache = 0;
    dispatch_sync(_queue, ^{
        maxDiskSizeForCache = self->_maxDiskSizeForCache;
    });
    return maxDiskSizeForCache;
}

@synthesize reservedFreeDiskSpace = _reservedFreeDiskSpace;
- (void)setReservedFreeDiskSpace:(NSUInteger)reservedFreeDiskSpace {
    dispatch_barrier_async(_queue, ^{
        if ( reservedFreeDiskSpace != self->_reservedFreeDiskSpace ) {
            self->_reservedFreeDiskSpace = reservedFreeDiskSpace;
            if ( reservedFreeDiskSpace != 0 ) {
                [self _removeAssetsForLimit:MCSLimitFreeDiskSpace];
            }
        }
    });
}

- (NSUInteger)reservedFreeDiskSpace {
    __block NSUInteger reservedFreeDiskSpace = 0;
    dispatch_sync(_queue, ^{
        reservedFreeDiskSpace = self->_reservedFreeDiskSpace;
    });
    return reservedFreeDiskSpace;
}

@synthesize usageLogsSaveInterval = _usageLogsSaveInterval;
- (void)setUsageLogsSaveInterval:(NSTimeInterval)usageLogsSaveInterval {
    dispatch_barrier_sync(_queue, ^{
        if ( usageLogsSaveInterval != self->_usageLogsSaveInterval ) {
            self->_usageLogsSaveInterval = usageLogsSaveInterval;
        }
    });
}

- (NSTimeInterval)usageLogsSaveInterval {
    __block NSUInteger usageLogsSaveInterval = 0;
    dispatch_sync(_queue, ^{
        usageLogsSaveInterval = self->_usageLogsSaveInterval;
    });
    return usageLogsSaveInterval;
}

#pragma mark -

- (__kindof MCSAsset *)assetWithURL:(NSURL *)URL {
    __block MCSAsset *asset = nil;
    dispatch_barrier_sync(_queue, ^{
        MCSAssetType type = [MCSURLRecognizer.shared assetTypeForURL:URL];
        NSString *name = [MCSURLRecognizer.shared assetNameForURL:URL];
        if ( _assets[name] == nil ) {
            Class cls = [self _assetClassForType:type];
            // query
            MCSAsset *r = (id)[_sqlite3 objectsForClass:cls conditions:@[
                [SJSQLite3Condition conditionWithColumn:@"name" value:name]
            ] orderBy:nil error:NULL].firstObject;
            
            // create
            if ( r == nil ) {
                r = [cls.alloc init];
                r.name = name;
                [self _update:r]; // save asset
                r.log = [MCSAssetUsageLog.alloc initWithAsset:r];
                [self _update:r]; // save log
                _count += 1;
            }
            
            // directory
            [MCSFileManager checkoutAssetWithName:name error:NULL];
            
            // contents
            [r prepareContents];
            _assets[name] = r;
        }
        asset  = _assets[name];
    });
    return asset;
}

- (void)saveMetadata:(MCSAsset *)asset {
    dispatch_barrier_sync(_queue, ^{
        [self _update:asset];
    });
}

- (void)cancelCurrentReadsForAsset:(MCSAsset *)asset {
    if ( asset.readWriteCount != 0 ) {
        [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetManagerUserCancelledReadingNotification object:self userInfo:@{ MCSAssetManagerUserInfoAssetKey : asset }];
    }
}

- (id<MCSAssetReader>)readerWithRequest:(NSURLRequest *)request {
    MCSAsset *asset = [self assetWithURL:request.URL];
    id<MCSAssetReader> reader = [asset readerWithRequest:request];
    reader.readDataDecoder = _readDataDecoder;
    return reader;
}

- (void)reader:(id<MCSAssetReader>)reader willReadAsset:(MCSAsset *)asset {
    dispatch_barrier_sync(_queue, ^{
        // update
        MCSAssetUsageLog *log = asset.log;
        log.usageCount += 1;
        log.updatedTime = NSDate.date.timeIntervalSince1970;
        self->_usageLogs[asset.name] = log;
    });
}

// 读取结束, 清理剩余的超出个数限制的资源
- (void)reader:(id<MCSAssetReader>)reader didEndReadAsset:(MCSAsset *)asset {
    dispatch_barrier_sync(_queue, ^{
        if ( self->_cacheCountLimit == 0 || self->_count < self->_cacheCountLimit )
            return;
        [self _removeAssetsForLimit:MCSLimitCount];
    });
}

// 剩余磁盘空间在发生变化
- (void)didWriteDataForAsset:(MCSAsset *)asset length:(NSUInteger)length {
    dispatch_barrier_sync(_queue, ^{
        if ( self->_reservedFreeDiskSpace == 0 && self->_maxDiskSizeForCache == 0 )
            return;
        self->_cacheDiskSpace += length;
        self->_freeDiskSpace -= length;
        [self _removeAssetsForLimit:MCSLimitFreeDiskSpace];
        [self _removeAssetsForLimit:MCSLimitCacheDiskSpace];
    });
}

- (void)didRemoveDataForAsset:(MCSAsset *)asset length:(NSUInteger)length {
    dispatch_barrier_sync(_queue, ^{
        self->_cacheDiskSpace -= length;
        self->_freeDiskSpace += length;
    });
}

- (void)removeAllAssets {
    dispatch_barrier_sync(_queue, ^{
        NSArray<FILEAsset *> *FILEAssets = [_sqlite3 objectsForClass:FILEAsset.class conditions:nil orderBy:nil error:NULL];
        [self _removeAssets:FILEAssets];
        NSArray<HLSAsset *> *HLSAssets = [_sqlite3 objectsForClass:HLSAsset.class conditions:nil orderBy:nil error:NULL];
        [self _removeAssets:HLSAssets];
    });
}

- (void)removeAssetForURL:(NSURL *)URL {
    if ( URL == nil )
        return;
    MCSAsset *asset = [self assetWithURL:URL];
    dispatch_barrier_sync(_queue, ^{
        [self _removeAssets:@[asset]];
    });
}

- (NSUInteger)cachedSizeForAssets {
    return [MCSFileManager rootDirectorySize];
}

#pragma mark -

- (void)_removeAssetsForLimit:(MCSLimit)limit {
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
    
    NSMutableArray<NSNumber *> *usingAssets = NSMutableArray.alloc.init;
    [_assets enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MCSAsset * _Nonnull obj, BOOL * _Nonnull stop) {
        if ( obj.readWriteCount > 0 )
            [usingAssets addObject:@(obj.id)];
    }];

    // 全部处于使用中
    if ( usingAssets.count == _count )
        return;

    NSArray<MCSAssetUsageLog *> *logs = nil;
    switch ( limit ) {
        case MCSLimitNone:
            break;
        case MCSLimitCount:
        case MCSLimitCacheDiskSpace:
        case MCSLimitFreeDiskSpace: {
            // 清理60s之前的
            NSTimeInterval before = NSDate.date.timeIntervalSince1970 - 60;
            // 清理一半
            NSInteger length = (NSInteger)ceil((_count - usingAssets.count) * 0.5);
            logs = [_sqlite3 objectsForClass:MCSAssetUsageLog.class conditions:@[
                // 检索60s之前未被使用的资源
                [SJSQLite3Condition conditionWithColumn:@"asset" notIn:usingAssets],
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
            logs = [_sqlite3 objectsForClass:MCSAssetUsageLog.class conditions:@[
                [SJSQLite3Condition conditionWithColumn:@"asset" notIn:usingAssets],
                [SJSQLite3Condition conditionWithColumn:@"updatedTime" relatedBy:SJSQLite3RelationLessThanOrEqual value:@(time)],
            ] orderBy:nil error:NULL];
        }
            break;
    }

    if ( logs.count == 0 )
        return;

    // 删除
    NSMutableArray<MCSAsset *> *results = NSMutableArray.array;
    [logs enumerateObjectsUsingBlock:^(MCSAssetUsageLog * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MCSAsset *asset = [self.sqlite3 objectForClass:[self _assetClassForType:obj.assetType] primaryKeyValue:@(obj.asset) error:NULL];
        if ( asset != nil ) [results addObject:asset];
    }];
    
    [self _removeAssets:results];
}

- (void)_removeAssets:(NSArray<MCSAsset *> *)assets {
    if ( assets.count == 0 )
        return;

    [assets enumerateObjectsUsingBlock:^(MCSAsset * _Nonnull r, NSUInteger idx, BOOL * _Nonnull stop) {
        if( self.assets[r.name].readWriteCount != 0 )
            return;

        NSUInteger length = [MCSFileManager fileSizeAtPath:[MCSFileManager getAssetPathWithName:r.name]];
        self->_cacheDiskSpace -= length;
        self->_freeDiskSpace += length;

        [MCSFileManager removeAssetWithName:r.name error:NULL];
        [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetManagerDidRemoveAssetNotification object:self userInfo:@{ MCSAssetManagerUserInfoAssetKey : r }];
        [self.sqlite3 removeObjectForClass:r.class primaryKeyValue:@(r.id) error:NULL];
        [self.sqlite3 removeAllObjectsForClass:MCSAssetUsageLog.class conditions:@[
            [SJSQLite3Condition conditionWithColumn:@"asset" value:@(r.id)],
            [SJSQLite3Condition conditionWithColumn:@"assetType" value:@(r.type)],
        ] error:NULL];
        [self.assets removeObjectForKey:r.name];
        [self.usageLogs removeObjectForKey:r.name];
    }];
    
    _count -= assets.count;
}

- (void)_update:(MCSAsset *)asset {
    if ( asset.log != nil ) asset.log.updatedTime = NSDate.date.timeIntervalSince1970;
    if ( asset != nil ) [_sqlite3 save:asset error:NULL];
    [_usageLogs removeObjectForKey:asset.name];
}

- (Class)_assetClassForType:(MCSAssetType)type {
    return type == MCSAssetTypeFILE ? FILEAsset.class : HLSAsset.class;
}

- (void)_saveRecursively {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_usageLogsSaveInterval * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        dispatch_barrier_sync(self->_queue, ^{
            if ( self->_usageLogs.count != 0 ) {
                [self->_sqlite3 updateObjects:self->_usageLogs.allValues forKeys:@[@"usageCount", @"updatedTime"] error:NULL];
                [self->_usageLogs removeAllObjects];
            }
        });
        [self _saveRecursively];
    });
}
@end
