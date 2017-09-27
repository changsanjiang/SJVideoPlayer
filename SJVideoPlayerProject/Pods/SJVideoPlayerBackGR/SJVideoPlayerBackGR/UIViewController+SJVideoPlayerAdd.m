//
//  UIViewController+SJVideoPlayerAdd.m
//  SJBackGR
//
//  Created by BlueDancer on 2017/9/27.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "UIViewController+SJVideoPlayerAdd.h"
#import <objc/message.h>

@implementation UIViewController (SJVideoPlayerAdd)

- (void)setSj_viewWillBeginDragging:(void (^)(UIViewController *))sj_viewWillBeginDragging {
    objc_setAssociatedObject(self, @selector(sj_viewWillBeginDragging), sj_viewWillBeginDragging, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UIViewController *))sj_viewWillBeginDragging {
    return objc_getAssociatedObject(self, _cmd);
}


- (void)setSj_viewDidDrag:(void (^)(UIViewController *))sj_viewDidDrag {
    objc_setAssociatedObject(self, @selector(sj_viewDidDrag), sj_viewDidDrag, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UIViewController *))sj_viewDidDrag {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSj_viewDidEndDragging:(void (^)(UIViewController *))sj_viewDidEndDragging {
    objc_setAssociatedObject(self, @selector(sj_viewDidEndDragging), sj_viewDidEndDragging, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UIViewController *))sj_viewDidEndDragging {
    return objc_getAssociatedObject(self, _cmd);
}

@end
