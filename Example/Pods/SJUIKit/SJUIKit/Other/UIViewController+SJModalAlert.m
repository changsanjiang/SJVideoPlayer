//
//  UIViewController+SJModalAlert.m
//  SJUIKit_Example
//
//  Created by 畅三江 on 2018/12/16.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "UIViewController+SJModalAlert.h"

NS_ASSUME_NONNULL_BEGIN
@implementation UIViewController (SJModalAlert)
- (void)sj_modalTextAlert:(NSString *)title
                   accept:(NSString *)accept
                   cancel:(NSString *)cancel
              placeHolder:(NSString *)placeHolder
                 callback:(void(^)(NSString *_Nullable inputStr))callback {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeHolder;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if ( callback ) callback(nil);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:accept style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       if ( callback ) callback(alert.textFields.firstObject.text);
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
@end
NS_ASSUME_NONNULL_END
