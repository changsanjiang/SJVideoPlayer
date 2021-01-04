//
//  MCSAssetManager.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/3.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSAssetManager.h"
#import <objc/message.h>
#import <SJUIKit/SJSQLite3.h>
#import <SJUIKit/SJSQLite3+QueryExtended.h>
#import <SJUIKit/SJSQLite3+RemoveExtended.h>
#import <SJUIKit/SJSQLite3+Private.h>

#import "MCSAssetUsageLog.h"
#import "NSFileManager+MCS.h"
 
#import "FILEReader.h"
#import "FILEAsset.h"
 
#import "HLSReader.h"
#import "HLSAsset.h"

#import "MCSRootDirectory.h"
#import "MCSConsts.h"

static NSString *kReadwriteCount = @"readwriteCount";

static dispatch_queue_t mcs_queue;

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

#pragma mark -

@interface MCSAssetManager () {
    unsigned long long _cacheSize;
    unsigned long long _freeSize;
}
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<MCSAsset> > *assets;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MCSAssetUsageLog *> *usageLogs;
@property (nonatomic, strong) SJSQLite3 *sqlite3;
@property (nonatomic) NSUInteger count;
@end

@implementation MCSAssetManager
+ (instancetype)shared {
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mcs_queue = dispatch_queue_create("queue.MCSAssetManager", DISPATCH_QUEUE_CONCURRENT);
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _sqlite3 = [SJSQLite3.alloc initWithDatabasePath:[MCSRootDirectory databasePath]];
        _count = [_sqlite3 countOfObjectsForClass:MCSAssetUsageLog.class conditions:nil error:NULL];
        _assets = NSMutableDictionary.dictionary;
        _usageLogs = NSMutableDictionary.dictionary;
        _checkInterval = 30;
        [self _checkRecursively];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_assetMetadataDidLoadWithNote:) name:MCSAssetMetadataDidLoadNotification object:nil];
    }
    return self;
}

#pragma mark -

@synthesize cacheCountLimit = _cacheCountLimit;
- (void)setCacheCountLimit:(NSUInteger)cacheCountLimit {
    dispatch_barrier_sync(mcs_queue, ^{
        _cacheCountLimit = cacheCountLimit;
    });
}

- (NSUInteger)cacheCountLimit {
    __block NSUInteger cacheCountLimit = 0;
    dispatch_sync(mcs_queue, ^{
        cacheCountLimit = self->_cacheCountLimit;
    });
    return cacheCountLimit;
}

@synthesize maxDiskAgeForCache = _maxDiskAgeForCache;
- (void)setMaxDiskAgeForCache:(NSTimeInterval)maxDiskAgeForCache {
    dispatch_barrier_sync(mcs_queue, ^{
        _maxDiskAgeForCache = maxDiskAgeForCache;
    });
}

- (NSTimeInterval)maxDiskAgeForCache {
    __block NSTimeInterval maxDiskAgeForCache = 0;
    dispatch_sync(mcs_queue, ^{
        maxDiskAgeForCache = _maxDiskAgeForCache;
    });
    return maxDiskAgeForCache;
}

@synthesize maxDiskSizeForCache = _maxDiskSizeForCache;
- (void)setMaxDiskSizeForCache:(NSUInteger)maxDiskSizeForCache {
    dispatch_barrier_sync(mcs_queue, ^{
        _maxDiskSizeForCache = maxDiskSizeForCache;
    });
}
- (NSUInteger)maxDiskSizeForCache {
    __block NSUInteger maxDiskSizeForCache = 0;
    dispatch_sync(mcs_queue, ^{
        maxDiskSizeForCache = self->_maxDiskSizeForCache;
    });
    return maxDiskSizeForCache;
}

@synthesize reservedFreeDiskSpace = _reservedFreeDiskSpace;
- (void)setReservedFreeDiskSpace:(NSUInteger)reservedFreeDiskSpace {
    dispatch_barrier_sync(mcs_queue, ^{
        _reservedFreeDiskSpace = reservedFreeDiskSpace;
    });
}

- (NSUInteger)reservedFreeDiskSpace {
    __block NSUInteger reservedFreeDiskSpace = 0;
    dispatch_sync(mcs_queue, ^{
        reservedFreeDiskSpace = self->_reservedFreeDiskSpace;
    });
    return reservedFreeDiskSpace;
}

@synthesize checkInterval = _checkInterval;
- (void)setCheckInterval:(NSTimeInterval)checkInterval {
    dispatch_barrier_sync(mcs_queue, ^{
        if ( checkInterval != self->_checkInterval ) {
            self->_checkInterval = checkInterval;
        }
    });
}

- (NSTimeInterval)checkInterval {
    __block NSUInteger checkInterval = 0;
    dispatch_sync(mcs_queue, ^{
        checkInterval = self->_checkInterval;
    });
    return checkInterval;
}

#pragma mark -

- (nullable __kindof id<MCSAsset> )assetWithURL:(NSURL *)URL {
    __block id<MCSAsset> asset = nil;
    dispatch_barrier_sync(mcs_queue, ^{
        MCSAssetType type = [MCSURLRecognizer.shared assetTypeForURL:URL];
        NSString *name = [MCSURLRecognizer.shared assetNameForURL:URL];
        if ( _assets[name] == nil ) {
            Class cls = [self _assetClassForType:type];
            if ( cls == nil ) return;
            
            // query
            id<MCSAsset> r = (id)[_sqlite3 objectsForClass:cls conditions:@[
                [SJSQLite3Condition conditionWithColumn:@"name" value:name]
            ] orderBy:nil error:NULL].firstObject;
            
            // create
            if ( r == nil ) {
                r = [cls.alloc initWithName:name];
                [self _syncToDatabase:r]; // save asset
                _count += 1;
            }
             
            [r prepare];
            _assets[name] = r;
        }
        
        asset  = _assets[name];
        
        if ( _usageLogs[name] == nil ) {
            MCSAssetUsageLog *log = (id)[_sqlite3 objectsForClass:MCSAssetUsageLog.class conditions:@[
                [SJSQLite3Condition conditionWithColumn:@"asset" value:@(asset.id)],
                [SJSQLite3Condition conditionWithColumn:@"assetType" value:@(asset.type)]
            ] orderBy:nil error:NULL].firstObject;
            
            if ( log == nil ) {
                log = [MCSAssetUsageLog.alloc initWithAsset:asset];
                [self _syncToDatabase:log]; // save log
            }
            
            _usageLogs[name] = log;
        }
    });
    return asset;
}

- (BOOL)isAssetStoredForURL:(NSURL *)URL {
    __block id<MCSAsset> asset = nil;
    dispatch_barrier_sync(mcs_queue, ^{
        NSString *name = [MCSURLRecognizer.shared assetNameForURL:URL];
        asset = _assets[name];
        if ( asset != nil ) return;
        MCSAssetType type = [MCSURLRecognizer.shared assetTypeForURL:URL];
        Class cls = [self _assetClassForType:type];
        if ( cls == nil ) return;
        asset = (id)[_sqlite3 objectsForClass:cls conditions:@[
            [SJSQLite3Condition conditionWithColumn:@"name" value:name]
        ] orderBy:nil error:NULL].firstObject;
        [asset prepare];
        if ( asset != nil ) _assets[name] = asset;
    });
    return asset.isStored;
}
 
- (nullable id<MCSAssetReader>)readerWithRequest:(NSURLRequest *)request networkTaskPriority:(float)networkTaskPriority delegate:(nullable id<MCSAssetReaderDelegate>)delegate {
    id<MCSAsset> asset = [self assetWithURL:request.URL];
    switch ( asset.type ) {
        case MCSAssetTypeFILE:
            return [FILEReader.alloc initWithAsset:asset request:request networkTaskPriority:networkTaskPriority readDataDecoder:_readDataDecoder delegate:delegate];
        case MCSAssetTypeHLS:
            return [HLSReader.alloc initWithAsset:asset request:request networkTaskPriority:networkTaskPriority readDataDecoder:_readDataDecoder delegate:delegate];
    }
    return nil;
}

- (void)removeAllAssets {
    dispatch_barrier_sync(mcs_queue, ^{
        NSArray<FILEAsset *> *FILEAssets = [_sqlite3 objectsForClass:FILEAsset.class conditions:nil orderBy:nil error:NULL];
        [self _removeAssets:FILEAssets];
        NSArray<HLSAsset *> *HLSAssets = [_sqlite3 objectsForClass:HLSAsset.class conditions:nil orderBy:nil error:NULL];
        [self _removeAssets:HLSAssets];
    });
}

- (void)removeAssetForURL:(NSURL *)URL {
    if ( URL.absoluteString.length == 0 )
        return;
    dispatch_barrier_sync(mcs_queue, ^{
        MCSAssetType type = [MCSURLRecognizer.shared assetTypeForURL:URL];
        NSString *name = [MCSURLRecognizer.shared assetNameForURL:URL];
        Class cls = [self _assetClassForType:type];
        if ( cls == nil ) return;
        id<MCSAsset> asset = (id)[_sqlite3 objectsForClass:cls conditions:@[
            [SJSQLite3Condition conditionWithColumn:@"name" value:name]
        ] orderBy:nil error:NULL].firstObject;
        if ( asset != nil ) [self _removeAssets:@[asset]];
    });
}

- (unsigned long long)cachedSizeForAssets {
    return MCSRootDirectory.size;
}

- (void)willReadAssetForURL:(NSURL *)URL {
    id<MCSAsset> asset = [self assetWithURL:URL];
    if ( asset != nil ) {
        dispatch_barrier_async(mcs_queue, ^{
            MCSAssetUsageLog *log = self->_usageLogs[asset.name];
            if ( log != nil ) {
                log.usageCount += 1;
                log.updatedTime = NSDate.date.timeIntervalSince1970;
            }
            [self _syncToDatabase:log];
        });
    }
}

#pragma mark - mark

- (void)_checkRecursively {
    if ( _checkInterval == 0 ) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_checkInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        dispatch_barrier_sync(mcs_queue, ^{
            [self _syncDiskSpace];
            [self _removeAssetsForLimit:MCSLimitFreeDiskSpace];
            [self _removeAssetsForLimit:MCSLimitCacheDiskSpace];
            [self _removeAssetsForLimit:MCSLimitExpires];
            [self _removeAssetsForLimit:MCSLimitCount];
        });
        
        [self _checkRecursively];
    });
}

- (void)_syncUsageLogsToDatabase {
    if ( _usageLogs.count != 0 ) {
        [_sqlite3 updateObjects:self->_usageLogs.allValues forKeys:@[@"usageCount", @"updatedTime"] error:NULL];
        [_usageLogs removeAllObjects];
    }
}

- (void)_syncDiskSpace {
    _freeSize = [NSFileManager.defaultManager mcs_freeDiskSpace];
    _cacheSize = [MCSRootDirectory size];
}

- (void)_syncToDatabase:(id<MCSSaveable>)saveable {
    [_sqlite3 save:saveable error:NULL];
}

#pragma mark - mark

- (void)_assetMetadataDidLoadWithNote:(NSNotification *)note {
    dispatch_barrier_async(mcs_queue, ^{
        [self _syncToDatabase:note.object];
    });
}

#pragma mark -

- (void)_removeAssetsForLimit:(MCSLimit)limit {
    switch ( limit ) {
        case MCSLimitNone:
            return;
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
            
            if ( _freeSize > _reservedFreeDiskSpace )
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
            if ( _maxDiskSizeForCache > _cacheSize )
                return;
        }
            break;
    }
     
    // 过滤被使用中的资源
    NSMutableArray<NSNumber *> *arr0 = NSMutableArray.array;
    NSMutableArray<NSNumber *> *arr1 = NSMutableArray.array;
    [_assets enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<MCSAsset>  _Nonnull asset, BOOL * _Nonnull stop) {
        if ( asset.readwriteCount > 0 ) {
            NSMutableArray<NSNumber *> *m = (asset.type == MCSAssetTypeFILE ? arr0 : arr1);
            [m addObject:@(asset.id)];
        }
    }];
    
    // 全部处于使用中
    NSInteger count = arr0.count + arr1.count;
    if ( count == _count )
        return;
    
    [arr0 addObject:@(0)];
    [arr1 addObject:@(0)];
    
    NSString *s0 = [arr0 componentsJoinedByString:@","];
    NSString *s1 = [arr1 componentsJoinedByString:@","];

    NSArray<MCSAssetUsageLog *> *logs = nil;
    switch ( limit ) {
        case MCSLimitNone:
            break;
        case MCSLimitCount:
        case MCSLimitCacheDiskSpace:
        case MCSLimitFreeDiskSpace: {
            // 清理60s之前的
            // 清理一半
            NSTimeInterval time = NSDate.date.timeIntervalSince1970 - 60;
            NSInteger length = (NSInteger)ceil(_cacheCountLimit != 0 ? (_count - _cacheCountLimit * 0.5) : (_count - count) * 0.5);
            NSArray<SJSQLite3RowData *> *rows = [_sqlite3 exec:[NSString stringWithFormat:
                            @"SELECT * FROM MCSAssetUsageLog WHERE (asset NOT IN (%@) AND assetType = 0) \
                                                                OR (asset NOT IN (%@) AND assetType = 1) \
                                                               AND updatedTime <= %lf \
                                                          ORDER BY updatedTime ASC, usageCount ASC \
                                                             LIMIT 0, %ld;", s0, s1, time, (long)length] error:NULL];
            logs = [_sqlite3 objectsForClass:MCSAssetUsageLog.class rowDatas:rows error:NULL];
        }
            break;
        case MCSLimitExpires: {
            NSTimeInterval time = NSDate.date.timeIntervalSince1970 - _maxDiskAgeForCache;
            NSArray<SJSQLite3RowData *> *rows = [_sqlite3 exec:[NSString stringWithFormat:
                            @"SELECT * FROM MCSAssetUsageLog WHERE (asset NOT IN (%@) AND assetType = 0) \
                                                                OR (asset NOT IN (%@) AND assetType = 1) \
                                                               AND updatedTime <= %lf;", s0, s1, time] error:NULL];
            logs = [_sqlite3 objectsForClass:MCSAssetUsageLog.class rowDatas:rows error:NULL];
        }
            break;
    }

    if ( logs.count == 0 )
        return;

    // 删除
    NSMutableArray<id<MCSAsset> > *results = NSMutableArray.array;
    [logs enumerateObjectsUsingBlock:^(MCSAssetUsageLog * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<MCSAsset> asset = [self.sqlite3 objectForClass:[self _assetClassForType:obj.assetType] primaryKeyValue:@(obj.asset) error:NULL];
        if ( asset != nil ) [results addObject:asset];
    }];
    
    [self _removeAssets:results];
}

- (void)_removeAssets:(NSArray<id<MCSAsset> > *)assets {
    if ( assets.count == 0 )
        return;

    [assets enumerateObjectsUsingBlock:^(id<MCSAsset>  _Nonnull r, NSUInteger idx, BOOL * _Nonnull stop) {
        [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetWillRemoveAssetNotification object:r];
        [NSFileManager.defaultManager removeItemAtPath:r.path error:NULL];
        [self.sqlite3 removeObjectForClass:r.class primaryKeyValue:@(r.id) error:NULL];
        [self.sqlite3 removeAllObjectsForClass:MCSAssetUsageLog.class conditions:@[
            [SJSQLite3Condition conditionWithColumn:@"asset" value:@(r.id)],
            [SJSQLite3Condition conditionWithColumn:@"assetType" value:@(r.type)],
        ] error:NULL];
        [self.assets removeObjectForKey:r.name];
        [self.usageLogs removeObjectForKey:r.name];
        [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetDidRemoveAssetNotification object:r];
    }];
    
    _count -= assets.count;
}

- (Class)_assetClassForType:(MCSAssetType)type {
    return type == MCSAssetTypeFILE ? FILEAsset.class : HLSAsset.class;
}
@end
