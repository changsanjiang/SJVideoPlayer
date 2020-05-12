//
//  UIScrollView+SJBaseVideoPlayerExtended.m
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/11/22.
//

#import "UIScrollView+SJBaseVideoPlayerExtended.h"
#import "UIView+SJBaseVideoPlayerExtended.h"

NS_ASSUME_NONNULL_BEGIN
@implementation UIScrollView (SJBaseVideoPlayerExtended)
///
/// 获取对应视图
///
- (nullable __kindof UIView *)viewWithTag:(NSInteger)tag atIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath == nil ) return nil;
    __kindof UIView *_Nullable cell = nil;
    if      ( [self isKindOfClass:UITableView.class] ) {
        cell = [(UITableView *)self cellForRowAtIndexPath:indexPath];
    }
    else if ( [self isKindOfClass:UICollectionView.class] ) {
        cell = [(UICollectionView *)self cellForItemAtIndexPath:indexPath];
    }
    return cell != nil ? [cell viewWithTag:tag] : nil;
}

///
/// 对应视图是否在window中显示
///
- (BOOL)isViewAppearedWithTag:(NSInteger)tag atIndexPath:(NSIndexPath *)indexPath {
    UIView *view = [self viewWithTag:tag atIndexPath:indexPath];
    return !CGRectIsEmpty([self intersectionWithView:view]);
}

///
/// 获取对应视图
///
- (nullable __kindof UIView *)viewWithProtocol:(Protocol *)protocol atIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath == nil ) return nil;
    __kindof UIView *_Nullable cell = nil;
    if      ( [self isKindOfClass:UITableView.class] ) {
        cell = [(UITableView *)self cellForRowAtIndexPath:indexPath];
    }
    else if ( [self isKindOfClass:UICollectionView.class] ) {
        cell = [(UICollectionView *)self cellForItemAtIndexPath:indexPath];
    }
    return cell != nil ? [cell viewWithProtocol:protocol] : nil;
}

///
/// 获取对应视图
///
- (nullable __kindof UIView *)viewWithProtocol:(Protocol *)protocol inHeaderForSection:(NSInteger)section {
    __kindof UIView *_Nullable headerView = nil;
    if      ( [self isKindOfClass:UITableView.class] ) {
        headerView = [(UITableView *)self headerViewForSection:section];
    }
    else if ( [self isKindOfClass:UICollectionView.class] ) {
        headerView = [(UICollectionView *)self supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    }
    return headerView != nil ? [headerView viewWithProtocol:protocol] : nil;
}

///
/// 获取对应视图
///
- (nullable __kindof UIView *)viewWithProtocol:(Protocol *)protocol inFooterForSection:(NSInteger)section {
    __kindof UIView *_Nullable footerView = nil;
    if      ( [self isKindOfClass:UITableView.class] ) {
        footerView = [(UITableView *)self footerViewForSection:section];
    }
    else if ( [self isKindOfClass:UICollectionView.class] ) {
        footerView = [(UICollectionView *)self supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    }
    return footerView != nil ? [footerView viewWithProtocol:protocol] : nil;
}

///
/// 对应视图是否在window中显示
///
- (BOOL)isViewAppearedWithProtocol:(Protocol *)protocol atIndexPath:(NSIndexPath *)indexPath {
    UIView *view = [self viewWithProtocol:protocol atIndexPath:indexPath];
    return !CGRectIsEmpty([self intersectionWithView:view]);
}
@end
NS_ASSUME_NONNULL_END
