//
//  SJSQLite3+FoundationExtended.h
//  SJUIKit
//
//  Created by 畅三江 on 2019/10/21.
//

#import "SJSQLite3.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJSQLite3 (FoundationExtended)
- (BOOL)save:(id)value forKey:(NSString *)key error:(NSError **)error;
- (void)removeValueForKey:(NSString *)key error:(NSError **)error;

- (nullable NSString *)jsonStringForKey:(NSString *)key;

// - container -
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
