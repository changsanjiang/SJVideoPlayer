//
//  SJImagePickerController.h
//  Pods
//
//  Created by BlueDancer on 2019/7/3.
//

#import <Foundation/Foundation.h>
#import "UIImagePickerController+SJUIKitExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJImagePickerController : NSObject
+ (void)alertPickerViewControllerWithTitle:(nullable NSString *)title
                                        message:(nullable NSString *)message
                       presentingViewController:(UIViewController *)presentingViewController
                                       callback:(SJUIKitDidFinishPickingImageHandler)callback;
@end

NS_ASSUME_NONNULL_END
