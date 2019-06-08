//
//  SJIsAppeared.m
//  Masonry
//
//  Created by BlueDancer on 2018/7/10.
//

#import "SJIsAppeared.h"
#import "SJPlayModel.h"

NS_ASSUME_NONNULL_BEGIN

__kindof UIView *_Nullable sj_getTarget(UIScrollView *scrollView, NSIndexPath *viewAtIndexPath, NSInteger viewTag) {
    if ( !viewAtIndexPath || !scrollView )
        return nil;
    UIView *target = nil;
    if ( [scrollView isKindOfClass:[UITableView class]] ) {
        UITableViewCell *cell = [(UITableView *)scrollView cellForRowAtIndexPath:viewAtIndexPath];
        target = [cell viewWithTag:viewTag];
    }
    else if ( [scrollView isKindOfClass:[UICollectionView class]] ) {
        UICollectionViewCell *cell = [(UICollectionView *)scrollView cellForItemAtIndexPath:viewAtIndexPath];
        target = [cell viewWithTag:viewTag];
    }
    return target;
}

bool sj_isAppeared1(NSInteger viewTag, NSIndexPath *viewAtIndexPath, UIScrollView *scrollView) {
    return sj_isAppeared2(sj_getTarget(scrollView, viewAtIndexPath, viewTag), scrollView);
}

bool sj_isAppeared2(UIView *_Nullable childView, UIScrollView *_Nullable scrollView) {
    return !CGRectIsEmpty(sj_intersection(childView, scrollView));
}

extern CGRect sj_intersection(UIView *_Nullable childView, UIScrollView *_Nullable scrollView) {
    if ( !childView || !scrollView || !scrollView.window )
        return CGRectZero;
    CGRect rect = [childView.superview convertRect:childView.frame toView:scrollView];
    CGRect rect_max = (CGRect){scrollView.contentOffset, scrollView.frame.size};
    CGRect ist = CGRectIntersection(rect, rect_max);
    if ( CGRectIsEmpty(ist) || CGRectIsNull(ist) )
        return CGRectZero;
    return ist;
}

UIScrollView *_Nullable sj_getScrollView(SJPlayModel *playModel) {
    if ( playModel.isPlayInTableView || playModel.isPlayInCollectionView ) {
        __kindof UIView *superview = playModel.playerSuperview;
        while ( superview && !([superview isKindOfClass:[UITableView class]] || [superview isKindOfClass:[UICollectionView class]]) ) {
            superview = superview.superview;
        }
        return superview;
    }
    return nil;
}
NS_ASSUME_NONNULL_END
