//
//  MCSAssetExporterManager.m
//  SJMediaCacheServer
//
//  Created by BD on 2021/3/10.
//

#import "MCSAssetExporterManager.h"
#import "MCSAssetCacheManager.h"
#import "MCSAssetManager.h"
#import "MCSPrefetcherManager.h"
#import "NSFileManager+MCS.h"
#import "MCSDatabase.h"
#import "MCSURL.h"
#import "MCSUtils.h"
#import "FILEAsset.h"
#import "HLSAsset.h"

static NSNotificationName const MCSAssetExporterProgressDidChangeNotification = @"MCSAssetExporterProgressDidChangeNotification";
static NSNotificationName const MCSAssetExporterStatusDidChangeNotification = @"MCSAssetExporterStatusDidChangeNotification";

static NSString *const MCSAssetExporterErrorUserInfoKey = @"MCSAssetExporterErrorUserInfoKey";

@interface MCSAssetExporter : NSObject<MCSSaveable, MCSAssetExporter>
- (instancetype)initWithURLString:(NSString *)URLStr name:(NSString *)name type:(MCSAssetType)type;
@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic) MCSAssetExportStatus status;
@property (nonatomic) float progress;
- (void)synchronize;
- (void)resume;
- (void)suspend;
- (void)cancel;
- (void)willBeRemoved;
@end

@interface MCSAssetExporter () {
    dispatch_semaphore_t _semaphore;
    id<MCSPrefetchTask> _task;
}
@property (nonatomic) NSInteger id;
@property (nonatomic, strong) NSString *name; // asset name
@property (nonatomic, strong) NSString *URLString;
@property (nonatomic) MCSAssetType type;
@end

@implementation MCSAssetExporter
@synthesize URL = _URL;
@synthesize status = _status;
@synthesize progress = _progress;
@synthesize progressDidChangeExecuteBlock = _progressDidChangeExecuteBlock;
@synthesize statusDidChangeExecuteBlock = _statusDidChangeExecuteBlock;

- (instancetype)initWithURLString:(NSString *)URLStr name:(NSString *)name type:(MCSAssetType)type {
    self = [self init];
    if ( self ) {
        _URLString = URLStr;
        _name = name;
        _type = type;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _semaphore = dispatch_semaphore_create(1);
        _status = MCSAssetExportStatusSuspended;
    }
    return self;
}

+ (NSString *)sql_primaryKey {
    return @"id";
}

+ (NSArray<NSString *> *)sql_autoincrementlist {
    return @[self.sql_primaryKey];
}

+ (NSArray<NSString *> *)sql_blacklist {
    return @[@"URL", @"progress"];
}

- (NSURL *)URL {
    __block NSURL *URL = nil;
    [self _lockInBlock:^{
        if ( _URL == nil )
            _URL = [NSURL URLWithString:_URLString];
        URL = _URL;
    }];
    return URL;
}
  
- (MCSAssetExportStatus)status {
    __block MCSAssetExportStatus status;
    [self _lockInBlock:^{
        status = _status;
    }];
    return status;
}

- (float)progress {
    __block float progress = 0;
    [self _lockInBlock:^{
        progress = _status == MCSAssetExportStatusFinished ? 1.0 : _progress;
    }];
    return progress;
}

- (void)synchronize {
    __kindof id<MCSAsset> asset = [MCSAssetManager.shared assetWithName:_name type:_type];
    switch ( _type ) {
        case MCSAssetTypeFILE:
            [self _synchronizeForFILEAsset:asset];
            break;
        case MCSAssetTypeHLS:
            [self _synchronizeForHLSAsset:asset];
            break;
    }
}

- (void)resume {
    __block BOOL isChanged = NO;
    [self _lockInBlock:^{
        switch ( _status ) {
            case MCSAssetExportStatusFinished:
            case MCSAssetExportStatusWaiting:
            case MCSAssetExportStatusExporting:
            case MCSAssetExportStatusCancelled:
                return;
            case MCSAssetExportStatusUnknown:
            case MCSAssetExportStatusFailed:
            case MCSAssetExportStatusSuspended: {
                if ( _URL == nil )
                    _URL = [NSURL URLWithString:_URLString];
                if ( _task != nil )
                    return;
                
                __weak typeof(self) _self = self;
                _task = [MCSPrefetcherManager.shared prefetchWithURL:_URL progress:nil completed:^(NSError * _Nullable error) {
                    __strong typeof(_self) self = _self;
                    if ( self == nil ) return;
                    [self _prefetchTaskDidCompleteWithError:error];
                }];
                
                _task.startedExecuteBlock = ^(id<MCSPrefetchTask>  _Nonnull task) {
                    __strong typeof(_self) self = _self;
                    if ( self == nil ) return;
                    [self _prefetchTaskDidStart];
                };
                
                _status = MCSAssetExportStatusWaiting;
                isChanged = YES;
            }
                return;
        }
    }];
    if ( isChanged ) [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetExporterStatusDidChangeNotification object:self];
}

- (void)suspend {
    __block BOOL isChanged = NO;
    [self _lockInBlock:^{
        switch ( _status ) {
            case MCSAssetExportStatusFinished:
            case MCSAssetExportStatusFailed:
            case MCSAssetExportStatusCancelled:
            case MCSAssetExportStatusSuspended:
                return;
            case MCSAssetExportStatusUnknown:
            case MCSAssetExportStatusWaiting:
            case MCSAssetExportStatusExporting: {
                if ( _task != nil ) {
                    [_task cancel];
                    _task = nil;
                }
                
                _status = MCSAssetExportStatusSuspended;
                isChanged = YES;
            }
        }
    }];
    if ( isChanged ) [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetExporterStatusDidChangeNotification object:self];
}

- (void)cancel {
    __block BOOL isChanged = NO;
    [self _lockInBlock:^{
        switch ( _status ) {
            case MCSAssetExportStatusFinished:
            case MCSAssetExportStatusCancelled:
                return;
            case MCSAssetExportStatusUnknown:
            case MCSAssetExportStatusFailed:
            case MCSAssetExportStatusSuspended:
            case MCSAssetExportStatusWaiting:
            case MCSAssetExportStatusExporting: {
                if ( _task != nil ) {
                    [_task cancel];
                    _task = nil;
                }
                
                _status = MCSAssetExportStatusCancelled;
                isChanged = YES;
            }
        }
    }];
    if ( isChanged ) [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetExporterStatusDidChangeNotification object:self];
}

- (void)willBeRemoved {
    [self _lockInBlock:^{
        if ( _task != nil ) {
            [_task cancel];
            _task = nil;
        }
    }];
}

#pragma mark - mark

- (void)_syncProgress {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        switch ( self->_status ) {
            case MCSAssetExportStatusUnknown:
            case MCSAssetExportStatusWaiting:
            case MCSAssetExportStatusFailed:
            case MCSAssetExportStatusSuspended:
            case MCSAssetExportStatusCancelled:
            case MCSAssetExportStatusFinished:
                break;
            case MCSAssetExportStatusExporting: {
                [self synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSelector:@selector(_syncProgress) withObject:nil afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
                });
            }
                break;
        }
    });
}

- (void)_prefetchTaskDidStart {
    [self _lockInBlock:^{
        _status = MCSAssetExportStatusExporting;
    }];
    [self _syncProgress];
    [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetExporterStatusDidChangeNotification object:self];
}

- (void)_prefetchTaskDidCompleteWithError:(NSError *_Nullable)error {
    [self synchronize];
    [self _lockInBlock:^{
        _task = nil;
        _status = error != nil ? MCSAssetExportStatusFailed : MCSAssetExportStatusFinished;
    }];
    NSDictionary *userInfo = nil;
    if ( error != nil ) {
        userInfo = @{MCSAssetExporterErrorUserInfoKey: error};
    }
    [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetExporterStatusDidChangeNotification object:self userInfo:userInfo];
}

- (void)_lockInBlock:(void(^NS_NOESCAPE)(void))task {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    task();
    dispatch_semaphore_signal(_semaphore);
}

- (void)_synchronizeForFILEAsset:(FILEAsset *)asset {
    __block BOOL isChanged = NO;
    [self _lockInBlock:^{
        if ( _status == MCSAssetExportStatusFinished )
            return;
        
        float progress = _progress;
        NSUInteger totalLength = asset.totalLength;
        if ( totalLength != 0 ) {
            __block id<MCSAssetContent> prev = nil;
            __block UInt64 length = 0;
            [asset enumerateContentNodesUsingBlock:^(id<FILEAssetContentNode>  _Nonnull node, BOOL * _Nonnull stop) {
                id<MCSAssetContent> cur = node.longestContent;
                length += cur.length;
                UInt64 prevPosition = prev.startPositionInAsset + prev.length;
                if ( prevPosition > cur.startPositionInAsset ) length -= (prevPosition - cur.startPositionInAsset);
                prev = cur;
            }];
            progress = length * 1.0 / totalLength;
        }
        isChanged = progress != _progress;
        if ( isChanged ) _progress = progress;
    }];
    
    if ( isChanged ) [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetExporterProgressDidChangeNotification object:self];
}

- (void)_synchronizeForHLSAsset:(HLSAsset *)asset {
    __block BOOL isChanged = NO;
    [self _lockInBlock:^{
        if ( _status == MCSAssetExportStatusFinished )
            return;
        
        float progress = _progress;
        HLSAssetParser *parser = asset.parser;
        if ( parser != nil ) {
            // 获取所有相关的asset, 计算进度
            NSMutableArray<HLSAsset *> *allAssets = [NSMutableArray arrayWithObject:asset];
            NSArray<HLSAsset *> *subAssets = asset.subAssets;
            if ( subAssets != nil ) {
                [allAssets addObjectsFromArray:subAssets];
            }
            
            float all = 0;
            for ( HLSAsset *asset in allAssets ) {
                all += [self _calculateProgressWithHLSAsset:asset];
            }
            progress = all / allAssets.count;
        }
        
        isChanged = progress != _progress;
        if ( isChanged ) _progress = progress;
    }];
    
    if ( isChanged ) [NSNotificationCenter.defaultCenter postNotificationName:MCSAssetExporterProgressDidChangeNotification object:self];
}

- (float)_calculateProgressWithHLSAsset:(HLSAsset *)asset {
    if ( asset.parser != nil && asset.tsCount == 0 )
        return 1.0f;
    
    if ( asset.TsContents.count != 0 ) {
        NSMutableArray<id<HLSAssetTsContent>> *contents = [asset.TsContents mutableCopy];
        [contents sortUsingComparator:^NSComparisonResult(id<HLSAssetTsContent>obj1, id<HLSAssetTsContent>obj2) {
            if ( [obj1.name isEqualToString:obj2.name] && NSEqualRanges(obj1.rangeInAsset, obj2.rangeInAsset) ) {
                if ( obj1.length == obj2.length )
                    return NSOrderedSame;
                return obj1.length > obj2.length ? NSOrderedAscending : NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        
        float progress = 0;
        id<HLSAssetTsContent>pre = nil;
        for ( id<HLSAssetTsContent>content in contents ) {
            if ( pre == nil || !([content.name isEqualToString:pre.name] && NSEqualRanges(content.rangeInAsset, pre.rangeInAsset)) ) {
                progress += content.length * 1.0 / content.rangeInAsset.length;
            }
            pre = content;
        }
        
        return progress / asset.tsCount;
    }
    return 0.0f;
}
@end
   

@interface MCSAssetExporterManager () {
    SJSQLite3 *_sqlite3;
    NSHashTable<id<MCSAssetExportObserver>> *_Nullable _observers;
    dispatch_semaphore_t _semaphore;
    NSMutableArray<MCSAssetExporter *> *_exporters;
    
    id _progressDidChangeToken;
    id _statusDidChangeToken;
}
@end

@implementation MCSAssetExporterManager
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
        _exporters = NSMutableArray.array;

        _sqlite3 = MCSDatabase();
                 
        __weak typeof(self) _self = self;
        _progressDidChangeToken = [NSNotificationCenter.defaultCenter addObserverForName:MCSAssetExporterProgressDidChangeNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
                [self _progressDidChange:note.object];
            });
        }];
        _statusDidChangeToken = [NSNotificationCenter.defaultCenter addObserverForName:MCSAssetExporterStatusDidChangeNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                __strong typeof(_self) self = _self;
                if ( self == nil ) return;
                NSError *error = [note.userInfo objectForKey:MCSAssetExporterErrorUserInfoKey];
                [self _statusDidChange:note.object error:error];
            });
        }];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:_progressDidChangeToken];
    [NSNotificationCenter.defaultCenter removeObserver:_statusDidChangeToken];
}

- (void)setMaxConcurrentExportCount:(NSInteger)maxConcurrentExportCount {
    MCSPrefetcherManager.shared.maxConcurrentPrefetchCount = maxConcurrentExportCount;
}

- (NSInteger)maxConcurrentExportCount {
    return MCSPrefetcherManager.shared.maxConcurrentPrefetchCount;
}

- (nullable NSArray<id<MCSAssetExporter>> *)allExporters {
    __block NSArray<id<MCSAssetExporter>> *allExporters = nil;
    [self _lockInBlock:^{
        // memory
        NSMutableArray<NSNumber *> *exporterIdsInMemory = _exporters.count != 0 ? ([NSMutableArray arrayWithCapacity:_exporters.count]) : nil;
        for ( MCSAssetExporter *exporter in _exporters ) {
            [exporterIdsInMemory addObject:@(exporter.id)];
        }
        
        // disk
        NSArray<SJSQLite3Condition *> *conditions = nil;
        if ( exporterIdsInMemory.count != 0 ) {
            conditions = @[[SJSQLite3Condition conditionWithColumn:@"id" notIn:exporterIdsInMemory]];
        }
        NSArray<MCSAssetExporter *> *exportersInDisk = [_sqlite3 objectsForClass:MCSAssetExporter.class conditions:conditions orderBy:nil error:NULL];
        if ( exportersInDisk.count != 0 ) {
            [_exporters addObjectsFromArray:exportersInDisk];
        }
        
        // results
        if ( _exporters.count != 0 ) {
            allExporters = _exporters.copy;
        }
    }];
    return allExporters;
}

- (UInt64)countOfBytesAllExportedAssets {
    return MCSAssetCacheManager.shared.countOfBytesAllCaches - MCSAssetCacheManager.shared.countOfBytesRemovableCaches;
}

/// 注册观察者
///
///     导出的相关回调会通知该观察者.
///
- (void)registerObserver:(id<MCSAssetExportObserver>)observer {
    if ( observer == nil )
        return;
    [self _lockInBlock:^{
        if ( _observers == nil ) {
            _observers = NSHashTable.weakObjectsHashTable;
        }
        [_observers addObject:observer];
    }];
}

/// 移除观察
///
///     当不需要监听时, 可以调用该方法移除监听.
///
///     监听是自动移除的, 在观察者释放时并不需要显示的调用该方法
///
- (void)removeObserver:(id<MCSAssetExportObserver>)observer {
    if ( observer == nil )
        return;
    [self _lockInBlock:^{
        [_observers removeObject:observer];
    }];
}

/// 添加一个导出任务
///
/// \code
///         id<MCSAssetExporter> exporter = [session exportAssetWithURL:URL];
///         // 开启
///         [exporter resume];
/// \endcode
///
- (nullable id<MCSAssetExporter>)exportAssetWithURL:(NSURL *)URL {
    if ( URL.absoluteString.length == 0 )
        return nil;
    __block MCSAssetExporter *exporter = nil;
    [self _lockInBlock:^{
        exporter = [self _exportAssetWithURL:URL];
    }];
    [exporter synchronize];
    return exporter;
}

/// 删除导出的资源
///
- (void)removeAssetWithURL:(NSURL *)URL {
    if ( URL.absoluteString.length == 0 )
        return;
    
    __block BOOL isRemoved = NO;
    [self _lockInBlock:^{
        NSString *name = [MCSURL.shared assetNameForURL:URL];
        MCSAssetExporter *_Nullable exporter = [self _exporterInCachesForName:name];
        if ( exporter != nil ) {
            [exporter willBeRemoved];
            [_exporters removeObject:exporter];
            [_sqlite3 removeObjectForClass:MCSAssetExporter.class primaryKeyValue:@(exporter.id) error:NULL];
            [MCSAssetCacheManager.shared setProtected:NO forCacheWithURL:URL];
            [MCSAssetCacheManager.shared removeCacheForURL:URL];
            isRemoved = YES;
        }
    }];
    
    if ( isRemoved ) {
        for ( id<MCSAssetExportObserver> observer in MCSAllHashTableObjects(_observers) ) {
            if ( [observer respondsToSelector:@selector(exporterManager:didRemoveAssetWithURL:)] ) {
                [observer exporterManager:self didRemoveAssetWithURL:URL];
            }
        }
    }
}

/// 删除全部
///
- (void)removeAllAssets {
    __block BOOL isRemoved = NO;
    [self _lockInBlock:^{
        NSMutableArray<NSNumber *> *exporterIdsInMemory = _exporters.count != 0 ? ([NSMutableArray arrayWithCapacity:_exporters.count]) : nil;
        for ( MCSAssetExporter *exporter in _exporters ) {
            [exporterIdsInMemory addObject:@(exporter.id)];
        }
        
        NSArray<SJSQLite3Condition *> *conditions = nil;
        if ( exporterIdsInMemory.count != 0 ) {
            conditions = @[[SJSQLite3Condition conditionWithColumn:@"id" notIn:exporterIdsInMemory]];
        }
        NSArray<MCSAssetExporter *> *exportersInDisk = [_sqlite3 objectsForClass:MCSAssetExporter.class conditions:conditions orderBy:nil error:NULL];
        NSArray<MCSAssetExporter *> *exportersInMemory = _exporters;
        
        NSMutableArray<MCSAssetExporter *> *allExporters = [NSMutableArray arrayWithCapacity:exportersInDisk.count + exportersInMemory.count];
        if ( exportersInDisk.count != 0 ) {
            [allExporters addObjectsFromArray:exportersInDisk];
        }
        
        if ( exportersInMemory.count != 0 ) {
            [allExporters addObjectsFromArray:exportersInMemory];
        }
        
        if ( allExporters.count != 0 ) {
            [_exporters removeAllObjects];
            [_sqlite3 removeAllObjectsForClass:MCSAssetExporter.class error:NULL];
            for ( MCSAssetExporter *exporter in allExporters ) {
                [exporter willBeRemoved];
                id<MCSAsset> asset = [MCSAssetManager.shared assetWithName:exporter.name type:exporter.type];
                [MCSAssetCacheManager.shared setProtected:NO forCacheWithAsset:asset];
                [MCSAssetCacheManager.shared removeCacheForAsset:asset];
            }
            isRemoved = YES;
        }
    }];
    
    if ( isRemoved ) {
        for ( id<MCSAssetExportObserver> observer in MCSAllHashTableObjects(_observers) ) {
            if ( [observer respondsToSelector:@selector(exporterManagerDidRemoveAllAssets:)] ) {
                [observer exporterManagerDidRemoveAllAssets:self];
            }
        }
    }
}

/// 查询状态
///
- (MCSAssetExportStatus)statusWithURL:(NSURL *)URL {
    __block MCSAssetExportStatus status = MCSAssetExportStatusUnknown;
    if ( URL.absoluteString.length != 0 ) {
        [self _lockInBlock:^{
            NSString *name = [MCSURL.shared assetNameForURL:URL];
            MCSAssetExporter *exporter = [self _exporterInCachesForName:name];
            status = exporter.status;
        }];
    }
    return status;
}

/// 查询进度
///
- (float)progressWithURL:(NSURL *)URL {
    __block float progress = 0.0f;
    if ( URL.absoluteString.length != 0 ) {
        [self _lockInBlock:^{
            NSString *name = [MCSURL.shared assetNameForURL:URL];
            MCSAssetExporter *exporter = [self _exporterInCachesForName:name];
            progress = exporter.progress;
        }];
    }
    return progress;
}


/// 同步缓存, 更新缓存进度
///
- (void)synchronizeForExporterWithAssetURL:(NSURL *)URL {
    if ( URL.absoluteString.length != 0 ) {
        [self _lockInBlock:^{
            NSString *name = [MCSURL.shared assetNameForURL:URL];
            MCSAssetExporter *exporter = [self _exporterInCachesForName:name];
            [exporter synchronize];
        }];
    }
}

- (void)synchronize {
    [self _lockInBlock:^{
        for ( MCSAssetExporter *exporter in _exporters ) {
            [exporter synchronize];
        }
    }];
}

- (nullable NSArray<id<MCSAssetExporter>> *)exportsForMask:(MCSAssetExportStatusQueryMask)mask {
    __block NSArray<id<MCSAssetExporter>> *_Nullable retv = nil;;
    [self _lockInBlock:^{
        retv = [self _exportersInCachesForMask:mask];
    }];
    return retv;
}

#pragma mark - mark

- (void)_lockInBlock:(void(^NS_NOESCAPE)(void))task {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    task();
    dispatch_semaphore_signal(_semaphore);
}

- (MCSAssetExporter *)_exportAssetWithURL:(NSURL *)URL {
    NSString *name = [MCSURL.shared assetNameForURL:URL];
    MCSAssetExporter *exporter = [self _exporterInCachesForName:name];
    if ( exporter == nil ) {
        MCSAssetType type = [MCSURL.shared assetTypeForURL:URL];
        exporter = [MCSAssetExporter.alloc initWithURLString:URL.absoluteString name:name type:type];
        [MCSAssetCacheManager.shared setProtected:YES forCacheWithURL:URL];
        [_sqlite3 save:exporter error:NULL];
        [_exporters addObject:exporter];
    }
    return exporter;
}

// memory + disk
- (nullable MCSAssetExporter *)_exporterInCachesForName:(NSString *)name {
    // memory
    MCSAssetExporter *exporter = [self _exporterInMemoryForName:name];
    if ( exporter == nil ) {
        // disk
        exporter = [_sqlite3 objectsForClass:MCSAssetExporter.class conditions:@[
            [SJSQLite3Condition conditionWithColumn:@"name" value:name]
        ] orderBy:nil error:NULL].firstObject;
        // add into memory
        if ( exporter != nil ) {
            [_exporters addObject:exporter];
        }
    }
    return exporter;
}

- (nullable MCSAssetExporter *)_exporterInMemoryForName:(NSString *)name {
    for ( MCSAssetExporter *exporter in _exporters ) {
        if ( [exporter.name isEqualToString:name] )
            return exporter;
    }
    return nil;
}

// memory + disk
- (nullable NSArray<MCSAssetExporter *> *)_exportersInCachesForMask:(MCSAssetExportStatusQueryMask)mask {
    // memory
    NSArray<MCSAssetExporter *> *_Nullable mem = [self _exportersInMemoryForMask:mask];
    NSMutableArray<NSNumber *> *notIn = [NSMutableArray arrayWithObject:@(0)];
    for ( MCSAssetExporter *exporter in mem ) {
        [notIn addObject:@(exporter.id)];
    }
    
    // disk
    NSMutableArray<NSNumber *> *queryStatus = NSMutableArray.array;
    if ( mask & MCSAssetExportStatusQueryMaskUnknown ) {
        [queryStatus addObject:@(MCSAssetExportStatusUnknown)];
    }
    if ( mask & MCSAssetExportStatusQueryMaskWaiting ) {
        [queryStatus addObject:@(MCSAssetExportStatusWaiting)];
    }
    if ( mask & MCSAssetExportStatusQueryMaskExporting ) {
        [queryStatus addObject:@(MCSAssetExportStatusExporting)];
    }
    if ( mask & MCSAssetExportStatusQueryMaskFinished ) {
        [queryStatus addObject:@(MCSAssetExportStatusFinished)];
    }
    if ( mask & MCSAssetExportStatusQueryMaskFailed ) {
        [queryStatus addObject:@(MCSAssetExportStatusFailed)];
    }
    if ( mask & MCSAssetExportStatusQueryMaskSuspended ) {
        [queryStatus addObject:@(MCSAssetExportStatusSuspended)];
    }
    if ( mask & MCSAssetExportStatusQueryMaskCancelled ) {
        [queryStatus addObject:@(MCSAssetExportStatusCancelled)];
    }
    NSArray<MCSAssetExporter *> *_Nullable disk = [_sqlite3 objectsForClass:MCSAssetExporter.class conditions:@[
        [SJSQLite3Condition conditionWithColumn:@"id" notIn:notIn],
        [SJSQLite3Condition conditionWithColumn:@"status" in:queryStatus]
    ] orderBy:nil error:NULL];
    // add into memory
    if ( disk.count != 0 ) {
        [_exporters addObjectsFromArray:disk];
    }
    
    NSMutableArray<MCSAssetExporter *> *_Nullable retv = nil;
    if ( mem.count != 0 || disk.count != 0 ) {
        retv = NSMutableArray.array;
        if ( mem.count != 0 )
            [retv addObjectsFromArray:mem];
        if ( disk.count != 0 )
            [retv addObjectsFromArray:disk];
    }
    return retv.copy;
}

- (nullable NSArray<MCSAssetExporter *> *)_exportersInMemoryForMask:(MCSAssetExportStatusQueryMask)mask {
    NSMutableArray<MCSAssetExporter *> *_Nullable retv = nil;
    for ( MCSAssetExporter *exporter in _exporters ) {
        if ( mask & (1 << exporter.status) ) {
            if ( retv == nil ) {
                retv = NSMutableArray.array;
            }
            [retv addObject:exporter];
        }
    }
    return retv.copy;
}

- (void)_statusDidChange:(MCSAssetExporter *)exporter error:(nullable NSError *)error {
    MCSAssetExportStatus status = exporter.status;
    if ( status == MCSAssetExportStatusCancelled ) {
        [self _lockInBlock:^{
            id<MCSAsset> asset = [MCSAssetManager.shared assetWithName:exporter.name type:exporter.type];
            [MCSAssetCacheManager.shared setProtected:NO forCacheWithAsset:asset];
            [_exporters removeObject:exporter];
            [_sqlite3 removeObjectForClass:MCSAssetExporter.class primaryKeyValue:@(exporter.id) error:NULL];
        }];
    }
    else {
        /// 将状态同步数据库
        ///
        /// 状态处于 Waiting, Exporting 时不需要同步至数据库, 仅维护 expoter 在内存中的状态即可.
        /// 当再次启动App时, 状态将在 Suspended, Failed, Finished 之间.
        ///
        switch ( exporter.status ) {
            case MCSAssetExportStatusFinished:
            case MCSAssetExportStatusFailed:
            case MCSAssetExportStatusSuspended:
                [_sqlite3 updateObjects:@[exporter] forKeys:@[@"status"] error:NULL];
                break;
            case MCSAssetExportStatusUnknown:
            case MCSAssetExportStatusCancelled:
            case MCSAssetExportStatusWaiting:
            case MCSAssetExportStatusExporting:
                break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( exporter.statusDidChangeExecuteBlock != nil ) {
            exporter.statusDidChangeExecuteBlock(exporter);
        }
        
        for ( id<MCSAssetExportObserver> observer in MCSAllHashTableObjects(self->_observers) ) {
            if ( [observer respondsToSelector:@selector(exporter:statusDidChange:)] ) {
                [observer exporter:exporter statusDidChange:status];
            }
        }
        
        if ( status == MCSAssetExportStatusFailed ) {
            for ( id<MCSAssetExportObserver> observer in MCSAllHashTableObjects(self->_observers) ) {
                if ( [observer respondsToSelector:@selector(exporter:statusDidChange:)] ) {
                    [observer exporter:exporter failedWithError:error];
                }
            }
        }
    });
}

- (void)_progressDidChange:(MCSAssetExporter *)exporter {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( exporter.progressDidChangeExecuteBlock != nil ) {
            exporter.progressDidChangeExecuteBlock(exporter);
        }
        
        for ( id<MCSAssetExportObserver> observer in MCSAllHashTableObjects(self->_observers) ) {
            if ( [observer respondsToSelector:@selector(exporter:progressDidChange:)] ) {
                [observer exporter:exporter progressDidChange:exporter.progress];
            }
        }
    });
}
@end

/*
 v2:
    - 需要对缓存管理进行改造
        - asset增加常驻标记
        - removeAllCaches 将不可用
        - 需要重新提供删除相关的方法
        - 需要提供常驻资源占用的缓存
        - 需要提供正常请求占用的缓存
    - 增加syncFromCache方法, 用于同步进度
    - 增加自己的状态
 */
