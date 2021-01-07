//
//  SJImagePickerController.m
//  Pods
//
//  Created by 畅三江 on 2019/7/3.
//

#import "SJImagePickerController.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJImagePickerController ()

@end

@implementation SJImagePickerController
+ (void)alertPickerViewControllerWithTitle:(nullable NSString *)title
                                        message:(nullable NSString *)msg
                       presentingViewController:(UIViewController *)controller
                                       callback:(SJUIKitDidFinishPickingImageHandler)callback {
    [self alertPickerViewControllerWithTitle:title message:msg presentingViewController:controller additionalActions:nil callback:callback];
}

+ (void)alertPickerViewControllerWithTitle:(nullable NSString *)title
                                   message:(nullable NSString *)message
                  presentingViewController:(UIViewController *)presentingViewController
                         additionalActions:(nullable NSArray<UIAlertAction *> *)additionalActions
                                  callback:(SJUIKitDidFinishPickingImageHandler)completionHandler {
    NSMutableArray<UIAlertAction *> *actions = NSMutableArray.array;
    if ( additionalActions.count != 0 ) {
        [actions addObjectsFromArray:additionalActions];
    }
    
    // 拍照
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
        [actions addObject:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ( !granted ) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"拍摄照片需要您开启相机权限! 您可以通过设置-隐私-蓝舞者中开启相机权限。" preferredStyle:UIAlertControllerStyleAlert];
                        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                        [alertController addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            NSURL *openUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            [[UIApplication sharedApplication] openURL:openUrl];
                        }]];
                        [presentingViewController presentViewController:alertController animated:YES completion:nil];
                        return;
                    }
                    
                    UIImagePickerController *pickerController = [UIImagePickerController new];
                    pickerController.edgesForExtendedLayout = UIRectEdgeNone;
                    pickerController.delegate = (id)self;
                    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    pickerController.sj_didFinishPickingImageHandler = completionHandler;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [presentingViewController presentViewController:pickerController animated:YES completion:nil];
                    });
                });
            }];
        }]];
    }
    
    // 相册
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
        [actions addObject:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *pickerController = [UIImagePickerController new];
            pickerController.edgesForExtendedLayout = UIRectEdgeNone;
            pickerController.automaticallyAdjustsScrollViewInsets = YES;
            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerController.delegate = (id)self;
            pickerController.sj_didFinishPickingImageHandler = completionHandler;
            dispatch_async(dispatch_get_main_queue(), ^{
                [presentingViewController presentViewController:pickerController animated:YES completion:nil];
            });
        }]];
    }
    
    if ( 0 == actions.count ) return;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    // actions
    for ( UIAlertAction *a in actions ) {
        [alertController addAction:a];
    }
    
    // cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //if iPhone
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            [presentingViewController presentViewController:alertController animated:YES completion:nil];
        }
        //if iPad
        else {
            // Change Rect to position Popover
            UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
            popPresenter.sourceView = [UIApplication sharedApplication].keyWindow;
            popPresenter.sourceRect = CGRectMake(0, [UIApplication sharedApplication].keyWindow.bounds.size.height, [UIApplication sharedApplication].keyWindow.bounds.size.width, 0);
            popPresenter.permittedArrowDirections = UIPopoverArrowDirectionDown;
            [presentingViewController presentViewController:alertController animated:YES completion:nil];
        }
    });
}

+ (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *imageOriginal = [info objectForKey:UIImagePickerControllerOriginalImage];
        if ( picker.sj_didFinishPickingImageHandler ) picker.sj_didFinishPickingImageHandler(imageOriginal);
    }];
}

+ (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
NS_ASSUME_NONNULL_END
