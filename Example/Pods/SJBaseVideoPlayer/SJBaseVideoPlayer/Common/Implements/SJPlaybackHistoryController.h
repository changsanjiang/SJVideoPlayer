//
//  SJPlaybackHistoryController.h
//  Pods
//
//  Created by 畅三江 on 2020/2/19.
//

#import <Foundation/Foundation.h>
#import "SJPlaybackHistoryControllerDefines.h"
#import "SJPlaybackRecord.h"
#import <objc/message.h>
NS_ASSUME_NONNULL_BEGIN
///
/// `SJPlaybackRecord`播放记录
///
/// \code
/// 如需为播放记录扩充自己的属性, 请参照如下步骤:
///
///    步骤1: 创建分类, 添加自己需要的属性
///    @interface SJPlaybackRecord (Extended)
///    @property (nonatomic, copy, nullable) NSString *title;
///    @property (nonatomic) BOOL test;
///    @end
///
///    步骤2: 实现分类方法
///    @implementation SJPlaybackRecord (Extended)
///    - (void)setTitle:(nullable NSString *)title {
///        objc_setAssociatedObject(self, @selector(title), title, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
///    }
///    - (nullable NSString *)title {
///        return objc_getAssociatedObject(self, _cmd);
///    }
///
///    - (void)setTest:(BOOL)test {
///        objc_setAssociatedObject(self, @selector(test), @(test), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
///    }
///    - (BOOL)test {
///        return [objc_getAssociatedObject(self, _cmd) boolValue];
///    }
///    @end
///
///    步骤3: 赋值
///    record.title = @"标题adc";
///    record.test = YES;
///
///    完成以上步骤即可. 管理类保存该条记录时, 相应的扩充属性也会被保存进数据库中
/// \endcode
///
@interface SJPlaybackRecord(SJSQLite3Extended)<SJSQLiteTableModelProtocol>

@end

extern SJMediaType const SJMediaTypeVideo;
extern SJMediaType const SJMediaTypeAudio;

///
/// \code
///    // 请在合适的时机 保存播放记录
///    SJPlaybackRecord *record = SJPlaybackRecord.alloc.init;
///    record.mediaId = media.id;
///    record.userId = user.id; // The user id of the current login
///    record.mediaType = SJMediaTypeVideo;
///    record.position = _player.currentTime;
///    record.title = media.title; // 可对record扩充自定义属性, 详情请前往`SJPlaybackHistoryController.h`查看
///    [SJPlaybackHistoryController.shared save:record];
/// \endcode
///
@interface SJPlaybackHistoryController : NSObject<SJPlaybackHistoryController>
+ (instancetype)shared;
- (instancetype)initWithPath:(NSString *)path;

///
/// 保存或更新播放记录
///
- (void)save:(SJPlaybackRecord *)record;

#pragma mark -

///
/// 查询, 如不存在将返回 nil
///
- (nullable SJPlaybackRecord *)recordForMedia:(NSInteger)mediaId user:(NSInteger)userId mediaType:(SJMediaType)mediaType;

///
/// 查询
///
- (nullable NSArray<SJPlaybackRecord *> *)recordsForUser:(NSInteger)userId mediaType:(SJMediaType)mediaType range:(NSRange)range;

///
/// 查询
///
- (nullable NSArray<SJPlaybackRecord *> *)recordsForUser:(NSInteger)userId mediaType:(SJMediaType)mediaType;

///
/// 查询
///
/// \code
///    // 这个方法适合分页查询的场景, 当数据量过大时, 可以指定请求的range
///    // 根据指定的`用户id`以及`mediaType`进行查询, 并将结果排序(以更新的时间倒序排列), 返回满足条件的前20条数据
///    NSArray *records = [SJPlaybackHistoryController.shared recordsForConditions:@[
///        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)],
///        [SJSQLite3Condition conditionWithColumn:@"mediaType" value:SJMediaTypeVideo],
///    ] orderBy:@[
///        [SJSQLite3ColumnOrder orderWithColumn:@"updatedTime" ascending:NO]
///    ] range:NSMakeRange(0, 20)];
/// \endcode
///
- (nullable NSArray<SJPlaybackRecord *> *)recordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders range:(NSRange)range;

///
/// 查询
///
/// \code
///    // 根据指定的`用户id`以及`mediaType`进行查询, 并将结果排序(以更新的时间倒序排列), 返回满足条件的数据
///    NSArray *records = [SJPlaybackHistoryController.shared recordsForConditions:@[
///        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)],
///        [SJSQLite3Condition conditionWithColumn:@"mediaType" value:SJMediaTypeVideo],
///    ] orderBy:@[
///        [SJSQLite3ColumnOrder orderWithColumn:@"updatedTime" ascending:NO]
///    ]];
/// \endcode
///
- (nullable NSArray<SJPlaybackRecord *> *)recordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders;

#pragma mark -

///
/// 查询数量
///
- (NSUInteger)countOfRecordsForUser:(NSInteger)userId mediaType:(SJMediaType)mediaType;

///
/// 查询数量
///
/// \code
///    // 根据指定的`用户id`以及`mediaType`进行查询
///    [SJPlaybackHistoryController.shared countOfRecordsForConditions:@[
///        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)],
///        [SJSQLite3Condition conditionWithColumn:@"mediaType" value:SJMediaTypeVideo],
///    ]];
/// \endcode
///
- (NSUInteger)countOfRecordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions;

#pragma mark -

///
/// 删除
///
- (void)remove:(NSInteger)media user:(NSInteger)userId mediaType:(SJMediaType)mediaType;

///
/// 删除
///
- (void)removeAllRecordsForUser:(NSInteger)userId mediaType:(SJMediaType)mediaType;

///
/// 删除
///
/// \code
///    [SJPlaybackHistoryController.shared removeForConditions:@[
///        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)],
///        [SJSQLite3Condition conditionWithColumn:@"mediaType" value:SJMediaTypeVideo],
///    ]];
/// \endcode
///
- (void)removeForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions;
@end
NS_ASSUME_NONNULL_END
