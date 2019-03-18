//
//  UIScrollView+ListViewAutoplaySJAdd.m
//  Masonry
//
//  Created by BlueDancer on 2018/7/9.
//

#import "UIScrollView+ListViewAutoplaySJAdd.h"
#import <objc/message.h>
#import "SJIsAppeared.h"

#if __has_include(<SJObserverHelper/NSObject+SJObserverHelper.h>)
#import <SJObserverHelper/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@implementation UIScrollView (SJPlayerCurrentPlayingIndexPath)
- (void)setSj_currentPlayingIndexPath:(nullable NSIndexPath *)sj_currentPlayingIndexPath {
    objc_setAssociatedObject(self, @selector(sj_currentPlayingIndexPath), sj_currentPlayingIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable NSIndexPath *)sj_currentPlayingIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}
@end

static void sj_observeContentOffset(UIScrollView *scrollView, void(^contentOffsetDidChangeExeBlock)(void));
static void sj_removeContentOffsetObserver(UIScrollView *scrollView);

static void sj_considerPlayNewAsset(__kindof UIScrollView *scrollView);
static void sj_needPlayNextAsset(__kindof UIScrollView *scrollView);
@implementation UIScrollView (ListViewAutoplaySJAdd)
- (void)setSj_enabledAutoplay:(BOOL)sj_enabledAutoplay {
    objc_setAssociatedObject(self, @selector(sj_enabledAutoplay), @(sj_enabledAutoplay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)sj_enabledAutoplay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSj_autoplayConfig:(nullable SJPlayerAutoplayConfig *)sj_autoplayConfig {
    objc_setAssociatedObject(self, @selector(sj_autoplayConfig), sj_autoplayConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable SJPlayerAutoplayConfig *)sj_autoplayConfig {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)sj_enableAutoplayWithConfig:(SJPlayerAutoplayConfig *)autoplayConfig {
    self.sj_enabledAutoplay = YES;
    self.sj_autoplayConfig = autoplayConfig;

    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) _self = self;
        sj_observeContentOffset(self, ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sj_considerPlayNewAsset) object:nil];
            [self performSelector:@selector(sj_considerPlayNewAsset) withObject:nil afterDelay:0.3];
        });
    });
}

- (void)sj_disenableAutoplay {
    self.sj_enabledAutoplay = NO;
    self.sj_autoplayConfig = nil;
    sj_removeContentOffsetObserver(self);
}

- (void)sj_needPlayNextAsset {
    dispatch_async(dispatch_get_main_queue(), ^{
        sj_needPlayNextAsset(self);
    });
}

- (void)sj_considerPlayNewAsset {
    dispatch_async(dispatch_get_main_queue(), ^{
        sj_considerPlayNewAsset(self);
    });
}
@end

@interface _SJScrollViewContentOffsetObserver : NSObject
- (instancetype)initWithScrollView:(UIScrollView *)scrollView contentOffsetDidChangeExeBlock:(void(^)(void))block;
@end

@implementation _SJScrollViewContentOffsetObserver {
    void(^_contentOffsetDidChangeExeBlock)(void);
}
+ (void)observeScrollView:(__kindof UIScrollView *)scrollView contentOffsetDidChangeExeBlock:(void(^)(void))block {
    _SJScrollViewContentOffsetObserver *_Nullable observer = objc_getAssociatedObject(scrollView, _cmd);
    if ( observer )
        return;
    
    observer = [[_SJScrollViewContentOffsetObserver alloc] initWithScrollView:scrollView contentOffsetDidChangeExeBlock:block];
    objc_setAssociatedObject(scrollView, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (instancetype)initWithScrollView:(UIScrollView *)scrollView contentOffsetDidChangeExeBlock:(void (^)(void))block {
    self = [super init];
    if ( !self ) return nil;
    [scrollView sj_addObserver:self forKeyPath:@"contentOffset"];
    _contentOffsetDidChangeExeBlock = block;
    return self;
}
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( [change[NSKeyValueChangeNewKey] isEqual:change[NSKeyValueChangeOldKey]] )
        return;
    if ( _contentOffsetDidChangeExeBlock ) _contentOffsetDidChangeExeBlock();
}
@end

static char kObserver;
static void sj_observeContentOffset(UIScrollView *scrollView, void(^contentOffsetDidChangeExeBlock)(void)) {
    dispatch_async(dispatch_get_main_queue(), ^{
        _SJScrollViewContentOffsetObserver *_Nullable observer = objc_getAssociatedObject(scrollView, &kObserver);
        if ( observer )
            return;
        observer = [[_SJScrollViewContentOffsetObserver alloc] initWithScrollView:scrollView contentOffsetDidChangeExeBlock:contentOffsetDidChangeExeBlock];
        objc_setAssociatedObject(scrollView, &kObserver, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
}

static void sj_removeContentOffsetObserver(UIScrollView *scrollView) {
    dispatch_async(dispatch_get_main_queue(), ^{
        objc_setAssociatedObject(scrollView, &kObserver, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
}

#pragma mark -
static void sj_tableViewConsiderPlayNewAsset(UITableView *tableView);
static void sj_collectionViewConsiderPlayNewAsset(UICollectionView *collectionView);
static void sj_exeAnima(__kindof UIScrollView *scrollView, NSIndexPath *indexPath, SJAutoplayScrollAnimationType animationType);

static void sj_considerPlayNewAsset(__kindof __kindof UIScrollView *scrollView) {
    if ( !scrollView.sj_enabledAutoplay ) return;
    if ( ![scrollView sj_autoplayConfig].autoplayDelegate ) return;
    if ( [scrollView isKindOfClass:[UITableView class]] )
        sj_tableViewConsiderPlayNewAsset(scrollView);
    else if ( [scrollView isKindOfClass:[UICollectionView class]] )
        sj_collectionViewConsiderPlayNewAsset(scrollView);
}

static NSIndexPath *_Nullable sj_tableViewAutoplayNextIndexPath(UITableView *tableView) {
    NSArray<NSIndexPath *> *_Nullable indexPathsForVisibleRows = tableView.indexPathsForVisibleRows;
    if ( !indexPathsForVisibleRows )
        return nil;
    
    SJPlayerAutoplayConfig *config = [tableView sj_autoplayConfig];
    NSIndexPath *currentPlayingIndexPath = tableView.sj_currentPlayingIndexPath;
    if ( currentPlayingIndexPath &&
        sj_isAppeared1(config.playerSuperviewTag, currentPlayingIndexPath, tableView) )
        return nil;
    
    switch ( config.autoplayPosition ) {
        case SJAutoplayPositionTop: {
            for ( NSIndexPath *indexPath in indexPathsForVisibleRows ) {
                UIView *_Nullable target = sj_getTarget(tableView, indexPath, config.playerSuperviewTag);
                if ( !target ) continue;
                CGRect its = sj_intersection(target, tableView);
                if ( floor(its.size.height) >= floor(target.bounds.size.height) ) {
                    return indexPath;
                }
            }
        }
            break;
        case SJAutoplayPositionMiddle: {
            NSArray<UITableViewCell *> *visibleCells = tableView.visibleCells;
            CGFloat midLine = 0;
            if (@available(iOS 11.0, *)) {
                midLine = floor((CGRectGetHeight(tableView.frame) - tableView.adjustedContentInset.top) * 0.5);
            } else {
                midLine = floor((CGRectGetHeight(tableView.frame) - tableView.contentInset.top) * 0.5);
            }

            NSInteger count = visibleCells.count;
            NSInteger half = (NSInteger)(count * 0.5);
            NSArray<UITableViewCell *> *half_l = [visibleCells subarrayWithRange:NSMakeRange(0, half)];
            NSArray<UITableViewCell *> *half_r = [visibleCells subarrayWithRange:NSMakeRange(half, count - half)];
            
            UITableViewCell *cell_l = nil;
            UIView *half_l_view = nil;
            for ( UITableViewCell *cell in half_l ) {
                UIView *_Nullable superview = [cell viewWithTag:config.playerSuperviewTag];
                if ( !superview ) continue;
                cell_l = cell;
                half_l_view = superview;
            }
            
            UITableViewCell *cell_r = nil;
            UIView *half_r_view = nil;
            for ( UITableViewCell *obj in half_r ) {
                UIView *_Nullable superview = [obj viewWithTag:config.playerSuperviewTag];
                if ( !superview ) continue;
                cell_r = obj;
                half_r_view = superview;
            }
            
            if ( !half_l_view && !half_r_view ) return nil;
            
            NSIndexPath *_Nullable nextIndexPath = nil;
            if ( half_l_view && !half_r_view ) {
                nextIndexPath = [tableView indexPathForCell:cell_l];
            }
            else if ( half_r_view && !half_l_view ) {
                nextIndexPath = [tableView indexPathForCell:cell_r];
            }
            else {
                CGRect half_l_rect = [half_l_view.superview convertRect:half_l_view.frame toView:tableView.superview];
                CGRect half_r_rect = [half_r_view.superview convertRect:half_r_view.frame toView:tableView.superview];
                
                if ( ABS(CGRectGetMaxY(half_l_rect) - midLine) < ABS(CGRectGetMinY(half_r_rect) - midLine) ) {
                    nextIndexPath = [tableView indexPathForCell:cell_l];
                }
                else {
                    nextIndexPath = [tableView indexPathForCell:cell_r];
                }
            }
            return nextIndexPath;
        }
    }

    return nil;
}

static void sj_tableViewConsiderPlayNewAsset(UITableView *tableView) {
    NSIndexPath *_Nullable nextIndexPath = sj_tableViewAutoplayNextIndexPath(tableView);
    if ( !nextIndexPath )
        return;
    SJPlayerAutoplayConfig *config = [tableView sj_autoplayConfig];
    [config.autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:nextIndexPath];
}

static NSIndexPath *_Nullable sj_collectionViewAutoplayNextIndexPath(UICollectionView *collectionView) {
    NSArray<NSIndexPath *> *indexPathsForVisibleItems = [collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    if ( 0 == indexPathsForVisibleItems.count )
        return nil;
    
    SJPlayerAutoplayConfig *config = [collectionView sj_autoplayConfig];
    NSIndexPath *currentPlayingIndexPath = collectionView.sj_currentPlayingIndexPath;
    if ( currentPlayingIndexPath &&
        sj_isAppeared1(config.playerSuperviewTag, currentPlayingIndexPath, collectionView) )
        return nil;
    
    switch ( config.autoplayPosition ) {
        case SJAutoplayPositionTop: {
            for ( NSIndexPath *indexPath in indexPathsForVisibleItems ) {
                UIView *_Nullable target = sj_getTarget(collectionView, indexPath, config.playerSuperviewTag);
                if ( !target ) continue;
                CGRect its = sj_intersection(target, collectionView);
                if ( floor(its.size.height) >= floor(target.bounds.size.height) ) {
                    return indexPath;
                }
            }
        }
            break;
        case SJAutoplayPositionMiddle: {
            CGFloat midLine = 0;
            if (@available(iOS 11.0, *)) {
                midLine = floor((CGRectGetHeight(collectionView.frame) - collectionView.adjustedContentInset.top) * 0.5);
            } else {
                midLine = floor((CGRectGetHeight(collectionView.frame) - collectionView.contentInset.top) * 0.5);
            }
            
            NSMutableArray<UICollectionViewCell *> *visibleCells = [NSMutableArray arrayWithCapacity:indexPathsForVisibleItems.count];
            for ( NSIndexPath *indexPath in indexPathsForVisibleItems ) {
                [visibleCells addObject:[collectionView cellForItemAtIndexPath:indexPath]];
            }
            NSInteger count = visibleCells.count;
            NSInteger half = (NSInteger)(count * 0.5);
            NSArray<UICollectionViewCell *> *half_l = [visibleCells subarrayWithRange:NSMakeRange(0, half)];
            NSArray<UICollectionViewCell *> *half_r = [visibleCells subarrayWithRange:NSMakeRange(half, count - half)];
            
            __block UICollectionViewCell *cell_l = nil;
            __block UIView *half_l_view = nil;
            [half_l enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIView *superview = [obj viewWithTag:config.playerSuperviewTag];
                if ( !superview ) return;
                *stop = YES;
                cell_l = obj;
                half_l_view = superview;
            }];
            
            __block UICollectionViewCell *cell_r = nil;
            __block UIView *half_r_view = nil;
            [half_r enumerateObjectsUsingBlock:^(UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIView *superview = [obj viewWithTag:config.playerSuperviewTag];
                if ( !superview ) return;
                *stop = YES;
                cell_r = obj;
                half_r_view = superview;
            }];
            
            if ( !half_l_view && !half_r_view ) return nil;
            
            NSIndexPath *nextIndexPath = nil;
            if ( half_l_view && !half_r_view ) {
                nextIndexPath = [collectionView indexPathForCell:cell_l];
            }
            else if ( half_r_view && !half_l_view ) {
                nextIndexPath = [collectionView indexPathForCell:cell_r];
            }
            else {
                CGRect half_l_rect = [half_l_view.superview convertRect:half_l_view.frame toView:collectionView.superview];
                CGRect half_r_rect = [half_r_view.superview convertRect:half_r_view.frame toView:collectionView.superview];
                
                if ( ABS(CGRectGetMaxY(half_l_rect) - midLine) < ABS(CGRectGetMinY(half_r_rect) - midLine) ) {
                    nextIndexPath = [collectionView indexPathForCell:cell_l];
                }
                else {
                    nextIndexPath = [collectionView indexPathForCell:cell_r];
                }
            }

            return nextIndexPath;
        }
    }
    return nil;
}

static void sj_collectionViewConsiderPlayNewAsset(UICollectionView *collectionView) {
    NSIndexPath *_Nullable nextIndexPath = sj_collectionViewAutoplayNextIndexPath(collectionView);
    if ( !nextIndexPath )
        return;
    SJPlayerAutoplayConfig *config = [collectionView sj_autoplayConfig];
    [config.autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:nextIndexPath];
}

/// 执行动画
static void sj_exeAnima(__kindof UIScrollView *scrollView, NSIndexPath *indexPath, SJAutoplayScrollAnimationType animationType) {
    switch ( animationType ) {
        case SJAutoplayScrollAnimationTypeNone: break;
        case SJAutoplayScrollAnimationTypeTop: {
            @try{
                if ( [scrollView isKindOfClass:[UITableView class]] ) {
                    [UIView animateWithDuration:0.6 animations:^{
                        [(UITableView *)scrollView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    }];
                }
                else if ( [scrollView isKindOfClass:[UICollectionView class]] ) {
                    [(UICollectionView *)scrollView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
                }
            }@catch(NSException *__unused ex) {}
        }
            break;
        case SJAutoplayScrollAnimationTypeMiddle: {
            @try{
                if ( [scrollView isKindOfClass:[UITableView class]] ) {
                    [UIView animateWithDuration:0.6 animations:^{
                        [(UITableView *)scrollView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                    }];
                }
                else if ( [scrollView isKindOfClass:[UICollectionView class]] ) {
                    [(UICollectionView *)scrollView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
                }
            }@catch(NSException *__unused ex) {}
        }
            break;
    }
}

#pragma mark -
static void sj_tableViewConsiderPlayNextAsset(UITableView *tableView);
static void sj_collectionViewConsiderPlayNextAsset(UICollectionView *collectionView);
static void sj_needPlayNextAsset(__kindof UIScrollView *scrollView) {
    if ( [scrollView isKindOfClass:[UITableView class]] ) {
        sj_tableViewConsiderPlayNextAsset((id)scrollView);
    }
    else if ( [scrollView isKindOfClass:[UICollectionView class]] ) {
        sj_collectionViewConsiderPlayNextAsset((id)scrollView);
    }
}

static void sj_tableViewConsiderPlayNextAsset(UITableView *tableView) {
    NSArray<NSIndexPath *> *visibleIndexPaths = tableView.indexPathsForVisibleRows;
    if ( visibleIndexPaths.count == 0 )
        return;
    if ( [visibleIndexPaths.lastObject compare:tableView.sj_currentPlayingIndexPath] == NSOrderedSame )
        return;
    
    NSInteger idx = [visibleIndexPaths indexOfObject:tableView.sj_currentPlayingIndexPath];
    if ( !tableView.sj_currentPlayingIndexPath ) {
        NSIndexPath *indexPath = [tableView.indexPathsForVisibleRows firstObject];
        
        [[tableView sj_autoplayConfig].autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:indexPath];
        sj_exeAnima(tableView, indexPath, [tableView sj_autoplayConfig].animationType);
    }
    else if ( idx == NSNotFound ) {
        sj_considerPlayNewAsset(tableView);
    }
    else {
        NSInteger next = idx + 1;
        NSArray<NSIndexPath *> *subIndexPaths = [visibleIndexPaths subarrayWithRange:NSMakeRange(next, visibleIndexPaths.count - next)];
        if ( subIndexPaths.count == 0 )
            return;
        __block NSIndexPath *nextIndexPath = nil;
        NSInteger superviewTag = [tableView sj_autoplayConfig].playerSuperviewTag;
        [subIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIView *superview = [[tableView cellForRowAtIndexPath:obj] viewWithTag:superviewTag];
            if ( !superview )
                return;
            *stop = YES;
            nextIndexPath = obj;
        }];
        if ( !nextIndexPath )
            return;
        [[tableView sj_autoplayConfig].autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:nextIndexPath];
        sj_exeAnima(tableView, nextIndexPath, [tableView sj_autoplayConfig].animationType);
    }
}

static void sj_collectionViewConsiderPlayNextAsset(UICollectionView *collectionView) {
    NSArray<NSIndexPath *> *visibleIndexPaths = [collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    if ( visibleIndexPaths.count == 0 ) return;
    if ( [visibleIndexPaths.lastObject compare:collectionView.sj_currentPlayingIndexPath] == NSOrderedSame ) return;
    NSInteger idx = [visibleIndexPaths indexOfObject:collectionView.sj_currentPlayingIndexPath];
    if ( !collectionView.sj_currentPlayingIndexPath ) {
        NSIndexPath *indexPath = [visibleIndexPaths firstObject];
        
        [[collectionView sj_autoplayConfig].autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:indexPath];
        sj_exeAnima(collectionView, indexPath, [collectionView sj_autoplayConfig].animationType);
    }
    else if ( idx == NSNotFound ) {
        sj_considerPlayNewAsset(collectionView);
    }
    else {
        NSInteger next = idx + 1;
        NSArray<NSIndexPath *> *subIndexPaths = [visibleIndexPaths subarrayWithRange:NSMakeRange(next, visibleIndexPaths.count - next)];
        if ( subIndexPaths.count == 0 )
            return;
        __block NSIndexPath *nextIndexPath = nil;
        NSInteger superviewTag = [collectionView sj_autoplayConfig].playerSuperviewTag;
        [subIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIView *superview = [[collectionView cellForItemAtIndexPath:obj] viewWithTag:superviewTag];
            if ( !superview )
                return;
            *stop = YES;
            nextIndexPath = obj;
        }];
        if ( !nextIndexPath )
            return;
        
        [[collectionView sj_autoplayConfig].autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:nextIndexPath];
        sj_exeAnima(collectionView, nextIndexPath, [collectionView sj_autoplayConfig].animationType);
    }
}

NS_ASSUME_NONNULL_END
