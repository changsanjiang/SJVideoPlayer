//
//  UIViewController+SJPageViewControllerExtended.h
//  Pods
//
//  Created by BlueDancer on 2020/2/5.
//

#import <UIKit/UIKit.h>
@class SJPageScrollViewItem;

NS_ASSUME_NONNULL_BEGIN
@interface UIViewController (SJPageViewControllerExtended)
@property (nonatomic, strong, nullable) SJPageScrollViewItem *sj_scrollViewItem;

- (nullable __kindof UIScrollView *)sj_lookupScrollView;
@end

@interface SJPageScrollViewItem : NSObject
@property (nonatomic, strong, nullable) __kindof UIScrollView *scrollView;
@property (nonatomic) CGFloat intersection;
@property (nonatomic) CGPoint contentOffset;
@end
NS_ASSUME_NONNULL_END
