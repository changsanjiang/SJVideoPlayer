//
//  SJPlayModelPropertiesObserver.m
//  SJVideoPlayerAssetCarrier
//
//  Created by 畅三江 on 2018/6/29.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "SJPlayModelPropertiesObserver.h"
#import "UIView+SJBaseVideoPlayerExtended.h"
#import "SJPlayModel+SJPrivate.h"
#import <objc/message.h>

#if __has_include(<SJUIKit/SJRunLoopTaskQueue.h>)
#import <SJUIKit/SJRunLoopTaskQueue.h>
#else
#import "SJRunLoopTaskQueue.h"
#endif

#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJPlayModelPropertiesObserver()
@property (nonatomic, strong, readonly) __kindof SJPlayModel *playModel;
@property (nonatomic) CGPoint beforeOffset;
@property (nonatomic) BOOL isAppeared;
@property (nonatomic, strong, readonly) SJRunLoopTaskQueue *taskQueue;
@property (nonatomic) BOOL isScrolling;
@end

@implementation SJPlayModelPropertiesObserver

- (instancetype)initWithPlayModel:(__kindof SJPlayModel *)playModel {
    NSParameterAssert(playModel);
    
    self = [super init];
    if ( !self ) return nil;
    _playModel = playModel;
    _taskQueue = SJRunLoopTaskQueue.queue(@"SJPlayModelObserverRunLoopTaskQueue").delay(3);
    _beforeOffset = CGPointMake(-1, -1);
    if ( [playModel isMemberOfClass:[SJPlayModel class]] ) {
        _isAppeared = YES;
    }
    else {
        [self _observeProperties];
    }
    
    [self refreshAppearState];
    
    return self;
}

- (void)_observeProperties {
    if ( [_playModel isKindOfClass:SJScrollViewPlayModel.class] ||
         [_playModel isKindOfClass:SJCollectionViewCellPlayModel.class] ||
         [_playModel isKindOfClass:SJCollectionViewSectionHeaderViewPlayModel.class] ||
         [_playModel isKindOfClass:SJCollectionViewSectionFooterViewPlayModel.class] ||
         [_playModel isKindOfClass:SJTableViewCellPlayModel.class]  ||
         [_playModel isKindOfClass:SJTableViewSectionHeaderViewPlayModel.class]  ||
         [_playModel isKindOfClass:SJTableViewSectionFooterViewPlayModel.class]  ||
         [_playModel isKindOfClass:SJTableViewTableHeaderViewPlayModel.class]  ||
         [_playModel isKindOfClass:SJTableViewTableFooterViewPlayModel.class]  ) {
        
        SJPlayModel *curr = _playModel;
        _beforeOffset = curr.inScrollView.contentOffset;
        while ( curr != nil ) {
            [self _observeScrollView:curr.inScrollView];
            curr = curr.nextPlayModel;
        }
    }
    // 以下已弃用, 未来可能会删除
    else if ( [_playModel isKindOfClass:[SJUITableViewCellPlayModel class]] ) {
        SJUITableViewCellPlayModel *playModel = _playModel;
        [self _observeScrollView:playModel.tableView];
    }
    else if ( [_playModel isKindOfClass:[SJUICollectionViewCellPlayModel class]] ) {
        SJUICollectionViewCellPlayModel *playModel = _playModel;
        [self _observeScrollView:playModel.collectionView];
    }
    else if ( [_playModel isKindOfClass:[SJUITableViewHeaderViewPlayModel class]] ) {
        SJUITableViewHeaderViewPlayModel *playModel = _playModel;
        [self _observeScrollView:playModel.tableView];
    }
    else if ( [_playModel isKindOfClass:[SJUICollectionViewNestedInUITableViewHeaderViewPlayModel class]] ) {
        SJUICollectionViewNestedInUITableViewHeaderViewPlayModel *playModel = _playModel;
        [self _observeScrollView:playModel.collectionView];
        [self _observeScrollView:playModel.tableView];
    }
    else if ( [_playModel isKindOfClass:[SJUICollectionViewNestedInUITableViewCellPlayModel class]] ) {
        SJUICollectionViewNestedInUITableViewCellPlayModel *playModel = _playModel;
        [self _observeScrollView:playModel.collectionView];
        [self _observeScrollView:playModel.tableView];
    }
    else if ( [_playModel isKindOfClass:[SJUICollectionViewNestedInUICollectionViewCellPlayModel class]] ) {
        SJUICollectionViewNestedInUICollectionViewCellPlayModel *playModel = _playModel;
        [self _observeScrollView:playModel.collectionView];
        [self _observeScrollView:playModel.rootCollectionView];
    }
    else if ( [_playModel isKindOfClass:[SJUITableViewHeaderFooterViewPlayModel class]] ) {
        SJUITableViewHeaderFooterViewPlayModel *playModel = _playModel;
        [self _observeScrollView:playModel.tableView];
    }
}

static NSString *kContentOffset = @"contentOffset";
static NSString *kState = @"state";
- (void)_observeScrollView:(UIScrollView *)scrollView {
    if ( !scrollView ) return;
    if ( ![scrollView isKindOfClass:[UIScrollView class]] ) return;
    [scrollView sj_addObserver:self forKeyPath:kContentOffset context:&kContentOffset];
    [scrollView.panGestureRecognizer sj_addObserver:self forKeyPath:kState context:&kState];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(nullable void *)context {
    if ( &kContentOffset == context ) {
        __weak typeof(self) _self = self;
        _taskQueue.empty().enqueue(^{
            [_self _scrollViewDidScroll:object];
        });
    }
    else if ( &kState == context ) {
        [self _panGestureStateDidChange:object];
    }
}

- (void)_panGestureStateDidChange:(UIPanGestureRecognizer *)pan {
    if ( !pan ) return;
    UIGestureRecognizerState state = pan.state;
    switch ( state ) {
        case UIGestureRecognizerStateChanged: return;
        case UIGestureRecognizerStatePossible: return;
        case UIGestureRecognizerStateBegan: {
            _isTouched = YES;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled: {
            _isTouched = NO;
        }
            break;
    }
}

- (BOOL)_isAppearedInTheScrollingView:(UIScrollView *)scrollView {
    return [scrollView isViewAppeared:_playModel.playerSuperview insets:_playModel.playableAreaInsets];
}

- (void)_scrollViewDidScroll:(UIScrollView *)scrollView {
    if ( !scrollView ) return;
    if ( CGPointEqualToPoint(_beforeOffset, scrollView.contentOffset) ) return;
    
    if ( _playModel.nextPlayModel != nil ) {
        SJPlayModel *curr = _playModel.nextPlayModel;
        while ( curr != nil ) {
            [self _observeScrollView:curr.inScrollView];
            curr = curr.nextPlayModel;
        }
    }
    // 以下已弃用, 未来可能会删除
    ///
    /// Thanks @loveuqian
    /// https://github.com/changsanjiang/SJVideoPlayer/issues/62
    ///
    else if ( [_playModel isKindOfClass:[SJUICollectionViewNestedInUITableViewCellPlayModel class]] ) {
        SJUICollectionViewNestedInUITableViewCellPlayModel *playModel = _playModel;
        if ( scrollView == playModel.tableView ) {
            [self _observeScrollView:playModel.collectionView];
        }
    }
    else if ( [_playModel isKindOfClass:[SJUICollectionViewNestedInUICollectionViewCellPlayModel class]] ) {
        SJUICollectionViewNestedInUICollectionViewCellPlayModel *playModel = _playModel;
        if ( scrollView == playModel.rootCollectionView ) {
            [self _observeScrollView:playModel.collectionView];
        }
    }
    
    self.isAppeared = [self _isAppearedInTheScrollingView:scrollView];
    _beforeOffset = scrollView.contentOffset;
}

@synthesize isAppeared = _isAppeared;
- (void)setIsAppeared:(BOOL)isAppeared {
    if ( isAppeared == _isAppeared ) return;
    _isAppeared = isAppeared;
    if ( isAppeared ) {
        if ( [self.delegate respondsToSelector:@selector(playerWillAppearForObserver:superview:)] ) {
            [self.delegate playerWillAppearForObserver:self superview:_playModel.playerSuperview];
        }
    }
    else {
        if ( [self.delegate respondsToSelector:@selector(playerWillDisappearForObserver:)] ) {
            [self.delegate playerWillDisappearForObserver:self];
        }
    }
}

- (BOOL)isPlayInScrollView {
    return _playModel.isPlayInScrollView;
}

- (void)refreshAppearState {
    _isAppeared = NO;
    if ( [_playModel isMemberOfClass:[SJPlayModel class]] ) {
        self.isAppeared = YES;
        return;
    }
    
    UIScrollView *superview = _playModel.inScrollView;
    if ( !superview ) {
        self.isAppeared = NO;
        return;
    }
    self.isAppeared = [self _isAppearedInTheScrollingView:superview];
}

- (BOOL)isScrolling {
    if ( [_playModel isKindOfClass:SJScrollViewPlayModel.class] ||
         [_playModel isKindOfClass:SJCollectionViewCellPlayModel.class] ||
         [_playModel isKindOfClass:SJCollectionViewSectionHeaderViewPlayModel.class] ||
         [_playModel isKindOfClass:SJCollectionViewSectionFooterViewPlayModel.class] ||
         [_playModel isKindOfClass:SJTableViewCellPlayModel.class]  ||
         [_playModel isKindOfClass:SJTableViewSectionHeaderViewPlayModel.class]  ||
         [_playModel isKindOfClass:SJTableViewSectionFooterViewPlayModel.class]  ||
         [_playModel isKindOfClass:SJTableViewTableHeaderViewPlayModel.class]  ||
         [_playModel isKindOfClass:SJTableViewTableFooterViewPlayModel.class]  ) {
        SJPlayModel *curr = _playModel;
        while ( curr != nil ) {
            if ( curr.inScrollView.isDragging || curr.inScrollView.isDecelerating )
                return YES;
            curr = curr.nextPlayModel;
        }
    }
    // 以下已弃用, 未来可能会删除
    else if ( [_playModel isKindOfClass:[SJUITableViewCellPlayModel class]] ) {
        SJUITableViewCellPlayModel *playModel = _playModel;
        return playModel.tableView.isDragging || playModel.tableView.isDecelerating;
    }
    else if ( [_playModel isKindOfClass:[SJUICollectionViewCellPlayModel class]] ) {
        SJUICollectionViewCellPlayModel *playModel = _playModel;
        return playModel.collectionView.isDragging || playModel.collectionView.isDecelerating;
    }
    else if ( [_playModel isKindOfClass:[SJUITableViewHeaderViewPlayModel class]] ) {
        SJUITableViewHeaderViewPlayModel *playModel = _playModel;
        return playModel.tableView.isDragging || playModel.tableView.isDecelerating;
    }
    else if ( [_playModel isKindOfClass:[SJUICollectionViewNestedInUITableViewHeaderViewPlayModel class]] ) {
        SJUICollectionViewNestedInUITableViewHeaderViewPlayModel *playModel = _playModel;
        return playModel.collectionView.isDragging || playModel.collectionView.isDecelerating ||
        playModel.tableView.isDragging || playModel.tableView.isDecelerating;
    }
    else if ( [_playModel isKindOfClass:[SJUICollectionViewNestedInUITableViewCellPlayModel class]] ) {
        SJUICollectionViewNestedInUITableViewCellPlayModel *playModel = _playModel;
        return playModel.collectionView.isDragging || playModel.collectionView.isDecelerating ||
        playModel.tableView.isDragging || playModel.tableView.isDecelerating;
    }
    else if ( [_playModel isKindOfClass:[SJUICollectionViewNestedInUICollectionViewCellPlayModel class]] ) {
        SJUICollectionViewNestedInUICollectionViewCellPlayModel *playModel = _playModel;
        return playModel.collectionView.isDragging || playModel.collectionView.isDecelerating ||
        playModel.rootCollectionView.isDragging || playModel.rootCollectionView.isDecelerating;
    }
    else if ( [_playModel isKindOfClass:[SJUITableViewHeaderFooterViewPlayModel class]] ) {
        SJUITableViewHeaderFooterViewPlayModel *playModel = _playModel;
        return playModel.tableView.isDragging || playModel.tableView.isDecelerating;
    }
    return NO;
}
@end
NS_ASSUME_NONNULL_END
