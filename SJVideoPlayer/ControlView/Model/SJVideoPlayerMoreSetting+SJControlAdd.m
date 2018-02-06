//
//  SJVideoPlayerMoreSetting+SJControlAdd.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/5.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSetting+SJControlAdd.h"
#import <objc/message.h>

@implementation SJVideoPlayerMoreSetting (SJControlAdd)
- (void)set_exeBlock:(void (^)(SJVideoPlayerMoreSetting * _Nonnull))_exeBlock {
    objc_setAssociatedObject(self, @selector(_exeBlock), _exeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(SJVideoPlayerMoreSetting * _Nonnull))_exeBlock {
    return objc_getAssociatedObject(self, _cmd);
}
@end
