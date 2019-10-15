//
//  UIImagePickerController+Extension.h
//  dancebaby
//
//  Created by BlueDancer on 2017/7/31.
//  Copyright © 2017年 hunter. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SJUIKitDidFinishPickingImageHandler)(UIImage *selectedImage);

@interface UIImagePickerController (SJUIKitExtension)

@property (nonatomic, copy) SJUIKitDidFinishPickingImageHandler sj_didFinishPickingImageHandler;

@end
