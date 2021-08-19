//
//  SJSQLite3+FoundationExtended.m
//  SJUIKit
//
//  Created by 畅三江 on 2019/10/21.
//

#import "SJSQLite3+FoundationExtended.h"
#import "SJSQLiteErrors.h"
#if __has_include(<YYModel/YYModel.h>)
#import <YYModel/NSObject+YYModel.h>
#elif __has_include(<YYKit/YYKit.h>)
#import <YYKit/YYKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJSQLite3BasicTypeItem : NSObject<SJSQLiteTableModelProtocol>
@property (nonatomic, copy, nullable) NSString *key;
@property (nonatomic, copy, nullable) NSString *value;
@end

@implementation SJSQLite3BasicTypeItem
+ (nullable NSString *)sql_primaryKey {
    return @"key";
}
@end

@implementation SJSQLite3 (FoundationExtended)
/// 将数据保存到数据库表中. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param value                需要保存的值. 支持的数据类型有: integer, float, double, NSString, 以及可序列化为`json字符串`的对象.
///
/// @param key                  用来关联值的键.
///
/// @param error                执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
/// @return                     操作是否成功.
///
- (BOOL)save:(nullable id)value forKey:(NSString *)key error:(NSError **)error {
    if ( value == nil ) {
        return [self removeValueForKey:key error:error];
    }
    
    NSString *_Nullable data = nil;
    if ( [value isKindOfClass:NSString.class] ) {
        data = value;
    }
    else if ( [value isKindOfClass:NSURL.class] || [value isKindOfClass:NSValue.class] ) {
        data = [value description];
    }
    else {
#if __has_include(<YYModel/YYModel.h>)
        data = [value yy_modelToJSONString];
#elif __has_include(<YYKit/YYKit.h>)
        data = [value modelToJSONString];
#else
        NSAssert(NO, @"请导入YYModel或者YYKit");
#endif
    }
    
    if ( data == nil ) {
        if ( error != NULL ) *error = sqlite3_error_make_error(@"不支持的存储类型");
        return NO;
    }
    SJSQLite3BasicTypeItem *item = SJSQLite3BasicTypeItem.new;
    item.key = key;
    item.value = data;
    return [self save:item error:error];
}

- (BOOL)setValue:(nullable id)value forKey:(NSString *)key error:(NSError **)error {
    return [self save:value forKey:key error:error];
}
- (BOOL)setDictionary:(nullable NSDictionary *)value forKey:(NSString *)key error:(NSError **)error {
    return [self save:value forKey:key error:error];
}
- (BOOL)setArray:(nullable NSArray *)value forKey:(NSString *)key error:(NSError **)error {
    return [self save:value forKey:key error:error];
}
- (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key error:(NSError **)error {
    return [self save:value forKey:key error:error];
}
- (BOOL)setURL:(nullable NSURL *)value forKey:(NSString *)key error:(NSError **)error {
    return [self save:value forKey:key error:error];
}
- (BOOL)setInteger:(NSInteger)value forKey:(NSString *)key error:(NSError **)error {
    return [self save:@(value) forKey:key error:error];
}
- (BOOL)setDouble:(double)value forKey:(NSString *)key error:(NSError **)error {
    return [self save:@(value) forKey:key error:error];
}
- (BOOL)setFloat:(float)value forKey:(NSString *)key error:(NSError **)error {
    return [self save:@(value) forKey:key error:error];
}
- (BOOL)setBool:(BOOL)value forKey:(NSString *)key error:(NSError **)error {
    return [self save:@(value) forKey:key error:error];
}

/// 删除指定键的值. 该操作将会开启一个新的事务, 当执行出错时, 数据库将回滚到执行之前的状态.
///
/// @param key                  用来关联值的键.
///
/// @param error                执行出错. 当执行发生错误时, 会暂停执行后续的sql语句, 数据库将回滚到执行之前的状态.
///
- (BOOL)removeValueForKey:(NSString *)key error:(NSError **)error {
    return [self removeObjectForClass:SJSQLite3BasicTypeItem.class primaryKeyValue:key error:error];
}

- (nullable NSString *)stringForKey:(NSString *)key {
    return [self _itemValueForKey:key];
}

- (nullable NSArray *)arrayForKey:(NSString *)key {
    return [self _containerValueForKey:key];
}

- (nullable id)objectForKey:(NSString *)key objectClass:(Class)cls {
    NSString *jsonStr = [self jsonStringForKey:key];
    if ( jsonStr.length == 0 )
        return nil;
#if __has_include(<YYModel/YYModel.h>)
    return [cls yy_modelWithJSON:jsonStr];
#elif __has_include(<YYKit/YYKit.h>)
    return [cls modelWithJSON:jsonStr];
#else
    NSAssert(NO, @"请导入YYModel或者YYKit");
#endif
}

- (nullable NSString *)jsonStringForKey:(NSString *)key {
    return [self _itemValueForKey:key];
}

- (nullable NSDictionary *)dictionaryForKey:(NSString *)key {
    return [self _containerValueForKey:key];
}

- (NSInteger)integerForKey:(NSString *)key {
    return [[self _itemValueForKey:key] integerValue];
}

- (float)floatForKey:(NSString *)key {
    return [[self _itemValueForKey:key] floatValue];
}

- (double)doubleForKey:(NSString *)key {
    return [[self _itemValueForKey:key] doubleValue];
}

- (BOOL)boolForKey:(NSString *)key {
    return [[self _itemValueForKey:key] boolValue];
}

- (nullable NSURL *)URLForKey:(NSString *)key {
    return [NSURL URLWithString:[self _itemValueForKey:key]];
}

- (nullable id)_containerValueForKey:(NSString *)key {
    NSString * _Nullable value = [self _itemValueForKey:key];
    if ( value == nil ) return nil;
    return [NSJSONSerialization JSONObjectWithData:[value dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
}

- (nullable NSString *)_itemValueForKey:(NSString *)key {
    return [(SJSQLite3BasicTypeItem *)[self objectForClass:SJSQLite3BasicTypeItem.class primaryKeyValue:key error:NULL] value];
}
@end

NSArray<id> *
SJFoundationExtendedValuesForKey(NSString *key, NSArray<NSDictionary *> *array) {
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:array.count];
    for ( NSDictionary *dict in array ) {
        id value = dict[key];
        if ( value ) [values addObject:value];
    }
    return values.count != 0 ? values : nil;
}
NS_ASSUME_NONNULL_END
