//
//  UIViewController+SJRotationPrivate_FixSafeArea.h
//  Pods
//
//  Created by 畅三江 on 2019/8/6.
//
//  适配 iOS 13.0
//

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(13.0)) @interface UIViewController (SJRotationPrivate_FixSafeArea)

@end

NS_ASSUME_NONNULL_END

#endif
