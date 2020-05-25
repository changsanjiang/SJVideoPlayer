//
//  SJPresentationQueue.m
//  Pods
//
//  Created by BlueDancer on 2020/5/8.
//

#import "SJPresentationQueue.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIView (SJPresentationQueueExtended)
@property (nonatomic, strong, readonly) NSMutableArray<UIView<SJPresentViewProtocol> *> *sjpq_waitingViews;
@property (nonatomic, strong, nullable) UIView<SJPresentViewProtocol> *sjpq_currentPresentView;
@end

@implementation UIView (SJPresentationQueueExtended)
- (NSMutableArray<UIView<SJPresentViewProtocol> *> *)sjpq_waitingViews {
    NSMutableArray *m = objc_getAssociatedObject(self, _cmd);
    if ( m == nil ) {
        m = NSMutableArray.array;
        objc_setAssociatedObject(self, _cmd, m, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return m;
}

- (void)setSjpq_currentPresentView:(nullable UIView<SJPresentViewProtocol> *)sjpq_currentPresentView {
    objc_setAssociatedObject(self, @selector(sjpq_currentPresentView), sjpq_currentPresentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable UIView<SJPresentViewProtocol> *)sjpq_currentPresentView {
    return objc_getAssociatedObject(self, _cmd);
}
@end

@implementation SJPresentationQueue
+ (instancetype)shared {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = SJPresentationQueue.new;
    });
    return instance;
}

+ (void)enqueueToPresent:(UIView<SJPresentViewProtocol> *)presentView sourceView:(UIView *)sourceView {
    [SJPresentationQueue.shared _enqueueToPresent:presentView sourceView:sourceView];
}

- (void)_enqueueToPresent:(UIView<SJPresentViewProtocol> *)presentView sourceView:(UIView *)sourceView {
    if ( sourceView.sjpq_currentPresentView == nil ) {
        [self _present:presentView showInSourceView:sourceView];
    }
    else {
        if ( presentView.priority == SJPresentationPriorityDroppable )
            return; // 抛弃此次任务
        
        [sourceView.sjpq_waitingViews addObject:presentView];
        [sourceView.sjpq_waitingViews sortUsingComparator:^NSComparisonResult(UIView<SJPresentViewProtocol> *view1, UIView<SJPresentViewProtocol> *view2) {
            if      ( view1.priority > view2.priority ) return NSOrderedAscending;
            else if ( view1.priority < view2.priority ) return NSOrderedDescending;
            return NSOrderedSame;
        }];
    }
}

- (void)_present:(nullable UIView<SJPresentViewProtocol> *)presentView showInSourceView:(nullable UIView *)sourceView {
    if ( presentView == nil ) return;
    if ( sourceView == nil ) return;
    sourceView.sjpq_currentPresentView = presentView;
    __weak typeof(sourceView) _sourceView = sourceView;
    [presentView showInSourceView:sourceView dismissedCallback:^{
        __strong typeof(_sourceView) sourceView = _sourceView;
        if ( !sourceView ) return;
        sourceView.sjpq_currentPresentView = nil;
        [self _present:[self _nextViewToPresentOfSourceView:sourceView] showInSourceView:sourceView];
    }];
}

- (nullable UIView<SJPresentViewProtocol> *)_nextViewToPresentOfSourceView:(UIView *)sourceView {
    __auto_type last = sourceView.sjpq_waitingViews.lastObject;
    [sourceView.sjpq_waitingViews removeLastObject];
    return last;
}
@end
NS_ASSUME_NONNULL_END
