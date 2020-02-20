//
//  SJPlaybackHistoryController.h
//  Pods
//
//  Created by 畅三江 on 2020/2/19.
//

#import <Foundation/Foundation.h>
#import "SJPlaybackHistoryControllerDefines.h"
#import <objc/message.h>
NS_ASSUME_NONNULL_BEGIN
///
/// 播放记录
///
/// \code
/// 如需扩充其他属性, 请参照如下步骤:
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
///    完成以上步骤即可. 管理类保存该条记录时, 相应的扩充属性也会被保存进数据库中
/// \endcod
///

@interface SJPlaybackRecord : NSObject<SJPlaybackRecord, SJSQLiteTableModelProtocol>
@property (nonatomic) NSInteger mediaId;
@property (nonatomic) NSInteger userId;
@property (nonatomic) NSTimeInterval position;
@end


///
/// \code
///    // 请在合适的时机 保存播放记录
///    SJPlaybackRecord *record = SJPlaybackRecord.alloc.init;
///    record.mediaId = media.id;
///    record.userId = user.id; // The user id of the current login
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

///
/// 获取某个播放记录(如不存在, 返回nil)
///
- (nullable SJPlaybackRecord *)recordForMedia:(NSInteger)mediaId user:(NSInteger)userId;

///
/// 获取所有历史记录
///
- (nullable NSArray<SJPlaybackRecord *> *)allRecordsForUser:(NSInteger)userId;

///
/// 获取满足条件的记录
///
- (nullable NSArray<SJPlaybackRecord *> *)recordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders;

///
/// 获取满足条件指定范围的记录
///
- (nullable NSArray<SJPlaybackRecord *> *)recordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders range:(NSRange)range;

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
NS_ASSUME_NONNULL_END
