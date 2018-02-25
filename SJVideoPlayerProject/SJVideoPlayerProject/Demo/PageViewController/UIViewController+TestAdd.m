//
//  UIViewController+TestAdd.m
//  SJBackGRProject
//
//  Created by BlueDancer on 2018/2/3.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "UIViewController+TestAdd.h"
#import <objc/message.h>

@implementation UIViewController (TestAdd)

- (void)setIndex:(NSInteger)index {
    objc_setAssociatedObject(self, @selector(index), @(index), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)index {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}
@end
