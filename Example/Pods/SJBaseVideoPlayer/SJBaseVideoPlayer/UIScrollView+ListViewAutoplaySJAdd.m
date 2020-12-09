//
//  UIScrollView+ListViewAutoplaySJAdd.m
//  Masonry
//
//  Created by 畅三江 on 2018/7/9.
//

#import "UIScrollView+ListViewAutoplaySJAdd.h"
#import "UIScrollView+SJBaseVideoPlayerExtended.h"
#import "UIView+SJBaseVideoPlayerExtended.h"
#import "SJBaseVideoPlayerConst.h"
#import "SJPlayModel.h"
#import <objc/message.h>

#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

#if __has_include(<SJUIKit/SJRunLoopTaskQueue.h>)
#import <SJUIKit/SJRunLoopTaskQueue.h>
#else
#import "SJRunLoopTaskQueue.h"
#endif

NS_ASSUME_NONNULL_BEGIN
static NSString *const kQueue = @"SJBaseVideoPlayerAutoplayTaskQueue";
static void sj_exeAnima(__kindof UIScrollView *scrollView, NSIndexPath *indexPath, SJAutoplayScrollAnimationType animationType);
static void sj_playAsset(UIScrollView *scrollView, NSIndexPath *indexPath, BOOL animated);
static SJRunLoopTaskQueue *
sj_queue(void) {
    static SJRunLoopTaskQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = SJRunLoopTaskQueue.queue(kQueue).update(CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    });
    return queue;
}

@implementation UIScrollView (SJAutoplayPrivate)
- (void)setSj_currentPlayingIndexPath:(nullable NSIndexPath *)sj_currentPlayingIndexPath {
    objc_setAssociatedObject(self, @selector(sj_currentPlayingIndexPath), sj_currentPlayingIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable NSIndexPath *)sj_currentPlayingIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}
@end

static void sj_playNextAssetAfterEndScroll(__kindof UIScrollView *scrollView);
static void sj_playNextVisibleAsset(__kindof UIScrollView *scrollView);

static void sj_scrollViewContentOffsetDidChange(UIScrollView *scrollView, void(^contentOffsetDidChangeExeBlock)(void));
static void sj_removeContentOffsetObserver(UIScrollView *scrollView);

@implementation UIScrollView (ListViewAutoplaySJAdd)
- (void)setSj_enabledAutoplay:(BOOL)sj_enabledAutoplay {
    objc_setAssociatedObject(self, @selector(sj_enabledAutoplay), @(sj_enabledAutoplay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)sj_enabledAutoplay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)sj_playAssetAtIndexPath:(NSIndexPath *)indexPath scrollAnimated:(BOOL)animated {
    if ( self.window == nil )
        return;
    
    [self sj_removeCurrentPlayerView];

    sj_queue().empty();
    if ( [self isKindOfClass:UITableView.class] ) {
        UITableView *tableView = (id)self;
        UITableViewScrollPosition position = [self sj_autoplayConfig].animationType != SJAutoplayScrollAnimationTypeTop ? UITableViewScrollPositionMiddle : UITableViewScrollPositionTop;
        if (@available(iOS 11.0, *)) {
            [tableView performBatchUpdates:^{
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            } completion:^(BOOL finished) {
                if ( [tableView numberOfRowsInSection:indexPath.section] > indexPath.row ) {
                    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:position animated:animated];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        sj_queue().empty();
                        [[self sj_autoplayConfig].autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:indexPath];
                    });
                }
            }];
        } else {
            [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
                [tableView beginUpdates];
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
            } completion:^(BOOL finished) {
                if ( [tableView numberOfRowsInSection:indexPath.section] > indexPath.row ) {
                    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:position animated:animated];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        sj_queue().empty();
                        [[self sj_autoplayConfig].autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:indexPath];
                    });
                }
            }];
        }
    }
    else if ( [self isKindOfClass:UICollectionView.class] ) {
        UICollectionView *collectionView = (id)self;
        UICollectionViewScrollPosition position = [self sj_autoplayConfig].animationType != SJAutoplayScrollAnimationTypeTop ? UICollectionViewScrollPositionCenteredVertically : UICollectionViewScrollPositionTop;
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:animated];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sj_queue().empty();
            [[self sj_autoplayConfig].autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:indexPath];
        });
    }
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

    __weak typeof(self) _self = self;
    sj_scrollViewContentOffsetDidChange(self, ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.sj_hasDelayedEndScrollTask == YES ) {
            self.sj_hasDelayedEndScrollTask = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sj_playNextAssetAfterEndScroll) object:nil];
        }

        sj_queue().empty();
        ///
        /// Thanks @YangYus
        ///
        /// Fix [#180](https://github.com/changsanjiang/SJVideoPlayer/issues/180)
        ///
        if ( self.window == nil ) {
            return;
        }

        sj_queue().enqueue(^{
            self.sj_hasDelayedEndScrollTask = YES;
            [self performSelector:@selector(sj_playNextAssetAfterEndScroll) withObject:nil afterDelay:0.4];
        });
    });
}

- (void)sj_disenableAutoplay {
    self.sj_enabledAutoplay = NO;
    self.sj_autoplayConfig = nil;
    self.sj_currentPlayingIndexPath = nil;
    sj_removeContentOffsetObserver(self);
}

- (void)sj_playNextVisibleAsset {
    dispatch_async(dispatch_get_main_queue(), ^{
        sj_playNextVisibleAsset(self);
    });
}

- (void)sj_removeCurrentPlayerView {
    self.sj_currentPlayingIndexPath = nil;
    [[self viewWithTag:SJBaseVideoPlayerViewTag] removeFromSuperview];
}

- (void)sj_playNextAssetAfterEndScroll {
    self.sj_hasDelayedEndScrollTask = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        sj_playNextAssetAfterEndScroll(self);
    });
}

- (NSArray<NSIndexPath *> *_Nullable)sj_visibleIndexPaths {
    NSArray<NSIndexPath *> *_Nullable visibleIndexPaths = nil;
    if ( [self isKindOfClass:[UITableView class]] )
        visibleIndexPaths = [(UITableView *)self indexPathsForVisibleRows];
    else if ( [self isKindOfClass:[UICollectionView class]] )
        visibleIndexPaths = [[(UICollectionView *)self indexPathsForVisibleItems] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
    return visibleIndexPaths;
}

- (void)setSj_hasDelayedEndScrollTask:(BOOL)sj_hasDelayedEndScrollTask {
    objc_setAssociatedObject(self, @selector(sj_hasDelayedEndScrollTask), @(sj_hasDelayedEndScrollTask), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)sj_hasDelayedEndScrollTask {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end

@interface _SJScrollViewContentOffsetObserver : NSObject
- (instancetype)initWithScrollView:(UIScrollView *)scrollView contentOffsetDidChangeExeBlock:(void(^)(void))block;
@property (nonatomic, copy, readonly) void(^contentOffsetDidChangeExeBlock)(void);
@end

@implementation _SJScrollViewContentOffsetObserver
- (instancetype)initWithScrollView:(UIScrollView *)scrollView contentOffsetDidChangeExeBlock:(void (^)(void))block {
    self = [super init];
    if ( !self ) return nil;
    _contentOffsetDidChangeExeBlock = block;
    dispatch_async(dispatch_get_main_queue(), ^{
        [scrollView sj_addObserver:self forKeyPath:@"contentOffset"];
    });
    return self;
}
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    _contentOffsetDidChangeExeBlock();
}
@end

static char kObserver;
static void sj_scrollViewContentOffsetDidChange(UIScrollView *scrollView, void(^contentOffsetDidChangeExeBlock)(void)) {
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

static void sj_playNextAssetAfterEndScroll(__kindof __kindof UIScrollView *scrollView) {
    NSArray<NSIndexPath *> *_Nullable visibleIndexPaths = [scrollView sj_visibleIndexPaths];
    if ( visibleIndexPaths.count < 1 )
        return;
 
    SJPlayerAutoplayConfig *config = [scrollView sj_autoplayConfig];
    NSIndexPath *_Nullable current = [scrollView sj_currentPlayingIndexPath];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSInteger superviewTag = config.playerSuperviewTag;
#pragma clang diagnostic pop
    
    if ( superviewTag != 0 && [scrollView isViewAppearedWithTag:superviewTag insets:config.playableAreaInsets atIndexPath:current] )
        return;
    else if ( [scrollView isViewAppearedWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:0 insets:config.playableAreaInsets atIndexPath:current] )
        return;
    
    NSIndexPath *_Nullable next = nil;
    switch ( config.autoplayPosition ) {
        case SJAutoplayPositionTop: {
            for ( NSIndexPath *indexPath in visibleIndexPaths ) {
                UIView *_Nullable target = superviewTag != 0 ?
                                    [scrollView viewWithTag:superviewTag atIndexPath:indexPath] :
                [scrollView viewWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:0 atIndexPath:indexPath];
                if ( !target ) continue;
                CGRect intersection = [scrollView intersectionWithView:target insets:config.playableAreaInsets];
                if ( floor(intersection.size.height) >= floor(target.bounds.size.height) ) {
                    next = indexPath;
                    break;
                }
            }
        }
            break;
        case SJAutoplayPositionMiddle: {
            // 中线, 距离中心最近的那个玩意儿
            CGFloat mid = 0;
            {
                CGFloat offset = 0;
                if (@available(iOS 11.0, *))
                    mid = floor((CGRectGetHeight(scrollView.bounds) - scrollView.adjustedContentInset.top) * 0.5 + offset);
                else
                    mid = floor((CGRectGetHeight(scrollView.bounds) - scrollView.contentInset.top) * 0.5 + offset);
                
                if ( mid < 1 )
                    return;
            }
            
            NSInteger count = visibleIndexPaths.count;
            CGFloat sub = CGFLOAT_MAX;
            for ( NSInteger i = 0 ; i < count ; ++ i ) {
                NSIndexPath *indexPath = visibleIndexPaths[i];
                UIView *_Nullable target = superviewTag != 0 ?
                                    [scrollView viewWithTag:superviewTag atIndexPath:indexPath] :
                                    [scrollView viewWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:0 atIndexPath:indexPath];
                if ( !target ) continue;
                CGRect intersection = [scrollView intersectionWithView:target insets:config.playableAreaInsets];
                CGFloat result = floor(ABS(mid - CGRectGetMidY(intersection)));
                if ( result < sub ) {
                    sub = result;
                    next = indexPath;
                }
            }
        }
            break;
    }
    
    if ( next )
        sj_playAsset(scrollView, next, NO);
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

static void sj_playNextVisibleAsset(__kindof UIScrollView *scrollView) {
    NSArray<NSIndexPath *> *_Nullable visibleIndexPaths = [scrollView sj_visibleIndexPaths];
    if ( visibleIndexPaths.count < 1 )
        return;
    
    NSArray<NSIndexPath *> *_Nullable remain = nil;
    NSIndexPath *_Nullable current = [scrollView sj_currentPlayingIndexPath];
    {
        NSInteger idx = NSNotFound;
        if ( !current || (idx = [visibleIndexPaths indexOfObject:current]) == NSNotFound ) {
            remain = visibleIndexPaths;
        }
        else if ( ++idx < visibleIndexPaths.count ) {
            remain = [visibleIndexPaths subarrayWithRange:NSMakeRange(idx, visibleIndexPaths.count - idx)];
        }
        
        if ( remain.count < 1 )
            return;
    }
    
    SJPlayerAutoplayConfig *config = [scrollView sj_autoplayConfig];
    NSIndexPath *_Nullable next = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSInteger superviewTag = config.playerSuperviewTag;
#pragma clang diagnostic pop
    for ( NSIndexPath *indexPath in remain ) {
        UIView *_Nullable target = superviewTag != 0 ?
                            [scrollView viewWithTag:superviewTag atIndexPath:indexPath] :
                            [scrollView viewWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:0 atIndexPath:indexPath];
        if ( !target ) continue;
        CGRect intersection = [scrollView intersectionWithView:target insets:config.playableAreaInsets];
        if ( floor(intersection.size.height) >= floor(target.bounds.size.height) ) {
            next = indexPath;
            break;
        }
    }
    
    if ( next )
        sj_playAsset(scrollView, next, current != nil);
}

static void sj_playAsset(UIScrollView *scrollView, NSIndexPath *indexPath, BOOL animated) {
    [[scrollView sj_autoplayConfig].autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:indexPath];
    if ( animated ) sj_exeAnima(scrollView, indexPath, [scrollView sj_autoplayConfig].animationType);
}


@implementation UIScrollView (SJAutoplayDeprecated)
- (void)sj_needPlayNextAsset __deprecated_msg("use `sj_playNextVisibleAsset`") {
    [self sj_playNextVisibleAsset];
}
@end
NS_ASSUME_NONNULL_END
