//
//  SJAttributesFactory.h
//  SJAttributesFactory
//
//  Created by 畅三江 on 2017/11/6.
//  Copyright © 2017年 畅三江. All rights reserved.
//
//
//  关于属性介绍请移步 => http://www.jianshu.com/p/ebbcfc24f9cb

#import <UIKit/UIKit.h>

@class SJAttributeWorker;

NS_ASSUME_NONNULL_BEGIN

@interface SJAttributesFactory : NSObject

/*!
 *  NSAttributedString *attr = [SJAttributesFactory alteringStr:@"我的故乡" task:^(SJAttributeWorker * _Nonnull worker) {
 *      NSShadow *shadow = [NSShadow new];
 *      shadow.shadowColor = [UIColor greenColor];
 *      shadow.shadowOffset = CGSizeMake(1, 1);
 *      worker.font([UIFont boldSystemFontOfSize:40]).shadow(shadow);
 *  }];
 **/
+ (NSAttributedString *)alteringStr:(NSString *)str task:(void(^)(SJAttributeWorker *worker))task;

+ (NSAttributedString *)alteringAttrStr:(NSAttributedString *)attrStr task:(void(^)(SJAttributeWorker *worker))task;

+ (NSAttributedString *)producingWithImage:(UIImage *)image size:(CGSize)size task:(void(^)(SJAttributeWorker *worker))task;

+ (NSAttributedString *)producingWithTask:(void(^)(SJAttributeWorker *worker))task;

@end

NS_ASSUME_NONNULL_END
