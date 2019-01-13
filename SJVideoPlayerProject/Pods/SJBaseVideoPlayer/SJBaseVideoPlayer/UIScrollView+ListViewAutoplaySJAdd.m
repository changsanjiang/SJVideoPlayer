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
@protocol UIScrollViewDelegate_ListViewAutoplaySJAdd <UIScrollViewDelegate>
- (void)sj_scrollViewDidEndDragging:(__kindof UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)sj_scrollViewDidEndDecelerating:(__kindof UIScrollView *)scrollView;
@end

/// took over
static bool sj_isTookOver(Class cls);
static void sj_setIsTookOver(Class cls);
static void sj_tookOverMethod(Class cls, struct objc_method_description *des, SEL tookOverSEL, IMP tookOverIMP);
static void sj_scrollViewDidEndDragging(id<UIScrollViewDelegate_ListViewAutoplaySJAdd> delegate, SEL _cmd, __kindof UIScrollView *scrollView, bool willDecelerate);
static void sj_scrollViewDidEndDecelerating(id<UIScrollViewDelegate_ListViewAutoplaySJAdd> delegate, SEL _cmd, __kindof UIScrollView *scrollView);

/// autoplay
static void sj_scrollViewConsiderPlayNewAsset(__kindof __kindof UIScrollView *scrollView);
static void sj_tableViewConsiderPlayNextAsset(UITableView *tableView);
static void sj_collectionViewConsiderPlayNextAsset(UICollectionView *collectionView);


@interface _SJScrollViewDelegateObserver: NSObject
+ (void)observeScrollView:(__kindof UIScrollView *)scrollView delegateChangeExeBlock:(void(^)(void))block;
- (instancetype)initWithScrollView:(__kindof UIScrollView *)scrollView valueChangeExeBlock:(void(^)(_SJScrollViewDelegateObserver *observer))block;
@property (nonatomic, copy) void(^valueChangeExeBlock)(_SJScrollViewDelegateObserver *observer);
@end

@implementation _SJScrollViewDelegateObserver
+ (void)observeScrollView:(__kindof UIScrollView *)scrollView delegateChangeExeBlock:(void(^)(void))block {
    if ( objc_getAssociatedObject(scrollView, _cmd) != nil ) return;
    _SJScrollViewDelegateObserver *observer = [[_SJScrollViewDelegateObserver alloc] initWithScrollView:scrollView valueChangeExeBlock:^(_SJScrollViewDelegateObserver * _Nonnull observer) {
        if ( block ) block();
    }];
    objc_setAssociatedObject(scrollView, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
static NSString *delegateKey = @"delegate";
- (instancetype)initWithScrollView:(__kindof UIScrollView *)scrollView valueChangeExeBlock:(void (^)(_SJScrollViewDelegateObserver * _Nonnull))block {
    self = [super init];
    if ( !self ) return nil;
    _valueChangeExeBlock = block;
    [scrollView sj_addObserver:self forKeyPath:delegateKey context:&delegateKey];
    return self;
}
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( context == &delegateKey ) {
        if ( change[NSKeyValueChangeOldKey] == change[NSKeyValueChangeNewKey] ) return;
        if ( _valueChangeExeBlock ) _valueChangeExeBlock(self);
    }
}
@end

@implementation UIScrollView (SJPlayerCurrentPlayingIndexPath)
- (void)setSj_currentPlayingIndexPath:(nullable NSIndexPath *)sj_currentPlayingIndexPath {
    objc_setAssociatedObject(self, @selector(sj_currentPlayingIndexPath), sj_currentPlayingIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable NSIndexPath *)sj_currentPlayingIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)sj_needPlayNextAsset {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 查询当前显示的cell中(sj_currentPlayingIndexPath之后的), 是否存在播放器父视图
        if ( [self isKindOfClass:[UITableView class]] ) {
            sj_tableViewConsiderPlayNextAsset((id)self);
        }
        else if ( [self isKindOfClass:[UICollectionView class]] ) {
            sj_collectionViewConsiderPlayNextAsset((id)self);
        }
    });
}
@end

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

    if ( self.delegate ) { [self _sj_tookOver]; }
    
    __weak typeof(self) _self = self;
    [_SJScrollViewDelegateObserver observeScrollView:self delegateChangeExeBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.delegate ) [self _sj_tookOver];
    }];
}

- (void)sj_disenableAutoplay {
    self.sj_enabledAutoplay = NO;
    self.sj_autoplayConfig = nil;
}

#pragma mark -
- (void)_sj_tookOver {
    if ( [self isMemberOfClass:[UIScrollView class]] ) return;
    Class delegate_cls = [self.delegate class];
    if ( sj_isTookOver(delegate_cls) ) return; sj_setIsTookOver(delegate_cls);
    Protocol *protocol = @protocol(UIScrollViewDelegate);
    struct objc_method_description des = protocol_getMethodDescription(protocol, @selector(scrollViewDidEndDragging:willDecelerate:), NO, YES);
    sj_tookOverMethod(delegate_cls, &des, @selector(sj_scrollViewDidEndDragging:willDecelerate:), (IMP)sj_scrollViewDidEndDragging);
    
    des = protocol_getMethodDescription(protocol, @selector(scrollViewDidEndDecelerating:), NO, YES);
    sj_tookOverMethod(delegate_cls, &des, @selector(sj_scrollViewDidEndDecelerating:), (IMP)sj_scrollViewDidEndDecelerating);
}

@end

static const char *tookOverKey = "tookOverKey";
static bool sj_isTookOver(Class cls) {
    return [objc_getAssociatedObject(cls, tookOverKey) boolValue];
}

static void sj_setIsTookOver(Class cls) {
    objc_setAssociatedObject(cls, tookOverKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void sj_none() { /* nothing */ }

static void sj_tookOverMethod(Class cls, struct objc_method_description *des, SEL tookOverSEL, IMP tookOverIMP) {
    Method origin = class_getInstanceMethod(cls, des->name);
    if ( !origin ) { class_addMethod(cls, des->name, (IMP)sj_none, des->types); origin = class_getInstanceMethod(cls, des->name); }
    class_addMethod(cls, tookOverSEL, tookOverIMP, des->types);
    Method t = class_getInstanceMethod(cls, tookOverSEL);
    method_exchangeImplementations(origin, t);
}

static void sj_tableViewConsiderPlayNewAsset(UITableView *tableView);
static void sj_collectionViewConsiderPlayNewAsset(UICollectionView *collectionView);
static void sj_exeAnima(__kindof UIScrollView *scrollView, NSIndexPath *indexPath, SJAutoplayScrollAnimationType animationType);

static void sj_scrollViewDidEndDragging(id<UIScrollViewDelegate_ListViewAutoplaySJAdd> delegate, SEL _cmd, __kindof UIScrollView *scrollView, bool willDecelerate) {
    [delegate sj_scrollViewDidEndDragging:scrollView willDecelerate:willDecelerate];
    if ( willDecelerate ) return;
    sj_scrollViewConsiderPlayNewAsset(scrollView);
}

static void sj_scrollViewDidEndDecelerating(id<UIScrollViewDelegate_ListViewAutoplaySJAdd> delegate, SEL _cmd, __kindof UIScrollView *scrollView) {
    [delegate sj_scrollViewDidEndDecelerating:scrollView];
    sj_scrollViewConsiderPlayNewAsset(scrollView);
}

static void sj_scrollViewConsiderPlayNewAsset(__kindof __kindof UIScrollView *scrollView) {
    if ( !scrollView.sj_enabledAutoplay ) return;
    if ( ![scrollView sj_autoplayConfig].autoplayDelegate ) return;
    if ( [scrollView isKindOfClass:[UITableView class]] ) sj_tableViewConsiderPlayNewAsset(scrollView);
    else if ( [scrollView isKindOfClass:[UICollectionView class]] ) sj_collectionViewConsiderPlayNewAsset(scrollView);
}

static void sj_tableViewConsiderPlayNewAsset(UITableView *tableView) {
    NSArray<UITableViewCell *> *visibleCells = tableView.visibleCells;
    if ( visibleCells.count == 0 ) return;
    
    SJPlayerAutoplayConfig *config = [tableView sj_autoplayConfig];
    
    NSIndexPath *currentPlayingIndexPath = tableView.sj_currentPlayingIndexPath;
    if ( currentPlayingIndexPath &&
         sj_isAppeared1(config.playerSuperviewTag, currentPlayingIndexPath, tableView) ) return;

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

    __block UITableViewCell *cell_l = nil;
    __block UIView *half_l_view = nil;
    [half_l enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *superview = [obj viewWithTag:config.playerSuperviewTag];
        if ( !superview ) return;
        *stop = YES;
        cell_l = obj;
        half_l_view = superview;
    }];

    __block UITableViewCell *cell_r = nil;
    __block UIView *half_r_view = nil;
    [half_r enumerateObjectsUsingBlock:^(UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *superview = [obj viewWithTag:config.playerSuperviewTag];
        if ( !superview ) return;
        *stop = YES;
        cell_r = obj;
        half_r_view = superview;
    }];

    if ( !half_l_view && !half_r_view ) return;
    
    NSIndexPath *nextIndexPath = nil;
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
    [config.autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:nextIndexPath];
}

static void sj_collectionViewConsiderPlayNewAsset(UICollectionView *collectionView) {
    NSArray<UICollectionViewCell *> *visibleCells = [collectionView.visibleCells sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [[collectionView indexPathForCell:obj1] compare:[collectionView indexPathForCell:obj2]];
    }];
    if ( visibleCells.count == 0 ) return;
    
    SJPlayerAutoplayConfig *config = [collectionView sj_autoplayConfig];
    
    NSIndexPath *currentPlayingIndexPath = collectionView.sj_currentPlayingIndexPath;
    if ( currentPlayingIndexPath &&
         sj_isAppeared1(config.playerSuperviewTag, currentPlayingIndexPath, collectionView) ) return;
    
    CGFloat midLine = 0;
    if (@available(iOS 11.0, *)) {
        midLine = floor((CGRectGetHeight(collectionView.frame) - collectionView.adjustedContentInset.top) * 0.5);
    } else {
        midLine = floor((CGRectGetHeight(collectionView.frame) - collectionView.contentInset.top) * 0.5);
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
    
    if ( !half_l_view && !half_r_view ) return;
    
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

static void sj_tableViewConsiderPlayNextAsset(UITableView *tableView) {
    NSArray<NSIndexPath *> *visibleIndexPaths = tableView.indexPathsForVisibleRows;
    if ( visibleIndexPaths.count == 0 ) return;
    if ( [visibleIndexPaths.lastObject compare:tableView.sj_currentPlayingIndexPath] == NSOrderedSame ) return;
    NSInteger cut = tableView.sj_currentPlayingIndexPath ? [visibleIndexPaths indexOfObject:tableView.sj_currentPlayingIndexPath] + 1  : 0;
    NSArray<NSIndexPath *> *subIndexPaths = [visibleIndexPaths subarrayWithRange:NSMakeRange(cut, visibleIndexPaths.count - cut)];
    if ( subIndexPaths.count == 0 ) return;
    __block NSIndexPath *nextIndexPath = nil;
    NSInteger superviewTag = [tableView sj_autoplayConfig].playerSuperviewTag;
    [subIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *superview = [[tableView cellForRowAtIndexPath:obj] viewWithTag:superviewTag];
        if ( !superview ) return;
        *stop = YES;
        nextIndexPath = obj;
    }];
    if ( !nextIndexPath ) return;

    [[tableView sj_autoplayConfig].autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:nextIndexPath];
    sj_exeAnima(tableView, nextIndexPath, [tableView sj_autoplayConfig].animationType);
}

static void sj_collectionViewConsiderPlayNextAsset(UICollectionView *collectionView) {
    NSArray<NSIndexPath *> *visibleIndexPaths = [collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    if ( visibleIndexPaths.count == 0 ) return;
    if ( [visibleIndexPaths.lastObject compare:collectionView.sj_currentPlayingIndexPath] == NSOrderedSame ) return;
    NSInteger cut = collectionView.sj_currentPlayingIndexPath ? [visibleIndexPaths indexOfObject:collectionView.sj_currentPlayingIndexPath] + 1 : 0;
    NSArray<NSIndexPath *> *subIndexPaths = [visibleIndexPaths subarrayWithRange:NSMakeRange(cut, visibleIndexPaths.count - cut)];
    if ( subIndexPaths.count == 0 ) return;
    __block NSIndexPath *nextIndexPath = nil;
    NSInteger superviewTag = [collectionView sj_autoplayConfig].playerSuperviewTag;
    [subIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *superview = [[collectionView cellForItemAtIndexPath:obj] viewWithTag:superviewTag];
        if ( !superview ) return;
        *stop = YES;
        nextIndexPath = obj;
    }];
    if ( !nextIndexPath ) return;
    
    [[collectionView sj_autoplayConfig].autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:nextIndexPath];
    sj_exeAnima(collectionView, nextIndexPath, [collectionView sj_autoplayConfig].animationType);
}

NS_ASSUME_NONNULL_END
