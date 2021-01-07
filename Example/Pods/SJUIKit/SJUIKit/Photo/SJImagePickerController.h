//
//  SJImagePickerController.h
//  Pods
//
//  Created by 畅三江 on 2019/7/3.
//

#import <Foundation/Foundation.h>
#import "UIImagePickerController+SJUIKitExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJImagePickerController : NSObject
/// none
+ (void)alertPickerViewControllerWithTitle:(nullable NSString *)title
                                        message:(nullable NSString *)message
                       presentingViewController:(UIViewController *)presentingViewController
                                       callback:(SJUIKitDidFinishPickingImageHandler)callback;

/// actions
+ (void)alertPickerViewControllerWithTitle:(nullable NSString *)title
                                   message:(nullable NSString *)message
                  presentingViewController:(UIViewController *)presentingViewController
                         additionalActions:(nullable NSArray<UIAlertAction *> *)additionalActions
                                  callback:(SJUIKitDidFinishPickingImageHandler)callback;
@end

NS_ASSUME_NONNULL_END
