//
//  UIScrollView+SJPageViewControllerExtended.h
//  Pods
//
//  Created by 畅三江 on 2020/2/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (SJPageViewControllerExtended)
- (void)sj_lock;
- (void)sj_unlock;
- (BOOL)sj_locked;
@end

NS_ASSUME_NONNULL_END
