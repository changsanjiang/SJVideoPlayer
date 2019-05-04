//
//  UIViewController+SJModalAlert.h
//  SJUIKit_Example
//
//  Created by 畅三江 on 2018/12/16.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIViewController (SJModalAlert)
- (void)sj_modalTextAlert:(NSString *)title
                   accept:(NSString *)accept
                   cancel:(NSString *)cancel
              placeHolder:(NSString *)placeHolder
                 callback:(void(^)(NSString *_Nullable inputStr))callback;
@end
NS_ASSUME_NONNULL_END
