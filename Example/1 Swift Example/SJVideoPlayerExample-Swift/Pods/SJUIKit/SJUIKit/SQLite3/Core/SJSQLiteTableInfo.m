//
//  SJSQLiteTableInfo.m
//  Pods-SJSQLite3_Example
//
//  Created by 畅三江 on 2019/7/26.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLiteTableInfo.h"
#import "SJSQLiteTableModelConstraints.h"
#import "SJSQLiteColumnInfo.h"
#import "SJSQLiteCore.h"
#import <objc/message.h>

#if __has_include(<YYModel/YYModel.h>)
#import <YYModel/YYClassInfo.h>
#elif __has_include(<YYKit/YYKit.h>)
#import <YYKit/YYClassInfo.h>
#endif

NS_ASSUME_NONNULL_BEGIN
typedef NSString *SJSQLITEColumnType;
static SJSQLITEColumnType const SJSQLITEColumnType_INTEGER = @"INTEGER";
static SJSQLITEColumnType const SJSQLITEColumnType_FLOAT = @"FLOAT";
static SJSQLITEColumnType const SJSQLITEColumnType_BLOB = @"BLOB";
static SJSQLITEColumnType const SJSQLITEColumnType_TEXT = @"TEXT";

@implementation SJSQLiteColumnInfo (SJSQLiteTableInfoExtended)
- (void)setAssociatedTableInfo:(nullable SJSQLiteTableInfo *)associatedTableInfo {
    objc_setAssociatedObject(self, @selector(associatedTableInfo), associatedTableInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable SJSQLiteTableInfo *)associatedTableInfo {
    return objc_getAssociatedObject(self, _cmd);
}
@end

@implementation SJSQLiteTableInfo
+ (nullable instancetype)tableInfoWithClass:(Class<SJSQLiteTableModelProtocol>)cls {
#if __has_include(<YYModel/YYModel.h>) || __has_include(<YYKit/YYKit.h>)
    SJSQLiteTableModelConstraints *cons = [[SJSQLiteTableModelConstraints alloc] initWithClass:cls];
    if ( cons.sql_primaryKey.length < 1 )
        return nil;
    
    YYClassInfo *_Nullable classInfo = [YYClassInfo classInfoWithClass:cls];
    if ( classInfo == nil || classInfo.superCls == nil )
        return nil;
    NSString *tablename = cons.sql_tableName ? : sj_sqlite3_obj_get_default_table_name(cls);
    NSMutableDictionary<SJSQLiteColumnInfo *, SJSQLiteTableInfo *> *associatedTableInfos = NSMutableDictionary.new;
    NSMutableArray<SJSQLiteColumnInfo *> *columns = NSMutableArray.new;
    NSMutableSet<Class> *allClasses = NSMutableSet.new;
    YYClassInfo *cur = classInfo;
    while ( cur.superCls != nil && cur.cls != NSObject.class ) {
        for ( YYClassPropertyInfo *property in cur.propertyInfos.allValues ) {
            if ( property.name.length < 1 )
                continue;
            if ( !class_respondsToSelector(cls, property.setter) )
                continue;
            if ( [cons.objc_sysProperties containsObject:property.name] )
                continue;
            if ( cons.sql_blacklist != nil && [cons.sql_blacklist containsObject:property.name] )
                continue;
            if ( cons.sql_whitelist != nil && ![cons.sql_whitelist containsObject:property.name] )
                continue;
            
            // Unavailable
            switch ( property.type & YYEncodingTypeMask ) {
                case YYEncodingTypeUnknown:
                case YYEncodingTypeVoid:
                case YYEncodingTypeClass:
                case YYEncodingTypeSEL:
                case YYEncodingTypeBlock:
                case YYEncodingTypePointer:
                case YYEncodingTypeStruct:
                case YYEncodingTypeUnion:
                case YYEncodingTypeCString:
                case YYEncodingTypeCArray:
                    continue;
                default:
                    break;
            }
            
            // Column
            SJSQLiteColumnInfo *columnInfo = SJSQLiteColumnInfo.alloc.init;
            columnInfo.property = property.name;
            columnInfo.name = cons.sql_customKeyMapper[property.name] ?: property.name;
            switch ( property.type & YYEncodingTypeMask ) {
                case YYEncodingTypeBool: {
                    columnInfo.type = SJSQLITEColumnType_BLOB;
                }
                    break;
                case YYEncodingTypeInt8:
                case YYEncodingTypeUInt8:
                case YYEncodingTypeInt16:
                case YYEncodingTypeUInt16:
                case YYEncodingTypeInt32:
                case YYEncodingTypeUInt32:
                case YYEncodingTypeInt64:
                case YYEncodingTypeUInt64: {
                    columnInfo.type = SJSQLITEColumnType_INTEGER;
                }
                    break;
                case YYEncodingTypeFloat:
                case YYEncodingTypeDouble:
                case YYEncodingTypeLongDouble: {
                    columnInfo.type = SJSQLITEColumnType_FLOAT;
                }
                    break;
                case YYEncodingTypeObject: {
                    if      ( [property.cls isSubclassOfClass:NSArray.class] ) {
                        [cons.sql_arrayPropertyGenericClass enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class<SJSQLiteTableModelProtocol>  _Nonnull genericClass, BOOL * _Nonnull stop) {
                            if ( [key isEqualToString:property.name] ) {
                                *stop = YES;
                                
                                SJSQLiteTableInfo *_Nullable associatedTableInfo = [SJSQLiteTableInfo tableInfoWithClass:genericClass];
                                if ( associatedTableInfo != nil ) {
                                    [allClasses addObject:associatedTableInfo.cls];
                                    [allClasses unionSet:associatedTableInfo.allClasses];
                                    associatedTableInfos[columnInfo] = associatedTableInfo;
                                    columnInfo.isModelArray = YES;
                                    columnInfo.type = SJSQLITEColumnType_TEXT;
                                    columnInfo.associatedTableInfo = associatedTableInfo;
                                }
                            }
                        }];
                    }
                    else if ( [property.cls isSubclassOfClass:NSString.class] ) {
                        columnInfo.type = SJSQLITEColumnType_TEXT;
                    }
                    else {
                        // Object
                        SJSQLiteTableInfo *_Nullable associatedTableInfo = nil;
                        for ( SJSQLiteColumnInfo *columnInfo in columns ) {
                            if ( [columnInfo.associatedTableInfo.cls isSubclassOfClass:property.cls] ) {
                                associatedTableInfo = columnInfo.associatedTableInfo;
                                break;
                            }
                        }
                        
                        if ( associatedTableInfo == nil ) {
                            associatedTableInfo = [SJSQLiteTableInfo tableInfoWithClass:property.cls];
                        }
                        
                        if ( associatedTableInfo != nil ) {
                            [allClasses addObject:associatedTableInfo.cls];
                            [allClasses unionSet:associatedTableInfo.allClasses];
                            associatedTableInfos[columnInfo] = associatedTableInfo;
                            columnInfo.type = SJSQLITEColumnType_INTEGER;
                            columnInfo.associatedTableInfo = associatedTableInfo;
                        }
                    }
                }
                    break;
                default: break;
            }
            
            if ( columnInfo.type == nil )
                continue;
            
            // Constraints
            NSMutableString *constraints = NSMutableString.new;
            if ( [columnInfo.name isEqualToString:cons.sql_primaryKey] ) {
                [constraints appendString:@" PRIMARY KEY"];
                columnInfo.isPrimaryKey = YES;
            }
            
            for ( NSString *key in cons.sql_autoincrementlist ) {
                if ( [columnInfo.name isEqualToString:key] ) {
                    [constraints appendFormat:@" AUTOINCREMENT"];
                    columnInfo.isAutoincrement = YES;
                }
            }
            
            for ( NSString *key in cons.sql_notnulllist ) {
                if ( [columnInfo.name isEqualToString:key] ) {
                    [constraints appendString:@" NOT NULL"];
                    break;
                }
            }
            
            for ( NSString *key in cons.sql_uniquelist ) {
                if ( [columnInfo.name isEqualToString:key] ) {
                    [constraints appendString:@" UNIQUE"];
                    break;
                }
            }
            
            if ( columnInfo.associatedTableInfo != nil && ![property.cls isSubclassOfClass:NSArray.class]) {
                SJSQLiteTableInfo *tableInfo = columnInfo.associatedTableInfo;
                [constraints appendFormat:@" REFERENCES '%@' ('%@')", tableInfo.name, tableInfo.primaryKey];
            }
            
            if ( constraints.length > 0 ) {
                columnInfo.constraints = constraints.copy;
            }
            
            [columns addObject:columnInfo];
        }
        
        cur = cur.superClassInfo;
    }
    
    if ( columns.count < 1 )
        return nil;
    
    [allClasses addObject:cls];
    
    SJSQLiteTableInfo *info = SJSQLiteTableInfo.alloc.init;
    info->_cls = cls;
    info->_columns = columns.copy;
    info->_name = tablename;
    info->_primaryKey = cons.sql_primaryKey;
    info->_allClasses = allClasses.copy;
    if ( associatedTableInfos.count > 0 ) info->_columnAssociatedTableInfos = associatedTableInfos.copy;
    return info;

#else
    return nil;
#endif
}

- (NSString *)description {
    return [NSString stringWithFormat:@"SJSQLiteTable:<%p> { %@ }", self, self.columns];
}

- (nullable SJSQLiteColumnInfo *)columnInfoForProperty:(NSString *)key {
    for ( SJSQLiteColumnInfo *column in self.columns ) {
        if ( [column.property isEqualToString:key] ) {
            return column;
        }
    }
    return nil;
}

- (nullable SJSQLiteColumnInfo *)columnInfoForColumnName:(NSString *)key {
    for ( SJSQLiteColumnInfo *column in self.columns ) {
        if ( [column.name isEqualToString:key] ) {
            return column;
        }
    }
    return nil;
}
@end
NS_ASSUME_NONNULL_END
