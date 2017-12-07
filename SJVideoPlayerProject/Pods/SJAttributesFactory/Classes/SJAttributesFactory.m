//
//  SJAttributesFactory.m
//  SJAttributesFactory
//
//  Created by 畅三江 on 2017/11/6.
//  Copyright © 2017年 畅三江. All rights reserved.
//

#import "SJAttributesFactory.h"
#import "SJAttributeWorker.h"

/*
 *  1. 派发任务
 *  2. 工厂接收
 *  3. 工厂根据任务, 分配工人完成任务
 */

@interface SJAttributesFactory ()

@end

@implementation SJAttributesFactory

+ (NSAttributedString *)alteringStr:(NSString *)str task:(void(^)(SJAttributeWorker *worker))task {
    if ( !str ) return nil;
    SJAttributeWorker *worker = [SJAttributeWorker new];
    worker.insert(str, 0);
    task(worker);
    return [worker endTask];
}

+ (NSAttributedString *)alteringAttrStr:(NSAttributedString *)attrStr task:(void(^)(SJAttributeWorker *worker))task {
    if ( !attrStr ) return nil;
    SJAttributeWorker *worker = [SJAttributeWorker new];
    worker.insert(attrStr, 0);
    task(worker);
    return [worker endTask];
}

+ (NSAttributedString *)producingWithImage:(UIImage *)image size:(CGSize)size task:(void(^)(SJAttributeWorker *worker))task {
    if ( !image ) return nil;
    SJAttributeWorker *worker = [SJAttributeWorker new];
    worker.insert(image, 0, CGPointZero, size);
    task(worker);
    return [worker endTask];
}

+ (NSAttributedString *)producingWithTask:(void(^)(SJAttributeWorker *worker))task {
    return [self alteringStr:@"" task:task];
}

@end

