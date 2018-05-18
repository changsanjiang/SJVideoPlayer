//
//  UIImagePickerController+Extension.h
//  dancebaby
//
//  Created by BlueDancer on 2017/7/31.
//  Copyright © 2017年 hunter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImagePickerController (Extension)

@property (nonatomic, copy) void(^didFinishPickingImageCallBlock)(UIImage *selectedImage);

@end
