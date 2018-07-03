//
//  SJPlayModelPropertiesObserver.m
//  SJVideoPlayerAssetCarrier
//
//  Created by 畅三江 on 2018/6/29.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJPlayModelPropertiesObserver.h"
#import <SJObserverHelper/NSObject+SJObserverHelper.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJPlayModelPropertiesObserver()
@property (nonatomic, strong, readonly) id<SJPlayModel> playModel;
@property (nonatomic) CGPoint beforeOffset;
@property (nonatomic) BOOL isAppeared;
@end

@implementation SJPlayModelPropertiesObserver

- (instancetype)initWithPlayModel:(__kindof SJPlayModel *)playModel {
    NSParameterAssert(playModel);
    
    self = [super init];
    if ( !self ) return nil;
    _playModel = playModel;
    _isAppeared = YES;
    if ( playModel && ![playModel isMemberOfClass:[SJPlayModel class]] ) {
        [self _observePlayModelProperties];
    }
    return self;
}

- (void)_observePlayModelProperties {
    if ( [_playModel isKindOfClass:[SJUITableViewCellPlayModel class]] ) {
        SJUITableViewCellPlayModel *playModel = _playModel;
        [self _observeScrollView:playModel.tableView];
        _beforeOffset = playModel.tableView.contentOffset;
    }
    else if ( [_playModel isKindOfClass:[SJUICollectionViewCellPlayModel class]] ) {
        SJUICollectionViewCellPlayModel *playModel = _playModel;
        [self _observeScrollView:playModel.collectionView];
        _beforeOffset = playModel.collectionView.contentOffset;
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
        [self _observeScrollView:[[playModel.tableView cellForRowAtIndexPath:playModel.collectionViewAtIndexPath] viewWithTag:playModel.collectionViewTag]];
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
        [self _scrollViewDidScroll:object];
    }
    else if ( &kState == context ) {
        [self _panGestureStateDidChange:object];
    }
}

- (void)_panGestureStateDidChange:(UIPanGestureRecognizer *)pan {
    if ( !pan ) return;
    UIGestureRecognizerState state = pan.state;
    BOOL isTableView = NO;
    BOOL isCollectionView = NO;
    switch ( state ) {
        case UIGestureRecognizerStateChanged: return;
        case UIGestureRecognizerStatePossible: return;
        case UIGestureRecognizerStateBegan: {
            if ( [pan.view isKindOfClass:[UITableView class]] ) {
                _isTouchedTablView = YES;
                isTableView = YES;
            }
            else if ( [pan.view isKindOfClass:[UICollectionView class]] ) {
                _isTouchedCollectionView = YES;
                isCollectionView = YES;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled: {
            if ( [pan.view isKindOfClass:[UITableView class]] ) {
                _isTouchedTablView = NO;
                isTableView = YES;
            }
            else if ( [pan.view isKindOfClass:[UICollectionView class]] ) {
                _isTouchedCollectionView = NO;
                isCollectionView = YES;
            }
        }
            break;
    }
    
    if ( isTableView ) {
        if ( [self.delegate respondsToSelector:@selector(observer:userTouchedTableView:)] ) {
            [self.delegate observer:self userTouchedTableView:_isTouchedTablView];
        }
    }
    else if ( isCollectionView ) {
        if ( [self.delegate respondsToSelector:@selector(observer:userTouchedCollectionView:)] ) {
            [self.delegate observer:self userTouchedCollectionView:_isTouchedCollectionView];
        }
    }
}

/// 某个视图是否在tableView中显示
- (BOOL)_isAppearedWithViewTag:(NSInteger)viewTag
        tableViewCellIndexPath:(NSIndexPath *)tableViewCellIndexPath
                     tableView:(UITableView *)tableView
                  beforeOffest:(CGPoint)beforeOffset {
    if ( ![tableView.indexPathsForVisibleRows containsObject:tableViewCellIndexPath] ) return NO;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:tableViewCellIndexPath];
    UIView *target = [cell viewWithTag:viewTag];
    CGRect rect = [target.superview convertRect:target.frame toView:tableView.superview];
    CGRect inset = CGRectIntersection(rect, tableView.frame);
    return !CGRectIsNull(inset);
}
/// 某个视图是否在tableHeaderView中显示
- (BOOL)_isAppearedWithTableHeaderChildView:(UIView *)tableHeaderChildView
                                  tableView:(UITableView *)tableView {
    CGFloat offsetY = tableView.contentOffset.y;
    if ( offsetY > tableView.tableHeaderView.frame.size.height ) return NO;
    
    CGRect rect = CGRectZero;
    if ( tableHeaderChildView.superview == tableView.tableHeaderView ) {
        rect = tableHeaderChildView.frame;
    }
    else rect = [tableView.tableHeaderView convertRect:tableHeaderChildView.frame fromView:tableHeaderChildView.superview];
    
    return offsetY <= CGRectGetMaxY(rect);
}

/// 某个视图是否在collectionView中显示
- (BOOL)_isAppearedWithViewTag:(NSInteger)viewTag
   collectionViewCellIndexPath:(NSIndexPath *)collectionViewCellIndexPath
                collectionView:(UICollectionView *)collectionView
                  beforeOffset:(CGPoint)beforeOffset {
    if ( ![collectionView.indexPathsForVisibleItems containsObject:collectionViewCellIndexPath] ) return NO;
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:collectionViewCellIndexPath];
    UIView *view = [cell viewWithTag:viewTag];
    CGRect rect = [view.superview convertRect:view.frame toView:collectionView.superview];
    CGRect inset = CGRectIntersection(rect, collectionView.frame);
    return !CGRectIsNull(inset);
}

/// 某个视图是否在tableView中显示
- (BOOL)_isAppearedWithViewTag:(NSInteger)viewTag
   collectionViewCellIndexPath:(NSIndexPath *)collectionViewCellIndexPath
                collectionView:(UICollectionView *)collectionView
                     tableView:(UITableView *)tableView
                  beforeOffset:(CGPoint)beforeOffset {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:collectionViewCellIndexPath];
    UIView *view = [cell viewWithTag:viewTag];
    CGRect rect = [view.superview convertRect:view.frame toView:tableView];
    return tableView.contentOffset.y <= CGRectGetMaxY(rect);
}

- (void)_scrollViewDidScroll:(UIScrollView *)scrollView {
    if ( !scrollView ) return;
    if ( CGPointEqualToPoint(_beforeOffset, scrollView.contentOffset) ) return;
 
    if ( [_playModel isKindOfClass:[SJUITableViewCellPlayModel class]] ) {
        SJUITableViewCellPlayModel *playModel = _playModel;
        self.isAppeared = [self _isAppearedWithViewTag:playModel.playerSuperviewTag
                                tableViewCellIndexPath:playModel.indexPath
                                             tableView:playModel.tableView
                                          beforeOffest:_beforeOffset];
    }
    else if ( [_playModel isKindOfClass:[SJUITableViewHeaderViewPlayModel class]] ) {
        SJUITableViewHeaderViewPlayModel *playModel = _playModel;
        self.isAppeared = [self _isAppearedWithTableHeaderChildView:playModel.playerSuperview
                                                          tableView:playModel.tableView];
    }
    else if ( [_playModel isKindOfClass:[SJUICollectionViewCellPlayModel class]] ) {
        SJUICollectionViewCellPlayModel *playModel = _playModel;
        self.isAppeared = [self _isAppearedWithViewTag:playModel.playerSuperviewTag
                           collectionViewCellIndexPath:playModel.indexPath
                                        collectionView:playModel.collectionView
                                          beforeOffset:_beforeOffset];
    }
    else if ( [_playModel isKindOfClass:[SJUICollectionViewNestedInUITableViewHeaderViewPlayModel class]] ) {
        SJUICollectionViewNestedInUITableViewHeaderViewPlayModel *playModel = _playModel;
        if ( scrollView == playModel.collectionView ) {
            // 确定cell是否显示
            self.isAppeared = [self _isAppearedWithViewTag:playModel.playerSuperviewTag
                               collectionViewCellIndexPath:playModel.indexPath
                                            collectionView:playModel.collectionView
                                              beforeOffset:_beforeOffset];
        }
        else {
            // 确定collectionView是否显示
            BOOL isAppeard_parentView = [self _isAppearedWithTableHeaderChildView:playModel.collectionView
                                                                        tableView:playModel.tableView];
            if ( !isAppeard_parentView ) {
                self.isAppeared = NO;
                return;
            }
            
            // 确定父视图是否显示在cell中显示
            BOOL isAppeared_cell = [self _isAppearedWithViewTag:playModel.playerSuperviewTag
                                    collectionViewCellIndexPath:playModel.indexPath
                                                 collectionView:playModel.collectionView
                                                   beforeOffset:_beforeOffset];
            if ( !isAppeared_cell ) {
                self.isAppeared = NO;
                return;
            }
            
            // 确定父视图是否在tableview中显示
            self.isAppeared = [self _isAppearedWithViewTag:playModel.playerSuperviewTag
                               collectionViewCellIndexPath:playModel.indexPath
                                            collectionView:playModel.collectionView
                                                 tableView:playModel.tableView
                                              beforeOffset:_beforeOffset];
        }
    }
    else if ( [_playModel isKindOfClass:[SJUICollectionViewNestedInUITableViewCellPlayModel class]] ) {
        SJUICollectionViewNestedInUITableViewCellPlayModel *playModel = _playModel;
        UICollectionView *collectionView = [[playModel.tableView cellForRowAtIndexPath:playModel.collectionViewAtIndexPath] viewWithTag:playModel.collectionViewTag];
        
        if ( collectionView == scrollView ) {
            self.isAppeared = [self _isAppearedWithViewTag:playModel.playerSuperviewTag
                               collectionViewCellIndexPath:playModel.indexPath
                                            collectionView:collectionView
                                              beforeOffset:_beforeOffset];
        }
        else {
            
            // 确定collectionView是否显示
            BOOL isAppeared_parentView = [self _isAppearedWithViewTag:playModel.collectionViewTag
                                               tableViewCellIndexPath:playModel.collectionViewAtIndexPath
                                                            tableView:playModel.tableView
                                                         beforeOffest:_beforeOffset];
            
            if ( !isAppeared_parentView ) {
                self.isAppeared = NO;
                return;
            }
            
            // 确定父视图是否显示在cell中显示
            BOOL isAppeared_cell = [self _isAppearedWithViewTag:playModel.playerSuperviewTag
                                    collectionViewCellIndexPath:playModel.indexPath
                                                 collectionView:collectionView
                                                   beforeOffset:_beforeOffset];
            if ( !isAppeared_cell ) {
                self.isAppeared = NO;
                return;
            }
            
            // 确定父视图是否在tableview中显示
            self.isAppeared = [self _isAppearedWithViewTag:playModel.playerSuperviewTag
                               collectionViewCellIndexPath:playModel.indexPath
                                            collectionView:collectionView
                                                 tableView:playModel.tableView
                                              beforeOffset:_beforeOffset];
        }
    }

    _beforeOffset = scrollView.contentOffset;
}

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

- (BOOL)isPlayInTableView {
    return _playModel.isPlayInTableView;
}

- (BOOL)isPlayInCollectionView {
    return _playModel.isPlayInCollectionView;
}

@end
NS_ASSUME_NONNULL_END
