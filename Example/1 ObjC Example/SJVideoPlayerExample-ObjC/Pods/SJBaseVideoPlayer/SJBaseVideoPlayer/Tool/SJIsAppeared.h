//
//  SJIsAppeared.h
//  Masonry
//
//  Created by BlueDancer on 2018/7/10.
//

#import <UIKit/UIKit.h>
@class SJPlayModel;

NS_ASSUME_NONNULL_BEGIN
extern __kindof UIView *_Nullable sj_getTarget(UIScrollView *scrollView, NSIndexPath *viewAtIndexPath, NSInteger viewTag);

extern bool sj_isAppeared1(NSInteger viewTag, NSIndexPath *viewAtIndexPath, UIScrollView *scrollView);

extern bool sj_isAppeared2(UIView *_Nullable childView, UIView *_Nullable rootView);

extern CGRect sj_intersection(UIView *_Nullable childView, UIView *_Nullable rootView);

extern UIScrollView *_Nullable sj_getScrollView(SJPlayModel *playModel);
NS_ASSUME_NONNULL_END
