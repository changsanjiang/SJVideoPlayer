//
//  SJPlaybackHistoryController.m
//  Pods
//
//  Created by 畅三江 on 2020/2/19.
//

#import "SJPlaybackHistoryController.h"
#if __has_include(<SJUIKit/SJSQLite3.h>)
#import <SJUIKit/SJSQLite3+Private.h>
#import <SJUIKit/SJSQLite3+RemoveExtended.h>
#import <SJUIKit/SJSQLite3+TableExtended.h>
#else
#import "SJSQLite3+Private.h"
#import "SJSQLite3+RemoveExtended.h"
#import "SJSQLite3+TableExtended.h"
#endif

NS_ASSUME_NONNULL_BEGIN
SJMediaType const SJMediaTypeVideo = @"video";
SJMediaType const SJMediaTypeAudio = @"audio";

@implementation SJPlaybackRecord(SJSQLite3Extended)
+ (nullable NSString *)sql_primaryKey {
    return @"id";
}

+ (nullable NSArray<NSString *> *)sql_autoincrementlist {
    return @[@"id"];
}
@end

@interface SJPlaybackHistoryController ()
@property (nonatomic, strong, nullable) SJSQLite3 *sqlite;
@end

@implementation SJPlaybackHistoryController
+ (instancetype)shared {
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"com.SJBaseVideoPlayer.history/sj.db"];
        obj = [SJPlaybackHistoryController.alloc initWithPath:path];
    });
    return obj;
}

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if ( self ) {
        self.sqlite = [SJSQLite3.alloc initWithDatabasePath:path];
    }
    return self;
}

- (void)save:(SJPlaybackRecord *)record {
    if ( record != nil ) {
        SJPlaybackRecord *_Nullable old = [self recordForMedia:record.mediaId user:record.userId mediaType:record.mediaType];
        if ( old != nil ) record.id = old.id;
        else record.createdTime = NSDate.date.timeIntervalSince1970;
        record.updatedTime = NSDate.date.timeIntervalSince1970;
        [_sqlite save:record error:NULL];
    }
}

- (nullable SJPlaybackRecord *)recordForMedia:(NSInteger)mediaId user:(NSInteger)userId mediaType:(SJMediaType)mediaType {
    NSParameterAssert(mediaType);
    return [self recordsForConditions:@[
        [SJSQLite3Condition conditionWithColumn:@"mediaId" value:@(mediaId)],
        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)],
        [SJSQLite3Condition conditionWithColumn:@"mediaType" value:mediaType]
    ] orderBy:nil].lastObject;
}

- (nullable NSArray<SJPlaybackRecord *> *)recordsForUser:(NSInteger)userId mediaType:(SJMediaType)mediaType range:(NSRange)range {
    return [self recordsForConditions:@[
        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)],
        [SJSQLite3Condition conditionWithColumn:@"mediaType" value:mediaType],
    ] orderBy:@[
        [SJSQLite3ColumnOrder orderWithColumn:@"updatedTime" ascending:NO]
    ] range:range];
}

- (nullable NSArray<SJPlaybackRecord *> *)recordsForUser:(NSInteger)userId mediaType:(SJMediaType)mediaType {
    return [self recordsForUser:userId mediaType:mediaType range:NSMakeRange(0, NSUIntegerMax)];
}

- (nullable NSArray<SJPlaybackRecord *> *)recordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders {
    return [self recordsForConditions:conditions orderBy:orders range:NSMakeRange(0, NSUIntegerMax)];
}

- (nullable NSArray<SJPlaybackRecord *> *)recordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders range:(NSRange)range {
    return [_sqlite objectsForClass:SJPlaybackRecord.class conditions:conditions orderBy:orders range:range error:NULL];
}

- (NSUInteger)countOfRecordsForUser:(NSInteger)userId mediaType:(SJMediaType)mediaType {
    return [self countOfRecordsForConditions:@[
        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)],
        [SJSQLite3Condition conditionWithColumn:@"mediaType" value:mediaType],
    ]];
}

- (NSUInteger)countOfRecordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions {
    return [_sqlite countOfObjectsForClass:SJPlaybackRecord.class conditions:conditions error:NULL];
}

- (void)remove:(NSInteger)media user:(NSInteger)userId mediaType:(SJMediaType)mediaType {
    NSParameterAssert(mediaType);
    SJPlaybackRecord *record = [self recordForMedia:media user:userId mediaType:mediaType];
    if ( record == nil ) return;
    [_sqlite removeObjectsForClass:SJPlaybackRecord.class primaryKeyValues:@[@(record.id)] error:NULL];
}

- (void)removeAllRecordsForUser:(NSInteger)userId mediaType:(SJMediaType)mediaType {
    NSParameterAssert(mediaType);
    [_sqlite removeAllObjectsForClass:SJPlaybackRecord.class conditions:@[
        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)],
        [SJSQLite3Condition conditionWithColumn:@"mediaType" value:mediaType],
    ] error:NULL];
}

- (void)removeForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions {
    [_sqlite removeAllObjectsForClass:SJPlaybackRecord.class conditions:conditions error:NULL];
}
@end
NS_ASSUME_NONNULL_END
