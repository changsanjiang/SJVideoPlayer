//
//  SJVideoPlayerURLAsset+SJControlAdd.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/2/4.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import <objc/message.h>

@implementation SJVideoPlayerURLAsset (SJControlAdd)

- (void)setTitle:(NSString *)title {
    objc_setAssociatedObject(self, @selector(title), title, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)title {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAlwaysShowTitle:(BOOL)alwaysShowTitle {
    objc_setAssociatedObject(self, @selector(alwaysShowTitle), @(alwaysShowTitle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)alwaysShowTitle {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
