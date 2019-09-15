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

bool sj_isAppeared2(UIView *_Nullable childView, UIView *_Nullable rootView) {
    return !CGRectIsEmpty(sj_intersection(childView, rootView));
}

CGRect sj_intersection(UIView *_Nullable childView, UIView *_Nullable rootView) {
    __unsafe_unretained UIWindow *_Nullable window = rootView.window;
    if ( childView == nil || rootView == nil || window == nil )
        return CGRectZero;
    CGRect child = [childView convertRect:childView.bounds toView:window];
    CGRect root = [rootView convertRect:rootView.bounds toView:window];
    CGRect ist = CGRectIntersection(child, root);
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
