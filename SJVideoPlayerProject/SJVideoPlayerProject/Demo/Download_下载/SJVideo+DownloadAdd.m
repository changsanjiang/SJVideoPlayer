//
//  SJVideo+DownloadAdd.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/17.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideo+DownloadAdd.h"
#import <objc/message.h>

@implementation SJVideo (DownloadAdd)
- (void)setEntity:(id<SJMediaEntity>)entity {
    objc_setAssociatedObject(self, @selector(entity), entity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<SJMediaEntity>)entity {
    return objc_getAssociatedObject(self, _cmd);
}
@end
