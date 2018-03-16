//
//  SJMediaDownloader.m
//  SJMediaDownloader
//
//  Created by BlueDancer on 2018/3/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJMediaDownloader.h"
#import <sqlite3.h>
#import <objc/message.h>
#import <sys/xattr.h>

NS_ASSUME_NONNULL_BEGIN

#define DEBUG_CONDITION 1

inline static bool sql_exe(sqlite3 *database, const char *sql);
inline static NSArray<id> *sql_query(sqlite3 *database, const char *sql, Class cls);

typedef NS_ENUM(NSInteger, SJMediaDownloadErrorCode) {
    SJMediaDownloadErrorCode_Unknown,
    SJMediaDownloadErrorCode_Cancelled = -999,
    SJMediaDownloadErrorCode_TimeOut = -1001,
    SJMediaDownloadErrorCode_ConnectionWasLost = -1005,
};

@interface SJMediaEntity : NSObject <SJMediaEntity>
@property (nonatomic, assign) SJMediaDownloadStatus downloadStatus;
@property (nonatomic, assign) NSInteger mediaId;
@property (nonatomic, strong) NSString *URLStr;
@property (nonatomic, assign) NSTimeInterval downloadTime;  // 插入数据库的时间
@property (nonatomic, assign) float progress;

@property (nonatomic, strong, nullable) NSString *title;
@property (class, nonatomic, strong, readonly) NSString *rootFolder;
@property (class, nonatomic, assign) BOOL startNotifi;
@property (nonatomic, weak, nullable) NSURLSessionDownloadTask *task;
@property (nonatomic, copy, nullable) void(^cancel)(void);
@property (nonatomic, strong, nullable) NSString *relativePath;
@property (nonatomic, strong, readonly) NSString *URLHashStr;
@property (nonatomic, strong, readonly) NSString *resumePath;
@property (nonatomic, strong, readonly) NSString *format;
@property (nonatomic, strong, readonly) NSURL *URL;
- (void)postStatus;
- (void)postProgress;
@end

@interface SJMediaDownloader (DownloadServer)<NSURLSessionDownloadDelegate>
@end

@interface NSURLSessionTask (SJDownloaderAdd)
@property (nonatomic, copy, nullable) void(^downloadProgressBlock)(__kindof NSURLSessionTask *task, float progress);;
@property (nonatomic, copy, nullable) void(^endDownloadHandleBlock)(__kindof NSURLSessionTask *task, NSURL *__nullable location, NSError *__nullable error);
@end

@interface SJMediaDownloader ()
@property (nonatomic, strong, readwrite, nullable) SJMediaEntity *currentEntity;
@property (nonatomic, strong, readonly) NSOperationQueue *taskQueue;
@property (nonatomic, strong, readonly) NSURLSession *downloadSession;
@property (nonatomic, assign, readonly) sqlite3 *database;
@end
NS_ASSUME_NONNULL_END

@implementation SJMediaDownloader

+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self initializeDatabase];
    [self installNotifications];
    [self checkoutRootFolder];
    return self;
}

- (void)checkoutRootFolder {
    NSString *rootFolder = [SJMediaEntity rootFolder];
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:rootFolder] ) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootFolder withIntermediateDirectories:YES attributes:nil error:nil];
        [self addSkipBackupAttributeToItemAtPath:rootFolder]; // do not backup
    };
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path {
    const char* filePath = [path fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

- (void)startNotifier {
    SJMediaEntity.startNotifi = YES;
}

- (void)stopNotifier {
    SJMediaEntity.startNotifi = NO;
}

@synthesize taskQueue = _taskQueue;
- (NSOperationQueue *)taskQueue {
    if ( _taskQueue ) return _taskQueue;
    _taskQueue = [NSOperationQueue new];
    _taskQueue.maxConcurrentOperationCount = 1;
    _taskQueue.name = @"com.sjmediadownloader.taskqueue";
    return _taskQueue;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmismatched-parameter-types"
- (void)async_requestMediasCompletion:(void(^)(SJMediaDownloader *downloader, NSArray<SJMediaEntity *> *medias))completionBlock {
    __weak typeof(self) _self = self;
    [self.taskQueue addOperationWithBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completionBlock ) completionBlock(self, sql_query(self.database, "SELECT *FROM 'SJMediaEntity';", [SJMediaEntity class]));
    }];
}
- (void)async_requestMediaWithID:(NSInteger)mediaId
                      completion:(void(^)(SJMediaDownloader *downloader, SJMediaEntity *media))completionBlock {
    __weak typeof(self) _self = self;
    [self.taskQueue addOperationWithBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT *FROM 'SJMediaEntity' WHERE mediaId = %zd;", mediaId];
        if ( completionBlock ) completionBlock(self, sql_query(self.database, sqlStr.UTF8String, [SJMediaEntity class]).firstObject);
    }];
}
- (void)sync_requestNextDownloadMedia {
    if ( self.currentEntity ) return;
    NSString *sql = [NSString stringWithFormat:@"SELECT *FROM 'SJMediaEntity' WHERE status =  %zd ORDER BY 'downloadTime';", SJMediaDownloadStatus_Waiting];
    SJMediaEntity *next = sql_query(self.database, sql.UTF8String, [SJMediaEntity class]).firstObject;
    if ( !next ) return;
    self.currentEntity = next;
    next.downloadStatus = SJMediaDownloadStatus_Downloading;
    [next postStatus];
    NSURLSessionDownloadTask *task = nil;
    NSData *resumeData = [NSData dataWithContentsOfFile:next.resumePath];
    if ( resumeData ) {
        task = [self.downloadSession downloadTaskWithResumeData:resumeData];
#if DEBUG_CONDITION
        NSLog(@"resume");
#endif
    }
    else {
        task = [self.downloadSession downloadTaskWithURL:next.URL];
#if DEBUG_CONDITION
        NSLog(@"new download");
#endif
    }
    
    [task resume];
    
    /// task
    next.task = task;
    
    task.downloadProgressBlock = ^(__kindof NSURLSessionTask * _Nonnull task, float progress) {
        next.progress = progress;
        [next postProgress];
    };
    
    __weak typeof(self) _self = self;
    task.endDownloadHandleBlock = ^(NSURLSessionDownloadTask * _Nonnull task, NSURL * _Nullable location, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
#if DEBUG_CONDITION
        NSLog(@"%@\n ----- %zd", error, next.downloadStatus);
#endif
        self.currentEntity = nil;
        if ( location ) {
            NSString *relativePath = [NSString stringWithFormat:@"%@", next.URLHashStr];
            NSString *saveFolder = [[SJMediaEntity rootFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", relativePath]];
            NSString *savePath = [saveFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", next.URLHashStr, next.format]];
            [[NSFileManager defaultManager] createDirectoryAtPath:saveFolder withIntermediateDirectories:YES attributes:nil error:nil];
            [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:savePath error:nil];
            next.relativePath = relativePath;
            next.downloadStatus = SJMediaDownloadStatus_Finished;
            [next postStatus];
            [self sync_insertOrReplaceMediaWithEntity:next];
            [self sync_requestNextDownloadMedia];
        }
        else {
            switch ( (SJMediaDownloadErrorCode)error.code ) {
                case SJMediaDownloadErrorCode_Unknown: break;
                case SJMediaDownloadErrorCode_TimeOut: {
                    [self async_suspendWithTask:task entity:next status:SJMediaDownloadStatus_TimeOut completion:^{
                        __strong typeof(_self) self = _self;
                        if ( !self ) return;
                        [self sync_requestNextDownloadMedia];
                    }];
                }
                    break;
                case SJMediaDownloadErrorCode_Cancelled: {
                    if ( next.cancel ) next.cancel();
                    next.cancel = nil;
                    if ( next.downloadStatus == SJMediaDownloadStatus_Paused ) [self sync_insertOrReplaceMediaWithEntity:next];
                    else [self sync_deleteMediaWithEntity:next];
                    [self sync_requestNextDownloadMedia];
                }
                    break;
                case SJMediaDownloadErrorCode_ConnectionWasLost: {
                    [self async_suspendWithTask:task entity:next status:SJMediaDownloadStatus_ConnectionWasLost completion:^{
                        __strong typeof(_self) self = _self;
                        if ( !self ) return;
                        [self sync_requestNextDownloadMedia];
                    }];
                }
                    break;
            }
        }
    };
}
- (void)async_suspendWithTask:(NSURLSessionDownloadTask *)task entity:( SJMediaEntity *)entity status:(SJMediaDownloadStatus)status completion:(void(^)(void))block {
    __weak typeof(self) _self = self;
    [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        NSString *folder = [entity.resumePath stringByDeletingLastPathComponent];
        if ( ![[NSFileManager defaultManager] fileExistsAtPath:folder] ) {
            [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [resumeData writeToFile:entity.resumePath atomically:YES];
        entity.downloadStatus = status;
        [entity postStatus];
        [self sync_insertOrReplaceMediaWithEntity:entity];
        [self.taskQueue addOperationWithBlock:^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( block ) block();
        }];
    }];
}
- (void)sync_insertOrReplaceMediaWithEntity:(SJMediaEntity *)entity {
    sql_exe(self.database, [NSString stringWithFormat:@"INSERT OR REPLACE INTO 'SJMediaEntity' VALUES (%zd, '%@', %zd, '%@', '%ld', '%@');", entity.mediaId, entity.title, entity.downloadStatus, entity.URLStr, time(NULL), entity.relativePath].UTF8String);
}
- (void)sync_deleteMediaWithEntity:(SJMediaEntity *)entity {
    sql_exe(self.database, [NSString stringWithFormat:@"DELETE FROM 'SJMediaEntity' WHERE mediaId = %zd;", entity.mediaId].UTF8String);
}
- (void)initializeDatabase {
    sql_exe(self.database, "CREATE TABLE IF NOT EXISTS SJMediaEntity ( 'mediaId' INTEGER PRIMARY KEY, 'title' TEXT, 'status' INTEGER, 'URLStr' TEXT, 'downloadTime' INTEGER, 'relativePath' TEXT);");
}
@synthesize database = _database;
- (sqlite3 *)database {
    if ( _database ) return _database;
    NSString *folder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"com.sjmediadownloader.databasefolder"];
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:folder] ) [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *dbPath = [folder stringByAppendingPathComponent:@"mediaentity.db"];
    if ( SQLITE_OK != sqlite3_open(dbPath.UTF8String, &_database) ) NSLog(@"init database failed!");
    return _database;
}
#pragma clang diagnostic pop

#pragma mark - download
@synthesize downloadSession = _downloadSession;
- (NSURLSession *)downloadSession {
    if ( _downloadSession ) return _downloadSession;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _downloadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.taskQueue];
    return _downloadSession;
}

- (void)async_downloadWithID:(NSInteger)mediaId title:(NSString * __nullable)title mediaURLStr:(NSString *)mediaURLStr tmpEntity:(void(^ __nullable)(id<SJMediaEntity> entiry))entity {
    __weak typeof(self) _self = self;
    [self async_requestMediaWithID:mediaId completion:^(SJMediaDownloader * _Nonnull downloader, SJMediaEntity * media) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( media.downloadStatus == SJMediaDownloadStatus_Downloading ||
             media.downloadStatus == SJMediaDownloadStatus_Waiting ) {
        }
        else if ( !media ) {
            media = [SJMediaEntity new];
            media.mediaId = mediaId;
            media.title = title;
            media.URLStr = mediaURLStr;
            media.downloadStatus = SJMediaDownloadStatus_Waiting;
            [self sync_insertOrReplaceMediaWithEntity:media];
        }
        else if ( media.downloadStatus != SJMediaDownloadStatus_Finished ) {
            media.downloadStatus = SJMediaDownloadStatus_Waiting;
            [media postStatus];
            [self sync_insertOrReplaceMediaWithEntity:media];
        }
        if ( entity ) entity(media);
        [self sync_requestNextDownloadMedia];
    }];
}

- (void)async_pauseWithMediaID:(NSInteger)mediaId completion:(void(^)(void))block {
    __weak typeof(self) _self = self;
    [self.taskQueue addOperationWithBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.currentEntity && self.currentEntity.mediaId == mediaId ) {
            if ( self.currentEntity.downloadStatus == SJMediaDownloadStatus_Waiting ) {
                self.currentEntity.downloadStatus = SJMediaDownloadStatus_Paused;
                [self sync_insertOrReplaceMediaWithEntity:self.currentEntity];
                [self sync_requestNextDownloadMedia];
                [self.currentEntity postStatus];
                if ( block ) block();
            }
            else if ( self.currentEntity.downloadStatus == SJMediaDownloadStatus_Downloading ) {
                [self async_suspendWithTask:self.currentEntity.task entity:self.currentEntity status:SJMediaDownloadStatus_Paused completion:^{
                    if ( block ) block();
                }];
            }
            return;
        }
        // else
        [self async_requestMediaWithID:mediaId completion:^(SJMediaDownloader * _Nonnull downloader, SJMediaEntity *media) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( media.downloadStatus == SJMediaDownloadStatus_Finished ) {
                NSLog(@"文件已下载, 无法暂停");
            }
            else {
                media.downloadStatus = SJMediaDownloadStatus_Paused;
                [self sync_insertOrReplaceMediaWithEntity:media];
                [self.currentEntity postStatus];
                if ( block ) block();
            }
        }];
    }];
}

- (void)async_deleteWithMediaID:(NSInteger)mediaId completion:(void(^)(void))block {
    __weak typeof(self) _self = self;
    [self.taskQueue addOperationWithBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.currentEntity && self.currentEntity.mediaId == mediaId ) {
            if ( self.currentEntity.downloadStatus == SJMediaDownloadStatus_Downloading ) {
                self.currentEntity.cancel = ^{
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    [self sync_deleteMediaWithEntity:self.currentEntity];
                    if ( block ) block();
                };
                self.currentEntity.downloadStatus = SJMediaDownloadStatus_Cancelled;
                [self.currentEntity.task cancel];
            }
            else {
                [self sync_deleteMediaWithEntity:self.currentEntity];
                if ( block ) block();
            }
            return;
        }
        // else
        [self async_requestMediaWithID:mediaId completion:^(SJMediaDownloader * _Nonnull downloader, SJMediaEntity *media) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( [[NSFileManager defaultManager] fileExistsAtPath:media.resumePath] ) {
                [[NSFileManager defaultManager] removeItemAtPath:media.resumePath error:nil];
            }
            [self sync_deleteMediaWithEntity:media];
            if ( block ) block();
        }];
    }];
}
#pragma mark -

#pragma mark -
- (void)installNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)applicationWillTerminate {
    [_downloadSession invalidateAndCancel];
}

@end

@implementation SJMediaDownloader (DownloadServer)
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
    if ( downloadTask.downloadProgressBlock ) downloadTask.downloadProgressBlock(downloadTask, progress);
}
- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    if ( downloadTask.endDownloadHandleBlock ) downloadTask.endDownloadHandleBlock(downloadTask, location, nil);
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if ( task.endDownloadHandleBlock ) task.endDownloadHandleBlock(task, nil, error);
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
#if DEBUG_CONDITION
    NSLog(@"\nmediaId:%zd \noffset: %zd \ntotal: %zd", self.currentEntity.mediaId, fileOffset, expectedTotalBytes);
#endif
}
@end

@implementation NSURLSessionTask (SJDownloaderAdd)
- (void)setDownloadProgressBlock:(void (^ __nullable)(__kindof NSURLSessionTask * _Nonnull, float))downloadProgressBlock {
    objc_setAssociatedObject(self, @selector(downloadProgressBlock), downloadProgressBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^ __nullable)(__kindof NSURLSessionTask * _Nonnull, float))downloadProgressBlock {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setEndDownloadHandleBlock:(void (^__nullable)(__kindof NSURLSessionTask * _Nonnull, NSURL * _Nullable, NSError * _Nullable))endDownloadHandleBlock {
    objc_setAssociatedObject(self, @selector(endDownloadHandleBlock), endDownloadHandleBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^__nullable)(__kindof NSURLSessionTask * _Nonnull, NSURL * _Nullable, NSError * _Nullable))endDownloadHandleBlock {
    return objc_getAssociatedObject(self, _cmd);
}
@end

@implementation SJMediaEntity
@synthesize downloadStatus = _downloadStatus;
@synthesize mediaId = _mediaId;
@synthesize URLStr = _URLStr;
@synthesize filePath = _filePath;
@synthesize URLHashStr = _URLHashStr;
- (NSString *)URLHashStr {
    if ( !_URLStr ) return nil;
    if ( _URLHashStr ) return _URLHashStr;
    _URLHashStr = [NSString stringWithFormat:@"%zd", [_URLStr hash]];
    return _URLHashStr;
}
@synthesize format = _format;
- (NSString *)format {
    if ( !_URLStr ) return nil;
    if ( _format ) return _format;
    _format = [_URLStr.lastPathComponent componentsSeparatedByString:@"."].lastObject;
    return _format;
}
@synthesize URL = _URL;
- (NSURL *)URL {
    if ( !_URLStr ) return nil;
    if ( _URL ) return _URL;
    _URL = [NSURL URLWithString:_URLStr];
    return _URL;
}
@synthesize resumePath = _resumePath;
- (NSString *)resumePath {
    if ( _resumePath ) return _resumePath;
    _resumePath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.URLHashStr];
    return _resumePath;
}
- (NSString *)filePath {
    if ( !_relativePath ) return nil;
    if ( _filePath ) return _filePath;
    _filePath = [[SJMediaEntity rootFolder] stringByAppendingPathComponent:_relativePath];
    return _filePath;
}
+ (NSString *)rootFolder {
    NSString *rootFolder = objc_getAssociatedObject(self, _cmd);
    if ( rootFolder ) return rootFolder;
    rootFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"sj_downloader_root_folder"];
    objc_setAssociatedObject(self, _cmd, rootFolder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return rootFolder;
}
+ (void)setStartNotifi:(BOOL)startNotifi {
    objc_setAssociatedObject(self, @selector(startNotifi), @(startNotifi), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
+ (BOOL)startNotifi {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)postStatus {
    if ( [SJMediaEntity startNotifi] ) [[NSNotificationCenter defaultCenter] postNotificationName:SJMediaDownloadStatusChangedNotification object:self];
}
- (void)postProgress {
    if ( [SJMediaEntity startNotifi] ) [[NSNotificationCenter defaultCenter] postNotificationName:SJMediaDownloadProgressNotification object:self];
}
@end

static NSArray <id> *sql_data(sqlite3_stmt *stmt, Class cls);

inline static bool sql_exe(sqlite3 *database, const char *sql) {
    char *error = NULL;
    bool r = (SQLITE_OK == sqlite3_exec(database, sql, NULL, NULL, &error));
    if ( error != NULL ) { NSLog(@"Error ==> \n SQL  : %s\n Error: %s", sql, error); sqlite3_free(error);}
    return r;
}

inline static NSArray<id> *sql_query(sqlite3 *database, const char *sql, Class cls) {
    sqlite3_stmt *pstmt;
    int result = sqlite3_prepare_v2(database, sql, -1, &pstmt, NULL);
    NSArray <NSDictionary *> *dataArr = nil;
    if (SQLITE_OK == result) dataArr = sql_data(pstmt, cls);
    sqlite3_finalize(pstmt);
    return dataArr;
}

static NSArray <id> *sql_data(sqlite3_stmt *stmt, Class cls) {
    NSMutableArray *dataArrM = [[NSMutableArray alloc] init];
    while ( sqlite3_step(stmt) == SQLITE_ROW ) {
        id model = [cls new];
        int columnCount = sqlite3_column_count(stmt);
        for ( int i = 0; i < columnCount ; ++ i ) {
            const char *c_key = sqlite3_column_name(stmt, i);
            NSString *oc_key = [NSString stringWithCString:c_key encoding:NSUTF8StringEncoding];
            int type = sqlite3_column_type(stmt, i);
            switch (type) {
                case SQLITE_INTEGER: {
                    int value = sqlite3_column_int(stmt, i);
                    [model setValue:@(value) forKey:oc_key];
                }
                    break;
                case SQLITE_TEXT: {
                    const  char *value = (const  char *)sqlite3_column_text(stmt, i);
                    [model setValue:[NSString stringWithUTF8String:value] forKey:oc_key];
                }
                    break;
                case SQLITE_FLOAT: {
                    double value = sqlite3_column_double(stmt, i);
                    [model setValue:@(value) forKey:oc_key];
                }
                    break;
                default:
                    break;
            }
        }
        [dataArrM addObject:model];
    }
    if ( dataArrM.count == 0 ) return nil;
    return dataArrM.copy;
}

NSNotificationName const SJMediaDownloadProgressNotification = @"SJMediaDownloadProgressNotification";
NSString *const kSJMediaDownloadProgressKey = @"kSJMediaDownloadProgressKey";
NSNotificationName const SJMediaDownloadStatusChangedNotification = @"SJMediaDownloadStatusChangedNotification";
