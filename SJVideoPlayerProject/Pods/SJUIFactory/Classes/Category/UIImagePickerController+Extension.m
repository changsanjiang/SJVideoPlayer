//
//  UIImagePickerController+Extension.m
//  dancebaby
//
//  Created by BlueDancer on 2017/7/31.
//  Copyright © 2017年 hunter. All rights reserved.
//

#import "UIImagePickerController+Extension.h"
#import <objc/message.h>

@implementation UIImagePickerController (Extension)

- (void)setDidFinishPickingImageCallBlock:(void (^)(UIImage *))didFinishPickingImageCallBlock {
    objc_setAssociatedObject(self, @selector(didFinishPickingImageCallBlock), didFinishPickingImageCallBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIImage *))didFinishPickingImageCallBlock {
    return objc_getAssociatedObject(self, _cmd);
}

@end
