//
//  SJImagePickerController.m
//  Pods
//
//  Created by BlueDancer on 2019/7/3.
//

#import "SJImagePickerController.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJImagePickerController ()

@end

@implementation SJImagePickerController
+ (void)alertPickerViewControllerWithTitle:(nullable NSString *)title
                                        message:(nullable NSString *)msg
                       presentingViewController:(UIViewController *)controller
                                       callback:(SJUIKitDidFinishPickingImageHandler)callback {
    NSMutableArray<NSString *> *titlesM = [NSMutableArray new];
    NSMutableArray<void(^)(void)> *actionsM = [NSMutableArray new];
    
    // 拍照
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
        [titlesM addObject:@"拍照"];
        [actionsM addObject:^{
            UIImagePickerController *pickerController = [UIImagePickerController new];
            pickerController.edgesForExtendedLayout = UIRectEdgeNone;
            pickerController.delegate = (id)self;
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerController.sj_didFinishPickingImageHandler = callback;
            dispatch_async(dispatch_get_main_queue(), ^{
                [controller presentViewController:pickerController animated:YES completion:nil];
            });
        }];
    }
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
        // 相册
        [titlesM addObject:@"相册"];
        [actionsM addObject:^ {
            UIImagePickerController *pickerController = [UIImagePickerController new];
            pickerController.edgesForExtendedLayout = UIRectEdgeNone;
            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerController.delegate = (id)self;
            pickerController.sj_didFinishPickingImageHandler = callback;
            dispatch_async(dispatch_get_main_queue(), ^{
                [controller presentViewController:pickerController animated:YES completion:nil];
            });
        }];
    }
    
    
    if ( 0 == titlesM.count ) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"无法访问相册, 请确认是否授权!" preferredStyle:UIAlertControllerStyleAlert];
        [controller presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleActionSheet];
    
    // actions
    [titlesM enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            actionsM[idx]();
        }];
        [alertController addAction:action];
    }];
    
    // cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //if iPhone
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            [controller presentViewController:alertController animated:YES completion:nil];
        }
        //if iPad
        else {
            // Change Rect to position Popover
            UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
            popPresenter.sourceView = [UIApplication sharedApplication].keyWindow;
            popPresenter.sourceRect = CGRectMake(0, [UIApplication sharedApplication].keyWindow.bounds.size.height, [UIApplication sharedApplication].keyWindow.bounds.size.width, 0);
            popPresenter.permittedArrowDirections = UIPopoverArrowDirectionDown;
            [controller presentViewController:alertController animated:YES completion:nil];
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
