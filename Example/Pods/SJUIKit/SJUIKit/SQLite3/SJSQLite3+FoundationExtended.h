//
//  SJSQLite3+FoundationExtended.h
//  SJUIKit
//
//  Created by 畅三江 on 2019/10/21.
//

#import "SJSQLite3.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJSQLite3 (FoundationExtended)
- (BOOL)save:(nullable id)value forKey:(NSString *)key error:(NSError **)error;
- (BOOL)setValue:(nullable id)value forKey:(NSString *)key error:(NSError **)error;
- (BOOL)setDictionary:(nullable NSDictionary *)value forKey:(NSString *)key error:(NSError **)error;
- (BOOL)setArray:(nullable NSArray *)value forKey:(NSString *)key error:(NSError **)error;
- (BOOL)setString:(nullable NSString *)value forKey:(NSString *)key error:(NSError **)error;
- (BOOL)setURL:(nullable NSURL *)value forKey:(NSString *)key error:(NSError **)error;
- (BOOL)setInteger:(NSInteger)value forKey:(NSString *)key error:(NSError **)error;
- (BOOL)setDouble:(double)value forKey:(NSString *)key error:(NSError **)error;
- (BOOL)setFloat:(float)value forKey:(NSString *)key error:(NSError **)error;
- (BOOL)setBool:(BOOL)value forKey:(NSString *)key error:(NSError **)error;

- (BOOL)removeValueForKey:(NSString *)key error:(NSError **)error;

// - container -
- (nullable id)objectForKey:(NSString *)key objectClass:(Class)cls;
- (nullable NSString *)jsonStringForKey:(NSString *)key;
- (nullable NSDictionary *)dictionaryForKey:(NSString *)key;
- (nullable NSArray *)arrayForKey:(NSString *)key;

// -
- (nullable NSString *)stringForKey:(NSString *)key;
- (nullable NSURL *)URLForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
@end

extern NSArray<id> *
SJFoundationExtendedValuesForKey(NSString *key, NSArray<NSDictionary *> *array);
NS_ASSUME_NONNULL_END
