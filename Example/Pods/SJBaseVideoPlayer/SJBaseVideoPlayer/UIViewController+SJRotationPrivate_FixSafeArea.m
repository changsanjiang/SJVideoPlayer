//
//  UIViewController+SJRotationPrivate_FixSafeArea.m
//  Pods
//
//  Created by 畅三江 on 2019/8/6.
//

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000

#import "UIViewController+SJRotationPrivate_FixSafeArea.h"
#import "SJBaseVideoPlayer.h"
#import "SJBaseVideoPlayerConst.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
API_AVAILABLE(ios(13.0)) @protocol _UIViewControllerPrivateMethodsProtocol <NSObject>
- (void)_setContentOverlayInsets:(UIEdgeInsets)insets andLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;
@end

API_AVAILABLE(ios(13.0)) @implementation UIViewController (SJRotationPrivate_FixSafeArea)
- (BOOL)sj_containsPlayerView {
    return [self.view viewWithTag:SJBaseVideoPlayerPresentViewTag] != nil ||
           [self.view viewWithTag:SJBaseVideoPlayerViewTag] != nil;
}

- (void)sj_setContentOverlayInsets:(UIEdgeInsets)insets andLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
    SJSafeAreaInsetsMask mask = self.disabledAdjustSafeAreaInsetsMask;
    if ( mask & SJSafeAreaInsetsMaskTop ) insets.top = 0;
    if ( mask & SJSafeAreaInsetsMaskLeft ) insets.left = 0;
    if ( mask & SJSafeAreaInsetsMaskBottom ) insets.bottom = 0;
    if ( mask & SJSafeAreaInsetsMaskRight ) insets.right = 0;
    
    BOOL isFullscreen = self.view.bounds.size.width > self.view.bounds.size.height;
    if ( ![NSStringFromClass(self.class) isEqualToString:@"SJFullscreenModeViewController"] || isFullscreen ) {
        if ( isFullscreen || insets.top != 0 || [self sj_containsPlayerView] == NO ) {
            [self sj_setContentOverlayInsets:insets andLeftMargin:leftMargin rightMargin:rightMargin];
        }
    }
}

- (void)setDisabledAdjustSafeAreaInsetsMask:(SJSafeAreaInsetsMask)disabledAdjustSafeAreaInsetsMask {
    objc_setAssociatedObject(self, @selector(disabledAdjustSafeAreaInsetsMask), @(disabledAdjustSafeAreaInsetsMask), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (SJSafeAreaInsetsMask)disabledAdjustSafeAreaInsetsMask {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}
@end


#pragma mark -

API_AVAILABLE(ios(13.0)) @implementation SJBaseVideoPlayer (SJRotationPrivate_FixSafeArea)
+ (void)initialize {
    if ( @available(iOS 13.0, *) ) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class cls = UIViewController.class;
            SEL originalSelector = @selector(_setContentOverlayInsets:andLeftMargin:rightMargin:);
            SEL swizzledSelector = @selector(sj_setContentOverlayInsets:andLeftMargin:rightMargin:);
            
            Method originalMethod = class_getInstanceMethod(cls, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
            method_exchangeImplementations(originalMethod, swizzledMethod);
        });
    }
}
@end

API_AVAILABLE(ios(13.0)) @implementation UINavigationController (SJRotationPrivate_FixSafeArea)
- (BOOL)sj_containsPlayerView {
    return [self.topViewController sj_containsPlayerView];
}
@end

API_AVAILABLE(ios(13.0)) @implementation UITabBarController (SJRotationPrivate_FixSafeArea)
- (BOOL)sj_containsPlayerView {
    UIViewController *vc = self.selectedIndex != NSNotFound ? self.selectedViewController : self.viewControllers.firstObject;
    return [vc sj_containsPlayerView];
}
@end
NS_ASSUME_NONNULL_END

#endif
