//
//  UIScrollView+SJBaseVideoPlayerExtended.m
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2019/11/22.
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
@end
NS_ASSUME_NONNULL_END
