//
//  SJPlayerScrollViewCarrier.m
//  SJVideoPlayerAssetCarrier
//
//  Created by BlueDancer on 2018/5/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJPlayerScrollViewCarrier.h"
#import <SJObserverHelper/NSObject+SJObserverHelper.h>

@interface SJPlayerScrollViewCarrier()
@property (nonatomic) CGPoint beforeOffset;
@property (nonatomic) BOOL isAppeared;
@property (nonatomic) BOOL isAppeared_Parent;
@end

@implementation SJPlayerScrollViewCarrier

/// player super view -> table or collection cell -> table or collection view
- (instancetype)initWithPlayerSuperViewTag:(NSInteger)playerSuperViewTag
                                 indexPath:(NSIndexPath *)indexPath
                                scrollView:(__unsafe_unretained UIScrollView *)tableViewOrCollectionView {
    return [self initWithPlayerSuperViewTag:playerSuperViewTag
                                  indexPath:indexPath
                                 scrollView:tableViewOrCollectionView
                              scrollViewTag:0
                        scrollViewIndexPath:nil
                             rootScrollView:nil];
}

/// player super view -> collection cell -> collection view -> table cell -> table view
- (instancetype)initWithPlayerSuperViewTag:(NSInteger)playerSuperViewTag
                                 indexPath:(NSIndexPath *__nullable)indexPath
                                scrollView:(__unsafe_unretained UIScrollView *__nullable)tableViewOrCollectionView
                             scrollViewTag:(NSInteger)scrollViewTag
                       scrollViewIndexPath:(NSIndexPath *__nullable)scrollViewIndexPath
                            rootScrollView:(__unsafe_unretained UIScrollView *__nullable)rootScrollView {
    self = [super init];
    if ( !self ) return nil;
    _isAppeared = YES;
    _isAppeared_Parent = YES;
    _superviewTag = playerSuperViewTag;
    _indexPath = indexPath;
    _scrollView = tableViewOrCollectionView;
    _scrollViewTag = scrollViewTag;
    _scrollViewIndexPath = scrollViewIndexPath;
    _rootScrollView = rootScrollView;
    [self _observeScrollView:_scrollView];
    [self _observeScrollView:_rootScrollView];
    return self;
}

/// player super view -> table header view -> table view
- (instancetype)initWithPlayerSuperViewOfTableHeader:(UIView *)playerSuperView
                                           tableView:(__unsafe_unretained UITableView *)tableView {
    self = [self initWithPlayerSuperViewTag:0
                                  indexPath:nil
                                 scrollView:tableView
                              scrollViewTag:0
                        scrollViewIndexPath:nil
                             rootScrollView:nil];
    if ( !self ) return nil;
    _tableHeaderSubView = playerSuperView;
    return self;
}

/// player super view -> collection cell -> table header view -> table view
- (instancetype)initWithPlayerSuperViewTag:(NSInteger)playerSuperViewTag
                                 indexPath:(NSIndexPath *)indexPath
               collectionViewOfTableHeader:(__unsafe_unretained UICollectionView *)collectionView
                             rootTableView:(__unsafe_unretained UITableView *)rootTableView {
    self = [self initWithPlayerSuperViewTag:playerSuperViewTag
                                  indexPath:indexPath
                                 scrollView:collectionView
                              scrollViewTag:0
                        scrollViewIndexPath:nil
                             rootScrollView:rootTableView];
    if ( !self ) return nil;
    _tableHeaderSubView = collectionView;
    return self;
}

- (void)_observeScrollView:(UIScrollView *)scrollView {
    if ( !scrollView ) return;
    [scrollView sj_addObserver:self forKeyPath:@"contentOffset"];
    [scrollView.panGestureRecognizer sj_addObserver:self forKeyPath:@"state"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ( [keyPath isEqualToString:@"contentOffset"] ) {
        [self _scrollViewDidScroll:object];
    }
    else if ( [keyPath isEqualToString:@"state"] ) {
        UIGestureRecognizerState state = [change[NSKeyValueChangeNewKey] integerValue];
        switch ( state ) {
            case UIGestureRecognizerStateChanged: break;
            case UIGestureRecognizerStatePossible: break;
            case UIGestureRecognizerStateBegan: {
                _touchedScrollView = YES;
                if ( [self.delegate respondsToSelector:@selector(scrollViewCarrier:touchedScrollView:)] ) {
                    [self.delegate scrollViewCarrier:self touchedScrollView:_touchedScrollView];
                }
            }
                break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateCancelled: {
                _touchedScrollView = NO;
                if ( [self.delegate respondsToSelector:@selector(scrollViewCarrier:touchedScrollView:)] ) {
                    [self.delegate scrollViewCarrier:self touchedScrollView:_touchedScrollView];
                }
            }
                break;
        }
    }
}

- (void)_scrollViewDidScroll:(UIScrollView *)scrollView {
    if ( !_scrollView ) return;
    if ( CGPointEqualToPoint(_beforeOffset, scrollView.contentOffset) ) return;
    _beforeOffset = scrollView.contentOffset;
    
    if ( self.tableHeaderSubView ) {
        [self considerTableHeader_scrollViewDidScroll:scrollView];
    }
    else {
        [self considerTableCell_scrollViewDidScroll:scrollView];
    }
}

- (void)considerTableHeader_scrollViewDidScroll:(UIScrollView *)scrollView {
    if ( scrollView == self.tableHeaderSubView && [self.tableHeaderSubView isKindOfClass:[UIScrollView class]] ) {
        [self considerTableCell_scrollViewDidScroll:scrollView];
    }
    else {
        CGFloat offsetY = scrollView.contentOffset.y;
        if ( offsetY < self.tableHeaderSubView.frame.size.height ) {
            if ( [self.scrollView isKindOfClass:[UITableView class]] ) {
                self.isAppeared = YES;
            }
            else {
                [self considerTableCell_scrollViewDidScroll:self.scrollView];
            }
        }
        else {
            self.isAppeared = NO;
        }
    }
}

- (void)considerTableCell_scrollViewDidScroll:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = (scrollView == _scrollView) ? _indexPath : _scrollViewIndexPath;
    __block BOOL visable = NO;
    if ( [scrollView isKindOfClass:[UITableView class]] ) {
        UITableView *tableView = (id)scrollView;
        [tableView.indexPathsForVisibleRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( [obj compare:indexPath] != NSOrderedSame ) return ;
            *stop = YES;
            visable = YES;
        }];
    }
    else if ( [scrollView isKindOfClass:[UICollectionView class]] ) {
        UICollectionView *collectionView = (UICollectionView *)scrollView;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        visable = [collectionView.visibleCells containsObject:cell];
    }
    
    if ( visable ) {
        visable = [self _playerViewIsAppeared];
    }
    if ( scrollView == _rootScrollView ) {
        if ( visable == self.isAppeared_Parent ) return;
        self.isAppeared_Parent = visable;
        if ( visable ) [self _updateScrollView];
    }
    
    self.isAppeared = self.isAppeared_Parent && visable;
}

- (BOOL)_playerViewIsAppeared {
    UIView *playerSuperView = [self _getPlayerSuperview];
    CGRect convertedRect = [playerSuperView.superview convertRect:playerSuperView.frame toView:_scrollView.superview];
    CGRect intersectionRect = CGRectIntersection(convertedRect, _scrollView.frame);
    return !CGRectIsNull(intersectionRect);
}

- (UIView *)_getPlayerSuperview {
    if ( self.tableHeaderSubView &&
        ![self.tableHeaderSubView isKindOfClass:[UIScrollView class]] ) {
        return [self.tableHeaderSubView viewWithTag:self.superviewTag];
    }
    
    UIView *cell = nil;
    if ( [_scrollView isKindOfClass:[UITableView class]] ) {
        cell = [(UITableView *)_scrollView cellForRowAtIndexPath:_indexPath];
    }
    else if ( [_scrollView isKindOfClass:[UICollectionView class]] ) {
        cell = [(UICollectionView *)_scrollView cellForItemAtIndexPath:_indexPath];
    }
    if ( !cell ) return nil;
    return [cell viewWithTag:_superviewTag];
}

- (void)_updateScrollView {
    UIScrollView *newScrollView = nil;
    if      ( [_rootScrollView isKindOfClass:[UITableView class]] ) {
        UITableView *parent = (UITableView *)_rootScrollView;
        UITableViewCell *parentCell = [parent cellForRowAtIndexPath:_scrollViewIndexPath];
        newScrollView = [parentCell viewWithTag:_scrollViewTag];
    }
    else if ( [_rootScrollView isKindOfClass:[UICollectionView class]] ) {
        UICollectionView *parent = (UICollectionView *)_rootScrollView;
        UICollectionViewCell *parentCell = [parent cellForItemAtIndexPath:_scrollViewIndexPath];
        newScrollView = [parentCell viewWithTag:_scrollViewTag];
    }
    
    if ( !newScrollView || newScrollView == _scrollView ) return;
    
    // set new scrollview
    _scrollView = newScrollView;
    
    // add observer
    [self _observeScrollView:newScrollView];
}

- (void)setIsAppeared:(BOOL)isAppeared {
    _isAppeared = isAppeared;
    if ( _isAppeared ) {
        if ( [self.delegate respondsToSelector:@selector(playerWillAppearForScrollViewCarrier:superview:)] ) {
            [self.delegate playerWillAppearForScrollViewCarrier:self superview:[self _getPlayerSuperview]];
        }
    }
    else {
        if ( [self.delegate respondsToSelector:@selector(playerWillDisappearForScrollViewCarrier:)] ) {
            [self.delegate playerWillDisappearForScrollViewCarrier:self];
        }
    }
}
@end
