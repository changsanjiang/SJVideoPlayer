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

@interface UIScrollView (SJAutoplayInternal)
@property (nonatomic, strong, nullable) SJPlayerAutoplayConfig *sj_autoplayConfig;
@property (nonatomic, readonly) BOOL sj_isScrolledToTop;
@property (nonatomic, readonly) BOOL sj_isScrolledToLeft;
@property (nonatomic, readonly) BOOL sj_isScrolledToBottom;
@property (nonatomic, readonly) BOOL sj_isScrolledToRight;
- (BOOL)sj_isAutoplayTargetViewAppearedForConfiguration:(SJPlayerAutoplayConfig *)config atIndexPath:(NSIndexPath *)indexPath;
- (nullable UIView *)sj_autoplayTargetViewForConfiguration:(SJPlayerAutoplayConfig *)config atIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)sj_autoplayGuidelineForConfiguration:(SJPlayerAutoplayConfig *)config;
- (UIEdgeInsets)sj_autoplayPlayableAreaInsetsForConfiguration:(SJPlayerAutoplayConfig *)config;
- (NSArray<NSIndexPath *> *_Nullable)sj_sortedVisibleIndexPaths;
@end


static NSString *const kQueue = @"SJBaseVideoPlayerAutoplayTaskQueue";
static SJRunLoopTaskQueue *
sj_queue(void) {
    static SJRunLoopTaskQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = SJRunLoopTaskQueue.queue(kQueue).update(CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    });
    return queue;
}

static void sj_playNextAssetAfterEndScroll(__kindof UIScrollView *scrollView);
static void sj_scrollViewContentOffsetDidChange(UIScrollView *scrollView, void(^contentOffsetDidChangeExeBlock)(void));
static void sj_removeContentOffsetObserver(UIScrollView *scrollView);

@implementation UIScrollView (ListViewAutoplaySJAdd)
- (void)setSj_enabledAutoplay:(BOOL)sj_enabledAutoplay {
    objc_setAssociatedObject(self, @selector(sj_enabledAutoplay), @(sj_enabledAutoplay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)sj_enabledAutoplay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
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

- (void)sj_disableAutoplay {
    self.sj_enabledAutoplay = NO;
    self.sj_autoplayConfig = nil;
    self.sj_currentPlayingIndexPath = nil;
    sj_removeContentOffsetObserver(self);
}
 
- (void)sj_removeCurrentPlayerView {
    self.sj_currentPlayingIndexPath = nil;
    [[self viewWithTag:SJPlayerViewTag] removeFromSuperview];
}

- (void)sj_playNextAssetAfterEndScroll {
    self.sj_hasDelayedEndScrollTask = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        sj_playNextAssetAfterEndScroll(self);
    });
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

static void sj_playNextAssetAfterEndScroll(__kindof __kindof UIScrollView *self) {
    if ( self.window == nil ) {
        return;
    }
    
    NSArray<NSIndexPath *> *_Nullable sortedVisibleIndexPaths = [self sj_sortedVisibleIndexPaths];
    if ( sortedVisibleIndexPaths.count < 1 )
        return;
    
    SJPlayerAutoplayConfig *config = [self sj_autoplayConfig];
    NSIndexPath *_Nullable current = [self sj_currentPlayingIndexPath];

    UICollectionViewScrollDirection scrollDirection = config.scrollDirection;
    switch ( scrollDirection ) {
        case UICollectionViewScrollDirectionVertical:
            if ( !self.sj_isScrolledToTop && !self.sj_isScrolledToBottom &&
                 [self sj_isAutoplayTargetViewAppearedForConfiguration:config atIndexPath:current] )
                return;
            break;
        case UICollectionViewScrollDirectionHorizontal:
            if ( !self.sj_isScrolledToLeft && !self.sj_isScrolledToRight &&
                 [self sj_isAutoplayTargetViewAppearedForConfiguration:config atIndexPath:current] )
                return;
            break;
    }
    
    NSIndexPath *_Nullable next = nil;
    // 参考线
    // 距离参考线最近的视频将会被播放
    CGFloat guideline = [self sj_autoplayGuidelineForConfiguration:config];
    
    if ( guideline < 0 )
        return;
    
    NSInteger count = sortedVisibleIndexPaths.count;
    CGFloat subs = CGFLOAT_MAX;
    for ( NSInteger i = 0 ; i < count ; ++ i ) {
        NSIndexPath *indexPath = sortedVisibleIndexPaths[i];
        UIView *_Nullable target = [self sj_autoplayTargetViewForConfiguration:config atIndexPath:indexPath];
        if ( !target ) continue;
        UIEdgeInsets playableAreaInsets = [self sj_autoplayPlayableAreaInsetsForConfiguration:config];
        CGRect intersection = [self intersectionWithView:target insets:playableAreaInsets];
        CGFloat result = CGFLOAT_MAX;
        switch ( scrollDirection ) {
            case UICollectionViewScrollDirectionVertical:
                if ( intersection.size.height != 0 ) result = floor(ABS(guideline - CGRectGetMidY(intersection)));
                break;
            case UICollectionViewScrollDirectionHorizontal:
                if ( intersection.size.width != 0 ) result = floor(ABS(guideline - CGRectGetMidX(intersection)));
                break;
        }
        
        if ( result < subs ) {
            subs = result;
            next = indexPath;
        }
    }
    
    if ( next != nil && ![next isEqual:current] ) [config.autoplayDelegate sj_playerNeedPlayNewAssetAtIndexPath:next];
}


@implementation UIScrollView (SJAutoplayInternal)

- (BOOL)sj_isScrolledToTop {
    return floor(self.contentOffset.y) == 0;
}

- (BOOL)sj_isScrolledToLeft {
    return floor(self.contentOffset.x) == 0;
}

- (BOOL)sj_isScrolledToRight {
    return floor(self.contentOffset.x + self.bounds.size.width) == floor(self.contentSize.width);
}

- (BOOL)sj_isScrolledToBottom {
    return floor(self.contentOffset.y + self.bounds.size.height) == floor(self.contentSize.height);
}

- (BOOL)sj_isAutoplayTargetViewAppearedForConfiguration:(SJPlayerAutoplayConfig *)config atIndexPath:(NSIndexPath *)indexPath {
    SEL playerSuperviewSelector = config.playerSuperviewSelector;
    if ( playerSuperviewSelector != NULL )
        return [self isViewAppearedForSelector:playerSuperviewSelector insets:config.playableAreaInsets atIndexPath:indexPath];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSInteger superviewTag = config.playerSuperviewTag;
#pragma clang diagnostic pop
    if ( superviewTag != 0 )
        return [self isViewAppearedWithTag:superviewTag insets:config.playableAreaInsets atIndexPath:indexPath];
    
    return [self isViewAppearedWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:0 insets:config.playableAreaInsets atIndexPath:indexPath];
}

- (nullable UIView *)sj_autoplayTargetViewForConfiguration:(SJPlayerAutoplayConfig *)config atIndexPath:(NSIndexPath *)indexPath {
    SEL playerSuperviewSelector = config.playerSuperviewSelector;
    if ( playerSuperviewSelector != NULL ) {
        return [self viewForSelector:playerSuperviewSelector atIndexPath:indexPath];
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSInteger superviewTag = config.playerSuperviewTag;
#pragma clang diagnostic pop
        return superviewTag != 0 ?
                 [self viewWithTag:superviewTag atIndexPath:indexPath] :
                 [self viewWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:0 atIndexPath:indexPath];
    }
}

- (CGFloat)sj_autoplayGuidelineForConfiguration:(SJPlayerAutoplayConfig *)config {
    CGFloat guideline = 0;
    switch ( config.scrollDirection ) {
        case UICollectionViewScrollDirectionVertical: {
            if      ( self.sj_isScrolledToTop ) {
                // nothing
            }
            else if ( self.sj_isScrolledToBottom ) {
                guideline = self.contentSize.height;
            }
            else {
                if (@available(iOS 11.0, *))
                    guideline = floor((CGRectGetHeight(self.bounds) - self.adjustedContentInset.top) * 0.5);
                else
                    guideline = floor((CGRectGetHeight(self.bounds) - self.contentInset.top) * 0.5);
            }
        }
            break;
        case UICollectionViewScrollDirectionHorizontal: {
            if      ( self.sj_isScrolledToLeft ) {
                // nothing
            }
            else if ( self.sj_isScrolledToBottom ) {
                guideline = self.contentSize.width;
            }
            else {
                if (@available(iOS 11.0, *))
                    guideline = floor((CGRectGetWidth(self.bounds) - self.adjustedContentInset.left) * 0.5);
                else
                    guideline = floor((CGRectGetWidth(self.bounds) - self.contentInset.left) * 0.5);
            }
        }
            break;
    }
    return guideline;
}

- (UIEdgeInsets)sj_autoplayPlayableAreaInsetsForConfiguration:(SJPlayerAutoplayConfig *)config {
    UIEdgeInsets insets = config.playableAreaInsets;
    switch ( config.scrollDirection ) {
        case UICollectionViewScrollDirectionVertical:
            if ( self.sj_isScrolledToTop ) insets.top = 0;
            else if ( self.sj_isScrolledToBottom ) insets.bottom = 0;
            break;
        case UICollectionViewScrollDirectionHorizontal:
            if ( self.sj_isScrolledToLeft ) insets.left = 0;
            else if ( self.sj_isScrolledToRight ) insets.right = 0;
            break;
    }
    return insets;
}

- (void)setSj_autoplayConfig:(nullable SJPlayerAutoplayConfig *)sj_autoplayConfig {
    objc_setAssociatedObject(self, @selector(sj_autoplayConfig), sj_autoplayConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable SJPlayerAutoplayConfig *)sj_autoplayConfig {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSArray<NSIndexPath *> *_Nullable)sj_sortedVisibleIndexPaths {
    NSArray<NSIndexPath *> *_Nullable visibleIndexPaths = nil;
    if ( [self isKindOfClass:[UITableView class]] )
        visibleIndexPaths = [(UITableView *)self indexPathsForVisibleRows];
    else if ( [self isKindOfClass:[UICollectionView class]] )
        visibleIndexPaths = [[(UICollectionView *)self indexPathsForVisibleItems] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
    return visibleIndexPaths;
}
@end

@implementation UIScrollView (SJAutoplayPlayerAssigns)
- (void)setSj_currentPlayingIndexPath:(nullable NSIndexPath *)sj_currentPlayingIndexPath {
    objc_setAssociatedObject(self, @selector(sj_currentPlayingIndexPath), sj_currentPlayingIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable NSIndexPath *)sj_currentPlayingIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}

@end
