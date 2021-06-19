//
//  UIScrollView+SJPageViewControllerExtended.h
//  Pods
//
//  Created by BlueDancer on 2020/2/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SJPageViewControllerExtended)
- (void)sj_lock;
- (void)sj_unlock;
- (BOOL)sj_locked;
@end

@interface UIScrollView (SJPageViewControllerExtended)
- (__kindof UIResponder *_Nullable)sj_page_lookupResponderForClass:(Class)cls;
@end

NS_ASSUME_NONNULL_END
