//
//  NSObject+SJ.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/7/14.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "NSObject+SJ.h"
#import <objc/runtime.h>

@implementation NSObject (SJ)

+ (NSArray<NSString *> *)csj_propertyList {
    NSMutableArray <NSString *> *namesArrM = [NSMutableArray array];
    unsigned int outCount = 0;
    objc_property_t *propertyList = class_copyPropertyList(self, &outCount);
    if (propertyList != NULL && outCount > 0) {
        for (int i = 0; i < outCount; i ++) {
            objc_property_t property = propertyList[i];
            const char *name  = property_getName(property);
            NSString *nameStr = [NSString stringWithUTF8String:name];
            [namesArrM addObject:nameStr];
        }
    }
    free(propertyList);
    return namesArrM.copy;
}
+ (NSArray<NSString *> *)csj_methodList; {
    NSMutableArray *methodNamesArrM = [NSMutableArray array];
    unsigned int outCount = 0;
    Method *methodList = class_copyMethodList(self, &outCount);
    if (methodList != NULL && outCount > 0) {
        for (int i = 0; i < outCount; i ++) {
            SEL sel = method_getName(methodList[i]);
            NSString *methodName = NSStringFromSelector(sel);
            [methodNamesArrM addObject:methodName];
        }
    }
    free(methodList);
    return methodNamesArrM.copy;
}
+ (NSArray<NSString *> *)csj_protocolList {
    NSMutableArray *protocolNamesArrM = [NSMutableArray array];
    unsigned int outCount = 0;
    Protocol * __unsafe_unretained *protocolList = class_copyProtocolList(self, &outCount);
    if (protocolList != NULL && outCount > 0) {
        for (int i = 0; i < outCount; i ++) {
            NSString *protocolName = NSStringFromProtocol(protocolList[i]);
            [protocolNamesArrM addObject:protocolName];
        }
    }
    free(protocolList);
    return protocolNamesArrM.copy;
}
+ (NSArray<NSString *> *)csj_invarList {
    NSMutableArray *invarListArrM = [NSMutableArray array];
    unsigned int outCount = 0;
    Ivar *ivarList = class_copyIvarList(self, &outCount);
    if (ivarList != NULL && outCount > 0) {
        for (int i = 0; i < outCount; i ++) {
            const char *name = ivar_getName(ivarList[i]);
            NSString *nameStr = [NSString stringWithUTF8String:name];
            [invarListArrM addObject:nameStr];
        }
    }
    free(ivarList);
    return invarListArrM.copy;
}
+ (NSArray<NSString *> *)csj_invarTypeList {
    
    unsigned int ivarCount = 0;
    
    struct objc_ivar **ivarList = class_copyIvarList(self, &ivarCount);
    
    NSMutableArray<NSString *> *listM = [NSMutableArray new];
    
    // 遍历获取类的属性类型
    for ( int i = 0 ; i < ivarCount ; i ++ ) {
        const char *cType = ivar_getTypeEncoding(ivarList[i]);
        [listM addObject:[NSString stringWithUTF8String:cType]];
    }
    free(ivarList);
    return listM;
}
@end
