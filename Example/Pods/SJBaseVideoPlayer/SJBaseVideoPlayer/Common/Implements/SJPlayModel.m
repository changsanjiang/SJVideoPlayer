//
//  SJPlayModel.m
//  SJVideoPlayerAssetCarrier
//
//  Created by 畅三江 on 2018/6/28.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "SJPlayModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 - SJPlayModel
 
 player view 在普通视图上
 
 
 - SJUITableViewCellPlayModel
 
 player view 在`UITableViewCell`中
 
 
 - SJUICollectionViewCellPlayModel
 
 player view 在`UICollectionViewCell`中
 
 
 - SJUITableViewHeaderViewPlayModel
 
 player view 在`UITableViewHeaderView`中
 
 
 - SJUICollectionViewNestedInUITableViewHeaderViewPlayModel
 
 player view 在`UICollectionViewCell`中, 但嵌套在`UITableViewHeaderView`里
 
 
 - SJUICollectionViewNestedInUITableViewCellPlayModel
 
 player view 在`UICollectionViewCell`中, 但嵌套在`UITableViewCell`里
 */
@implementation SJPlayModel
+ (instancetype)UIViewPlayModel {
    return SJPlayModel.alloc.init;
}

+ (instancetype)UITableViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                   atIndexPath:(__strong NSIndexPath *)indexPath
                                                     tableView:(__weak UITableView *)tableView {
    return [[SJUITableViewCellPlayModel alloc] initWithPlayerSuperviewTag:playerSuperviewTag atIndexPath:indexPath tableView:tableView];
}

+ (instancetype)UICollectionViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                        atIndexPath:(__strong NSIndexPath *)indexPath
                                                     collectionView:(__weak UICollectionView *)collectionView {
    return [[SJUICollectionViewCellPlayModel alloc] initWithPlayerSuperviewTag:playerSuperviewTag atIndexPath:indexPath collectionView:collectionView];
}

+ (instancetype)UITableViewHeaderViewPlayModelWithPlayerSuperview:(__weak UIView *)playerSuperview
                                                        tableView:(__weak UITableView *)tableView {
    return [[SJUITableViewHeaderViewPlayModel alloc] initWithPlayerSuperview:playerSuperview tableView:tableView];
}

+ (instancetype)UICollectionViewNestedInUITableViewHeaderViewPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                                                 atIndexPath:(NSIndexPath *)indexPath
                                                                              collectionView:(__weak UICollectionView *)collectionView
                                                                                   tableView:(__weak UITableView *)tableView {
    return [[SJUICollectionViewNestedInUITableViewHeaderViewPlayModel alloc] initWithPlayerSuperviewTag:playerSuperviewTag atIndexPath:indexPath collectionView:collectionView tableView:tableView];
}

+ (instancetype)UICollectionViewNestedInUITableViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                                           atIndexPath:(__strong NSIndexPath *)indexPath
                                                                     collectionViewTag:(NSInteger)collectionViewTag
                                                             collectionViewAtIndexPath:(__strong NSIndexPath *)collectionViewAtIndexPath
                                                                             tableView:(__weak UITableView *)tableView {
    return [[SJUICollectionViewNestedInUITableViewCellPlayModel alloc] initWithPlayerSuperviewTag:playerSuperviewTag atIndexPath:indexPath collectionViewTag:collectionViewTag collectionViewAtIndexPath:collectionViewAtIndexPath tableView:tableView];
}

+ (instancetype)UICollectionViewNestedInUICollectionViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                                                atIndexPath:(__strong NSIndexPath *)indexPath
                                                                          collectionViewTag:(NSInteger)collectionViewTag
                                                                  collectionViewAtIndexPath:(__strong NSIndexPath *)collectionViewAtIndexPath
                                                                         rootCollectionView:(__weak UICollectionView *)rootCollectionView {
    return [[SJUICollectionViewNestedInUICollectionViewCellPlayModel alloc] initWithPlayerSuperviewTag:playerSuperviewTag atIndexPath:indexPath collectionViewTag:collectionViewTag collectionViewAtIndexPath:collectionViewAtIndexPath rootCollectionView:rootCollectionView];
}

+ (instancetype)UITableViewHeaderFooterViewPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag inSection:(NSInteger)section isHeader:(BOOL)isHeader tableView:(UITableView * _Nonnull __weak)tableView {
    return [[SJUITableViewHeaderFooterViewPlayModel alloc] initWithPlayerSuperviewTag:playerSuperviewTag inSection:section isHeader:isHeader tableView:tableView];
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    return self;
}
- (BOOL)isPlayInTableView { return NO; }
- (BOOL)isPlayInCollectionView { return NO; }
- (nullable UIView *)playerSuperview { return nil; }
- (nullable __kindof UIScrollView *)inScrollView { return nil; }
- (nullable NSIndexPath *)indexPath { return nil; }
@end

@implementation SJUITableViewCellPlayModel

- (instancetype)initWithPlayerSuperview:(__unused UIView<SJPlayModelViewProtocol> *)playerSuperview
                            atIndexPath:(__strong NSIndexPath *)indexPath
                              tableView:(__weak UITableView *)tableView {
    return [self initWithPlayerSuperviewTag:playerSuperview.tag atIndexPath:indexPath tableView:tableView];
}
- (instancetype)initWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                               atIndexPath:(__strong NSIndexPath *)indexPath
                                 tableView:(__weak UITableView *)tableView {
    NSParameterAssert(playerSuperviewTag != 0);
    NSParameterAssert(indexPath);
    NSParameterAssert(tableView);
    
    self = [super init];
    if ( !self ) return nil;
    _playerSuperviewTag = playerSuperviewTag;
    _indexPath = indexPath;
    _tableView = tableView;
    return self;
}
- (BOOL)isPlayInTableView { return YES; }
- (BOOL)isPlayInCollectionView { return NO; }
- (nullable UIView *)playerSuperview {
    return [[self.tableView cellForRowAtIndexPath:self.indexPath] viewWithTag:self.playerSuperviewTag];
}
- (nullable __kindof UIScrollView *)inScrollView {
    return self.tableView;
}
@end

@implementation SJUICollectionViewCellPlayModel

- (instancetype)initWithPlayerSuperview:(__unused UIView<SJPlayModelViewProtocol> *)playerSuperview
                            atIndexPath:(__strong NSIndexPath *)indexPath
                         collectionView:(__weak UICollectionView *)collectionView {
    return [self initWithPlayerSuperviewTag:playerSuperview.tag atIndexPath:indexPath collectionView:collectionView];
}

- (instancetype)initWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                               atIndexPath:(__strong NSIndexPath *)indexPath
                            collectionView:(__weak UICollectionView *)collectionView {
    NSParameterAssert(playerSuperviewTag != 0);
    NSParameterAssert(indexPath);
    NSParameterAssert(collectionView);
    
    self = [super init];
    if ( !self ) return nil;
    _playerSuperviewTag = playerSuperviewTag;
    _indexPath = indexPath;
    _collectionView = collectionView;
    return self;
}
- (BOOL)isPlayInTableView { return NO; }
- (BOOL)isPlayInCollectionView { return YES; }
- (nullable UIView *)playerSuperview {
    return [[self.collectionView cellForItemAtIndexPath:self.indexPath] viewWithTag:self.playerSuperviewTag];
}
- (nullable __kindof UIScrollView *)inScrollView {
    return self.collectionView;
}
@end

@implementation SJUITableViewHeaderViewPlayModel

- (instancetype)initWithPlayerSuperview:(UIView * _Nonnull __weak)playerSuperview
                              tableView:(UITableView * _Nonnull __weak)tableView {
    NSParameterAssert(playerSuperview);
    NSParameterAssert(tableView);

    self = [super init];
    if ( !self ) return nil;
    _playerSuperview = playerSuperview;
    _tableView = tableView;
    return self;
}

- (BOOL)isPlayInTableView { return YES; }
- (BOOL)isPlayInCollectionView { return NO; }
- (nullable __kindof UIScrollView *)inScrollView {
    return _tableView;
}
@end

@implementation SJUICollectionViewNestedInUITableViewHeaderViewPlayModel

- (instancetype)initWithPlayerSuperview:(UIView<SJPlayModelViewProtocol> *)playerSuperview
                            atIndexPath:(NSIndexPath *)indexPath
                         collectionView:(UICollectionView * _Nonnull __weak)collectionView
                              tableView:(UITableView * _Nonnull __weak)tableView {
    return [self initWithPlayerSuperviewTag:playerSuperview.tag atIndexPath:indexPath collectionView:collectionView tableView:tableView];
}

- (instancetype)initWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                               atIndexPath:(NSIndexPath *)indexPath
                            collectionView:(__weak UICollectionView *)collectionView
                                 tableView:(__weak UITableView *)tableView {
    NSParameterAssert(playerSuperviewTag != 0);
    NSParameterAssert(indexPath);
    NSParameterAssert(collectionView);
    NSParameterAssert(tableView);
    
    self = [super init];
    if ( !self ) return nil;
    _playerSuperviewTag = playerSuperviewTag;
    _indexPath = indexPath;
    _collectionView = collectionView;
    _tableView = tableView;
    return self;
}

- (BOOL)isPlayInTableView { return NO; }
- (BOOL)isPlayInCollectionView { return YES; }
- (nullable UIView *)playerSuperview {
    return [[self.collectionView cellForItemAtIndexPath:self.indexPath] viewWithTag:self.playerSuperviewTag];
}
- (nullable __kindof UIScrollView *)inScrollView {
    return _collectionView;
}
@end

@implementation SJUICollectionViewNestedInUITableViewCellPlayModel

- (instancetype)initWithPlayerSuperview:(UIView<SJPlayModelViewProtocol> *)playerSuperview
                            atIndexPath:(NSIndexPath * _Nonnull)indexPath
                         collectionView:(UICollectionView<SJPlayModelViewProtocol> *)collectionView
              collectionViewAtIndexPath:(NSIndexPath * _Nonnull)collectionViewAtIndexPath
                              tableView:(UITableView * _Nonnull __weak)tableView {
    return [self initWithPlayerSuperviewTag:playerSuperview.tag atIndexPath:indexPath collectionViewTag:collectionView.tag collectionViewAtIndexPath:collectionViewAtIndexPath tableView:tableView];
}
- (instancetype)initWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                               atIndexPath:(__strong NSIndexPath *)indexPath
                         collectionViewTag:(NSInteger)collectionViewTag
                 collectionViewAtIndexPath:(__strong NSIndexPath *)collectionViewAtIndexPath
                                 tableView:(__weak UITableView *)tableView {
    NSParameterAssert(playerSuperviewTag != 0);
    NSParameterAssert(indexPath);
    NSParameterAssert(collectionViewTag != 0);
    NSParameterAssert(collectionViewAtIndexPath);
    NSParameterAssert(tableView);
    
    self = [super init];
    if ( !self ) return nil;
    _playerSuperviewTag = playerSuperviewTag;
    _indexPath = indexPath;
    _collectionViewTag = collectionViewTag;
    _collectionViewAtIndexPath = collectionViewAtIndexPath;
    _tableView = tableView;
    return self;
}

- (BOOL)isPlayInTableView { return NO; }
- (BOOL)isPlayInCollectionView { return YES; }
- (nullable UIView *)playerSuperview {
    return [[self.collectionView cellForItemAtIndexPath:self.indexPath] viewWithTag:self.playerSuperviewTag];
}
- (UICollectionView *)collectionView {
    return (UICollectionView *)([[self.tableView cellForRowAtIndexPath:self.collectionViewAtIndexPath] viewWithTag:self.collectionViewTag]);
}
- (nullable __kindof UIScrollView *)inScrollView {
    return [self collectionView];
}
@end

@implementation SJUICollectionViewNestedInUICollectionViewCellPlayModel
- (instancetype)initWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                   atIndexPath:(__strong NSIndexPath *)indexPath
                             collectionViewTag:(NSInteger)collectionViewTag
                     collectionViewAtIndexPath:(__strong NSIndexPath *)collectionViewAtIndexPath
                            rootCollectionView:(__weak UICollectionView *)rootCollectionView {
    NSParameterAssert(playerSuperviewTag != 0);
    NSParameterAssert(indexPath);
    NSParameterAssert(collectionViewTag != 0);
    NSParameterAssert(collectionViewAtIndexPath);
    NSParameterAssert(rootCollectionView);
    
    self = [super init];
    if ( !self ) return nil;
    _playerSuperviewTag = playerSuperviewTag;
    _indexPath = indexPath;
    _collectionViewTag = collectionViewTag;
    _collectionViewAtIndexPath = collectionViewAtIndexPath;
    _rootCollectionView = rootCollectionView;
    return self;
}

- (BOOL)isPlayInTableView { return NO; }
- (BOOL)isPlayInCollectionView { return YES; }
- (nullable UIView *)playerSuperview {
    return [[[self collectionView] cellForItemAtIndexPath:self.indexPath] viewWithTag:self.playerSuperviewTag];
}
- (UICollectionView *)collectionView {
    return (UICollectionView *)[[self.rootCollectionView cellForItemAtIndexPath:self.collectionViewAtIndexPath] viewWithTag:self.collectionViewTag];
}
- (nullable __kindof UIScrollView *)inScrollView {
    return [self collectionView];
}
@end

@implementation SJUITableViewHeaderFooterViewPlayModel
- (instancetype)initWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                 inSection:(NSInteger)inSection
                                  isHeader:(BOOL)isHeader
                                 tableView:(UITableView * _Nonnull __weak)tableView {
    NSParameterAssert(playerSuperviewTag != 0);
    NSParameterAssert(tableView);
    
    self = [super init];
    if ( !self )
        return nil;
    _playerSuperviewTag = playerSuperviewTag;
    _inSection = inSection;
    _tableView = tableView;
    _isHeader = isHeader;
    return self;
}

- (BOOL)isPlayInTableView { return YES; }
- (BOOL)isPlayInCollectionView { return NO; }
- (UIView *_Nullable)playerSuperview {
    return _isHeader?[[[self tableView] headerViewForSection:_inSection] viewWithTag:_playerSuperviewTag]:
    [[[self tableView] footerViewForSection:_inSection] viewWithTag:_playerSuperviewTag];
}
- (nullable __kindof UIScrollView *)inScrollView {
    return _tableView;
}
@end
NS_ASSUME_NONNULL_END
