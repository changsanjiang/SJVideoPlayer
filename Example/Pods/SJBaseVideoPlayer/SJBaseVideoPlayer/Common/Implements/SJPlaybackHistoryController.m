//
//  SJPlaybackHistoryController.m
//  Pods
//
//  Created by 畅三江 on 2020/2/19.
//

#import "SJPlaybackHistoryController.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJPlaybackRecord ()
@property (nonatomic) NSInteger id;
@property (nonatomic) NSTimeInterval createdTime;
@property (nonatomic) NSTimeInterval updatedTime;
@end

@implementation SJPlaybackRecord
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
        _sqlite = [SJSQLite3.alloc initWithDatabasePath:path];
    }
    return self;
}

- (void)save:(SJPlaybackRecord *)record {
    if ( record != nil ) {
        SJPlaybackRecord *_Nullable old = [self recordForMedia:record.mediaId user:record.userId];
        if ( old != nil ) record.id = old.id;
        else record.createdTime = NSDate.date.timeIntervalSince1970;
        record.updatedTime = NSDate.date.timeIntervalSince1970;
        [_sqlite save:record error:NULL];
    }
}

- (nullable SJPlaybackRecord *)recordForMedia:(NSInteger)mediaId user:(NSInteger)userId {
    return [self recordsForConditions:@[
        [SJSQLite3Condition conditionWithColumn:@"mediaId" value:@(mediaId)],
        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)]
    ] orderBy:nil].lastObject;
}

- (nullable NSArray<SJPlaybackRecord *> *)allRecordsForUser:(NSInteger)userId {
    return [self recordsForConditions:@[
        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)]
    ] orderBy:nil];
}

- (nullable NSArray<SJPlaybackRecord *> *)recordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders {
    return [_sqlite objectsForClass:SJPlaybackRecord.class conditions:conditions orderBy:orders error:NULL];
}

- (nullable NSArray<SJPlaybackRecord *> *)recordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders range:(NSRange)range {
    return [_sqlite objectsForClass:SJPlaybackRecord.class conditions:conditions orderBy:orders range:range error:NULL];
}

- (NSUInteger)countOfRecordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions {
    return [_sqlite countOfObjectsForClass:SJPlaybackRecord.class conditions:conditions error:NULL];
}

- (NSUInteger)count {
    return [self countOfRecordsForConditions:nil];
}

- (void)remove:(NSInteger)media user:(NSInteger)userId {
    SJPlaybackRecord *record = [self recordForMedia:media user:userId];
    if ( record == nil ) return;
    [_sqlite removeObjectsForClass:SJPlaybackRecord.class primaryKeyValues:@[@(record.id)] error:NULL];
}

- (void)removeAllRecords {
    [_sqlite removeAllObjectsForClass:SJPlaybackRecord.class error:NULL];
}
@end
NS_ASSUME_NONNULL_END
