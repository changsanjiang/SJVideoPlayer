//
//  UIImagePickerController+Extension.m
//  dancebaby
//
//  Created by BlueDancer on 2017/7/31.
//  Copyright © 2017年 hunter. All rights reserved.
//

#import "UIImagePickerController+SJUIKitExtension.h"
#import <objc/message.h>

@implementation UIImagePickerController (SJUIKitExtension)

- (void)setSj_didFinishPickingImageHandler:(void (^)(UIImage *))sj_didFinishPickingImageHandler {
    objc_setAssociatedObject(self, @selector(sj_didFinishPickingImageHandler), sj_didFinishPickingImageHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIImage *))sj_didFinishPickingImageHandler {
    return objc_getAssociatedObject(self, _cmd);
}

@end
