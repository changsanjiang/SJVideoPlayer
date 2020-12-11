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

typedef enum : NSUInteger {
    SJSafeAreaInsetsMaskNone = 0,
    SJSafeAreaInsetsMaskTop = 1 << 0,
    SJSafeAreaInsetsMaskLeft = 1 << 1,
    SJSafeAreaInsetsMaskBottom = 1 << 2,
    SJSafeAreaInsetsMaskRight = 1 << 3,
    
    SJSafeAreaInsetsMaskHorizontal = SJSafeAreaInsetsMaskLeft | SJSafeAreaInsetsMaskRight,
    SJSafeAreaInsetsMaskVertical = SJSafeAreaInsetsMaskTop | SJSafeAreaInsetsMaskRight,
    SJSafeAreaInsetsMaskAll = SJSafeAreaInsetsMaskHorizontal | SJSafeAreaInsetsMaskVertical
} SJSafeAreaInsetsMask NS_AVAILABLE_IOS(13.0);


API_AVAILABLE(ios(13.0)) @interface UIViewController (SJRotationPrivate_FixSafeArea)

/// 禁止调整哪些方向的安全区
@property (nonatomic) SJSafeAreaInsetsMask disabledAdjustSafeAreaInsetsMask;

@end

NS_ASSUME_NONNULL_END

#endif
