//
//  MCSAssetCacheManager.m
//  Pods-SJMediaCacheServer_Example
//
//  Created by BlueDancer on 2021/3/26.
//

#import "MCSAssetCacheManager.h"
#import "NSFileManager+MCS.h"
#import "MCSRootDirectory.h"
#import "MCSConsts.h"
#import "MCSUtils.h"
#import "MCSAssetManager.h"
#import "MCSDatabase.h"
#import "MCSQueue.h"

typedef NS_ENUM(NSUInteger, MCSLimit) {
    MCSLimitNone,
    MCSLimitCount,
    MCSLimitCacheDiskSpace,
    MCSLimitFreeDiskSpace,
    MCSLimitExpires,
};

@interface MCSAssetCacheTmpProtectedItem : NSObject<MCSSaveable>
- (instancetype)initWithAsset:(id<MCSAsset>)asset;
@property (nonatomic) NSInteger id;
@property (nonatomic) NSInteger asset;
@property (nonatomic) MCSAssetType assetType;
@end

@implementation MCSAssetCacheTmpProtectedItem
+ (NSString *)sql_primaryKey {
    return @"id";
}

+ (NSArray<NSString *> *)sql_autoincrementlist {
    return @[@"id"];
}

- (instancetype)initWithAsset:(id<MCSAsset>)asset {
    self = [super init];
    if ( self ) {
        _asset = asset.id;
        _assetType = asset.type;
    }
    return self;
}
@end

@interface MCSAssetCacheManager () {
    unsigned long long _cacheSize;
    unsigned long long _freeSize;
    NSInteger _countOfProtectedAssets;
    SJSQLite3 *_sqlite3;
}

@end

@implementation MCSAssetCacheManager
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
        _checkInterval = 30;
        _lastTimeLimit = 60;
        _sqlite3 = MCSDatabase();
        _countOfProtectedAssets = [_sqlite3 countOfObjectsForClass:MCSAssetCacheTmpProtectedItem.class conditions:nil error:NULL];
        [self _checkCachesRecursively];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_fileWriteOutOfSpaceErrorWithNote:) name:MCSFileWriteOutOfSpaceErrorNotification object:nil];
    }
    return self;
}

#pragma mark -

@synthesize cacheCountLimit = _cacheCountLimit;
- (void)setCacheCountLimit:(NSUInteger)cacheCountLimit {
    mcs_queue_sync(^{
        _cacheCountLimit = cacheCountLimit;
    });
}

- (NSUInteger)cacheCountLimit {
    __block NSUInteger cacheCountLimit = 0;
    mcs_queue_sync(^{
        cacheCountLimit = self->_cacheCountLimit;
    });
    return cacheCountLimit;
}

@synthesize maxDiskAgeForCache = _maxDiskAgeForCache;
- (void)setMaxDiskAgeForCache:(NSTimeInterval)maxDiskAgeForCache {
    mcs_queue_sync(^{
        _maxDiskAgeForCache = maxDiskAgeForCache;
    });
}

- (NSTimeInterval)maxDiskAgeForCache {
    __block NSTimeInterval maxDiskAgeForCache = 0;
    mcs_queue_sync(^{
        maxDiskAgeForCache = _maxDiskAgeForCache;
    });
    return maxDiskAgeForCache;
}

@synthesize maxDiskSizeForCache = _maxDiskSizeForCache;
- (void)setMaxDiskSizeForCache:(NSUInteger)maxDiskSizeForCache {
    mcs_queue_sync(^{
        _maxDiskSizeForCache = maxDiskSizeForCache;
    });
}
- (NSUInteger)maxDiskSizeForCache {
    __block NSUInteger maxDiskSizeForCache = 0;
    mcs_queue_sync(^{
        maxDiskSizeForCache = self->_maxDiskSizeForCache;
    });
    return maxDiskSizeForCache;
}

@synthesize reservedFreeDiskSpace = _reservedFreeDiskSpace;
- (void)setReservedFreeDiskSpace:(NSUInteger)reservedFreeDiskSpace {
    mcs_queue_sync(^{
        _reservedFreeDiskSpace = reservedFreeDiskSpace;
    });
}

- (NSUInteger)reservedFreeDiskSpace {
    __block NSUInteger reservedFreeDiskSpace = 0;
    mcs_queue_sync(^{
        reservedFreeDiskSpace = self->_reservedFreeDiskSpace;
    });
    return reservedFreeDiskSpace;
}

@synthesize checkInterval = _checkInterval;
- (void)setCheckInterval:(NSTimeInterval)checkInterval {
    mcs_queue_sync(^{
        if ( checkInterval != self->_checkInterval ) {
            self->_checkInterval = checkInterval;
        }
    });
}

- (NSTimeInterval)checkInterval {
    __block NSUInteger checkInterval = 0;
    mcs_queue_sync(^{
        checkInterval = self->_checkInterval;
    });
    return checkInterval;
}

- (UInt64)countOfBytesAllCaches {
    return MCSAssetManager.shared.countOfBytesAllAssets;
}

- (UInt64)countOfBytesRemovableCaches {
    __block UInt64 size = 0;
    mcs_queue_sync(^{
        size = [MCSAssetManager.shared countOfBytesNotIn:[self _allProtectedAssets]];
    });
    return size;
}

- (BOOL)isRemovableForCacheWithURL:(NSURL *)URL {
    if ( URL == nil )
        return NO;
    return [self isRemovableForCacheWithAsset:[MCSAssetManager.shared assetWithURL:URL]];
}

- (BOOL)isRemovableForCacheWithAsset:(id<MCSAsset>)asset {
    __block BOOL isRemovable = NO;
    if ( asset != nil ) {
        mcs_queue_sync(^{
            isRemovable = [self _isRemovableForCacheWithAsset:asset];
        });
    }
    return isRemovable;
}

- (BOOL)removeCacheForURL:(NSURL *)URL {
    if ( URL == nil )
        return NO;
    return [self removeCacheForAsset:[MCSAssetManager.shared assetWithURL:URL]];
}

- (BOOL)removeCacheForAsset:(id<MCSAsset>)asset {
    __block BOOL isRemoved = NO;
    if ( asset != nil ) {
        mcs_queue_sync(^{
            BOOL isRemovable = [self _isRemovableForCacheWithAsset:asset];
            if ( isRemovable ) {
                [MCSAssetManager.shared removeAsset:asset];
                isRemoved = YES;
            }
        });
    }
    return isRemoved;
}

- (void)removeAllRemovableCaches {
    mcs_queue_sync(^{
        NSDictionary<MCSAssetTypeNumber *, NSArray<MCSAssetIDNumber *> *> *protectedAssets = [self _allProtectedAssets];
        [MCSAssetManager.shared removeAssetsNotIn:protectedAssets];
        _countOfProtectedAssets = protectedAssets.count;
    });
}

- (void)setProtected:(BOOL)isProtected forCacheWithURL:(NSURL *)URL {
    [self setProtected:isProtected forCacheWithAsset:[MCSAssetManager.shared assetWithURL:URL]];
}

- (void)setProtected:(BOOL)isProtected forCacheWithAsset:(id<MCSAsset>)asset {
    if ( asset == nil )
        return;
    mcs_queue_sync(^{
        MCSAssetCacheTmpProtectedItem *item = (id)[_sqlite3 objectsForClass:MCSAssetCacheTmpProtectedItem.class conditions:@[
            [SJSQLite3Condition conditionWithColumn:@"assetType" value:@(asset.type)],
            [SJSQLite3Condition conditionWithColumn:@"asset" value:@(asset.id)]
        ] orderBy:nil error:NULL].firstObject;
        
        if ( isProtected ) {
            // save
            if ( item == nil ) {
                _countOfProtectedAssets += 1;
                item = [MCSAssetCacheTmpProtectedItem.alloc initWithAsset:asset];
                [_sqlite3 save:item error:NULL];
            }
            
            // return
            return;
        }

        // delete
        if ( item != nil ) {
            _countOfProtectedAssets -= 1;
            [_sqlite3 removeObjectForClass:MCSAssetCacheTmpProtectedItem.class primaryKeyValue:@(item.id) error:NULL];
        }
    });
}

#pragma mark -

- (void)_checkCachesRecursively {
    if ( _checkInterval == 0 ) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_checkInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        mcs_queue_sync(^{
            [self _trim];
        });
        
        [self _checkCachesRecursively];
    });
}
 
- (void)_syncDiskSpace {
    _freeSize = [NSFileManager.defaultManager mcs_freeDiskSpace];
    _cacheSize = [MCSRootDirectory size];
}

- (void)_trim {
    [self _syncDiskSpace];
    [self _removeAssetsForLimit:MCSLimitFreeDiskSpace];
    [self _removeAssetsForLimit:MCSLimitCacheDiskSpace];
    [self _removeAssetsForLimit:MCSLimitExpires];
    [self _removeAssetsForLimit:MCSLimitCount];
}

// 空间不足
- (void)_fileWriteOutOfSpaceErrorWithNote:(NSNotification *)note {
    mcs_queue_async(^{
        [self _trim];
    });
}

- (BOOL)_isRemovableForCacheWithAsset:(id<MCSAsset>)asset {
    return [_sqlite3 objectsForClass:MCSAssetCacheTmpProtectedItem.class conditions:@[
        [SJSQLite3Condition conditionWithColumn:@"assetType" value:@(asset.type)],
        [SJSQLite3Condition conditionWithColumn:@"asset" value:@(asset.id)]
    ] orderBy:nil error:NULL].count == 0;
}

- (void)_removeAssetsForLimit:(MCSLimit)limit {
    NSInteger count = MCSAssetManager.shared.countOfAllAssets - _countOfProtectedAssets;

    switch ( limit ) {
        case MCSLimitNone:
            return;
        case MCSLimitCount: {
            if ( _cacheCountLimit == 0 )
                return;
            
            
            if ( count == 1 )
                return;
            
            // 资源数量少于限制的个数
            if ( _cacheCountLimit > count )
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
    
    NSDictionary<MCSAssetTypeNumber *, NSArray<MCSAssetIDNumber *> *> *protectedAssets = [self _allProtectedAssets];
    switch ( limit ) {
        case MCSLimitNone:
            break;
        case MCSLimitCount:
        case MCSLimitCacheDiskSpace:
        case MCSLimitFreeDiskSpace: {
            // 清理`lastTimeLimit`之前的
            // 清理一半
            NSTimeInterval timeLimit = NSDate.date.timeIntervalSince1970 - _lastTimeLimit;
            NSInteger countLimit = (NSInteger)ceil(_cacheCountLimit != 0 ? (count - _cacheCountLimit * 0.5) : (count * 0.5));
            [MCSAssetManager.shared removeAssetsForLastReadingTime:timeLimit notIn:protectedAssets countLimit:countLimit];
        }
            break;
        case MCSLimitExpires: {
            NSTimeInterval timeLimit = NSDate.date.timeIntervalSince1970 - _maxDiskAgeForCache;
            [MCSAssetManager.shared removeAssetsForLastReadingTime:timeLimit notIn:protectedAssets];
        }
            break;
    }
}

#pragma mark - mark

- (NSDictionary<MCSAssetTypeNumber *, NSArray<MCSAssetIDNumber *> *> *)_allProtectedAssets {
    NSArray<NSDictionary *> *protectedHLSAssets = [_sqlite3 queryDataForClass:MCSAssetCacheTmpProtectedItem.class resultColumns:@[@"asset"] conditions:@[
        [SJSQLite3Condition conditionWithColumn:@"assetType" value:@(MCSAssetTypeHLS)]
    ] orderBy:nil error:NULL];
    NSArray<NSDictionary *> *protectedFILEAssets = [_sqlite3 queryDataForClass:MCSAssetCacheTmpProtectedItem.class resultColumns:@[@"asset"] conditions:@[
        [SJSQLite3Condition conditionWithColumn:@"assetType" value:@(MCSAssetTypeFILE)]
    ] orderBy:nil error:NULL];
    
    NSMutableDictionary<MCSAssetTypeNumber *, NSArray<MCSAssetIDNumber *> *> *protectedAssets = nil;
    if ( protectedHLSAssets.count != 0 || protectedFILEAssets.count != 0 ) {
        protectedAssets = NSMutableDictionary.dictionary;
    }
    
    if ( protectedHLSAssets.count != 0 ) {
        NSArray<NSNumber *> *rootAssets = SJFoundationExtendedValuesForKey(@"asset", protectedHLSAssets);
        NSMutableArray<NSNumber *> *array = rootAssets.mutableCopy;
        for ( NSNumber *root in rootAssets ) {
            HLSAsset *asset = [MCSAssetManager.shared assetForAssetId:root.integerValue type:MCSAssetTypeHLS];
            NSArray<HLSAsset *> *subAssets = asset.subAssets;
            if ( subAssets != nil ) {
                for ( HLSAsset *subAsset in subAssets ) {
                    [array addObject:@(subAsset.id)];
                }
            }
        }
        protectedAssets[@(MCSAssetTypeHLS)] = array.copy;
    }
    
    if ( protectedFILEAssets.count != 0 ) {
        protectedAssets[@(MCSAssetTypeFILE)] = SJFoundationExtendedValuesForKey(@"asset", protectedFILEAssets);
    }
    return protectedAssets.copy;
}

@end
