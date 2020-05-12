//
//  SJPlaybackHistoryControllerDefines.h
//  Pods
//
//  Created by 畅三江 on 2020/2/19.
//

#ifndef SJPlaybackHistoryControllerDefines_h
#define SJPlaybackHistoryControllerDefines_h
#if __has_include(<SJUIKit/SJSQLite3.h>)
#import <SJUIKit/SJSQLite3+QueryExtended.h>
#else
#import "SJSQLite3+QueryExtended.h"
#endif

#import "SJVideoPlayerURLAsset.h"
@protocol SJPlaybackRecord;

NS_ASSUME_NONNULL_BEGIN
@protocol SJPlaybackHistoryController <NSObject>
///
/// 保存或更新播放记录
///
- (void)save:(id<SJPlaybackRecord>)record;

///
/// 获取某个播放记录(如不存在, 返回nil)
///
- (nullable id<SJPlaybackRecord>)recordForMedia:(NSInteger)mediaId user:(NSInteger)userId;

///
/// 获取所有历史记录
///
- (nullable NSArray<id<SJPlaybackRecord>> *)allRecordsForUser:(NSInteger)userId;

///
/// 获取满足条件的记录
///
- (nullable NSArray<id<SJPlaybackRecord>> *)recordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders;

///
/// 获取满足条件指定范围的记录
///
- (nullable NSArray<id<SJPlaybackRecord>> *)recordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders range:(NSRange)range;

///
/// 获取满足条件的记录的数量
///
- (NSUInteger)countOfRecordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions;

///
/// 获取所有记录的数量
///
- (NSUInteger)count;

///
/// 删除指定的记录
///
- (void)remove:(NSInteger)media user:(NSInteger)userId;

///
/// 删除全部
///
- (void)removeAllRecords;
@end

@protocol SJPlaybackRecord <NSObject>
@property (nonatomic, readonly) NSInteger mediaId;
@property (nonatomic, readonly) NSInteger userId;
@property (nonatomic, readonly) NSTimeInterval position; ///< 上次观看到的位置
@property (nonatomic, readonly) NSTimeInterval createdTime;
@property (nonatomic, readonly) NSTimeInterval updatedTime;
@end
NS_ASSUME_NONNULL_END

#endif /* SJPlaybackHistoryControllerDefines_h */
