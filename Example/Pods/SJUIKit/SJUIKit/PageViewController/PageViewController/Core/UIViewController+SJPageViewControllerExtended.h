//
//  UIViewController+SJPageViewControllerExtended.h
//  Pods
//
//  Created by BlueDancer on 2020/2/5.
//

#import <UIKit/UIKit.h>
@class SJPageItem;

NS_ASSUME_NONNULL_BEGIN
@interface UIViewController (SJPageViewControllerExtended)
@property (nonatomic, strong, nullable) SJPageItem *sj_pageItem;

- (nullable __kindof UIScrollView *)sj_lookupScrollView;
@end

@interface SJPageItem : NSObject
@property (nonatomic, strong, nullable) __kindof UIScrollView *scrollView;
@property (nonatomic) CGFloat intersection;
@property (nonatomic) CGPoint contentOffset;
@end
NS_ASSUME_NONNULL_END
