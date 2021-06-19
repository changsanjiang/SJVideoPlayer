//
//  SJPageMenuBarSubclass.h
//  Pods
//
//  Created by BlueDancer on 2021/5/8.
//

#ifndef SJPageMenuBarSubclass_h
#define SJPageMenuBarSubclass_h

#import "SJPageMenuBar.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJPageMenuBar (SJPageMenuBarSubclassHooks)
- (void)updateForItemView:(__kindof UIView<SJPageMenuItemView> *)itemView zoomScale:(CGFloat)scale transitionProgress:(CGFloat)progress tintColor:(UIColor *)tintColor bounds:(CGRect)bounds center:(CGPoint)center NS_REQUIRES_SUPER;
@end
NS_ASSUME_NONNULL_END

#endif /* SJPageMenuBarSubclass_h */
