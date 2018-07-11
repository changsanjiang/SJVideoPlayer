//
//  SJIsAppeared.m
//  Masonry
//
//  Created by BlueDancer on 2018/7/10.
//

#import "SJIsAppeared.h"

/// View -> UITableViewCell -> UITableView
bool sj_isAppeared1(NSInteger viewTag, NSIndexPath *viewAtIndexPath, UITableView *tableView) {
    if ( ![tableView.indexPathsForVisibleRows containsObject:viewAtIndexPath] ) return NO;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:viewAtIndexPath];
    UIView *target = [cell viewWithTag:viewTag];
    CGRect rect = [target.superview convertRect:target.frame toView:tableView.superview];
    CGRect inset = CGRectIntersection(rect, tableView.frame);
    return !CGRectIsNull(inset);
}

bool sj_isAppeared2(UIView *childView, UITableView *tableView) {
    CGRect rect = [childView.superview convertRect:childView.frame toView:tableView];;
    return tableView.contentOffset.y <= CGRectGetMaxY(rect);
}

/// View -> UICollectionViewCell -> UICollectionView
bool sj_isAppeared3(NSInteger viewTag, NSIndexPath *viewAtIndexPath, UICollectionView *collectionView) {
    if ( ![collectionView.indexPathsForVisibleItems containsObject:viewAtIndexPath] ) return NO;
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:viewAtIndexPath];
    UIView *view = [cell viewWithTag:viewTag];
    CGRect rect = [view.superview convertRect:view.frame toView:collectionView.superview];
    CGRect inset = CGRectIntersection(rect, collectionView.frame);
    return !CGRectIsNull(inset);
}

/// View -> UICollectionViewCell -> UICollectionView -> UITableViewCell -> UITableView
bool sj_isAppeared4(NSInteger viewTag, NSIndexPath *viewAtIndexPath, NSInteger collectionViewTag, NSIndexPath * collectionViewAtIndexPath, UITableView *tableView) {
    UICollectionView *collectionView = (id)[[tableView cellForRowAtIndexPath:collectionViewAtIndexPath] viewWithTag:collectionViewTag];
    // 确定collectionView是否显示
    bool isAppeared = sj_isAppeared1(collectionViewTag, collectionViewAtIndexPath, tableView);
    if ( !isAppeared ) return false;
    
    // 确定view是否显示
    isAppeared = sj_isAppeared3(viewTag, viewAtIndexPath, collectionView);
    if ( !isAppeared ) return false;
    
    // 确定view是否在tableview中显示
    return sj_isAppeared2([[collectionView cellForItemAtIndexPath:viewAtIndexPath] viewWithTag:viewTag], tableView);
}

/// View -> UICollectionViewCell -> UICollectionView -> UITableHeaderView -> UITableView
bool sj_isAppeared5(NSInteger viewTag, NSIndexPath *viewAtIndexPath, UICollectionView *collectionView, UITableView *tableView) {
    // 确定collectionView是否显示
    bool isAppeared = sj_isAppeared2(collectionView, tableView);
    if ( !isAppeared ) return false;
    
    // 确定view是否显示
    isAppeared = sj_isAppeared3(viewTag, viewAtIndexPath, collectionView);
    if ( !isAppeared ) return false;
    
    // 确定view是否在tableview中显示
    return sj_isAppeared2([[collectionView cellForItemAtIndexPath:viewAtIndexPath] viewWithTag:viewTag], tableView);
}
