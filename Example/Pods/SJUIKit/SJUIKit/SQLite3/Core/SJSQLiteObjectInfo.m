//
//  SJSQLiteObjectInfo.m
//  Pods
//
//  Created by 畅三江 on 2019/7/30.
//

#import "SJSQLiteObjectInfo.h"
#import "SJSQLiteTableModelConstraints.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJSQLiteColumnInfo (SJSQLiteObjectInfoExtended)
- (void)setAssociatedObjectInfos:(NSArray<SJSQLiteObjectInfo *> * _Nullable)associatedObjectInfos {
    objc_setAssociatedObject(self, @selector(associatedObjectInfos), associatedObjectInfos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable NSArray<SJSQLiteObjectInfo *> *)associatedObjectInfos {
    return objc_getAssociatedObject(self, _cmd);
}
@end

@implementation SJSQLiteObjectInfo
+ (nullable instancetype)objectInfoWithObject:(id)obj {
    SJSQLiteTableInfo *_Nullable table = [SJSQLiteTableInfo tableInfoWithClass:[obj class]];
    if ( table == nil )
        return nil;
    
    NSMutableArray<SJSQLiteColumnInfo *> *autoincrementColumns = NSMutableArray.new;
    SJSQLiteColumnInfo *primaryKeyColumnInfo = nil;
    for ( SJSQLiteColumnInfo *column in table.columns ) {
        if ( column.isPrimaryKey )
            primaryKeyColumnInfo = column;
        
        if ( column.isAutoincrement )
            [autoincrementColumns addObject:column];
        
        if ( column.associatedTableInfo != nil ) {
            id _Nullable value = [obj valueForKey:column.name];
            if ( value != nil ) {
                if ( column.isModelArray ) {
                    NSMutableArray<SJSQLiteObjectInfo *> *infos = [[NSMutableArray alloc] initWithCapacity:[value count]];
                    [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        SJSQLiteObjectInfo *_Nullable info = [SJSQLiteObjectInfo objectInfoWithObject:obj];
                        if ( info != nil ) {
                            [infos addObject:info];
                        }
                    }];
                    
                    if ( infos.count != 0 ) {
                        column.associatedObjectInfos = infos.copy;
                    }
                }
                else {
                    SJSQLiteObjectInfo *_Nullable info = [SJSQLiteObjectInfo objectInfoWithObject:value];
                    if ( info != nil ) {
                        column.associatedObjectInfos = @[info];
                    }
                }
            }
        }
    }
    
    SJSQLiteObjectInfo *info = [SJSQLiteObjectInfo new];
    info->_obj = obj;
    info->_table = table;
    info->_primaryKeyColumnInfo = primaryKeyColumnInfo;
    if ( autoincrementColumns.count != 0 ) info->_autoincrementColumns = autoincrementColumns;
    return info;
}
@end
NS_ASSUME_NONNULL_END
