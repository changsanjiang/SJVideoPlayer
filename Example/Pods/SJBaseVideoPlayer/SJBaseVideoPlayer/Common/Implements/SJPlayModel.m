//
//  SJPlayModel.m
//  SJVideoPlayerAssetCarrier
//
//  Created by 畅三江 on 2018/6/28.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "SJPlayModel.h"
#import "UIView+SJBaseVideoPlayerExtended.h"
#import "UIScrollView+SJBaseVideoPlayerExtended.h"
#import "SJPlayModel+SJPrivate.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJPlayModel
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    return self;
}

+ (instancetype)playModelWithScrollView:(__weak UIScrollView *)scrollView {
    return [SJScrollViewPlayModel.alloc initWithScrollView:scrollView];
}

+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    return [SJTableViewCellPlayModel.alloc initWithTableView:tableView indexPath:indexPath];
}

+ (instancetype)playModelWithTableView:(UITableView *__weak)tableView tableHeaderView:(__weak UIView *)tableHeaderView {
    return [SJTableViewTableHeaderViewPlayModel.alloc initWithTableView:tableView tableHeaderView:tableHeaderView];
}

+ (instancetype)playModelWithTableView:(UITableView *__weak)tableView tableFooterView:(__weak UIView *)tableFooterView {
    return [SJTableViewTableFooterViewPlayModel.alloc initWithTableView:tableView tableFooterView:tableFooterView];
}

+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView inHeaderForSection:(NSInteger)section {
    return [SJTableViewSectionHeaderViewPlayModel.alloc initWithTableView:tableView inHeaderForSection:section];
}

+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView inFooterForSection:(NSInteger)section {
    return [SJTableViewSectionFooterViewPlayModel.alloc initWithTableView:tableView inFooterForSection:section];
}

+ (instancetype)playModelWithCollectionView:(__weak UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    return [SJCollectionViewCellPlayModel.alloc initWithCollectionView:collectionView indexPath:indexPath];
}

+ (instancetype)playModelWithCollectionView:(UICollectionView *__weak)collectionView inHeaderForSection:(NSInteger)section {
    return [SJCollectionViewSectionHeaderViewPlayModel.alloc initWithCollectionView:collectionView inHeaderForSection:section];
}

+ (instancetype)playModelWithCollectionView:(UICollectionView *__weak)collectionView inFooterForSection:(NSInteger)section {
    return [SJCollectionViewSectionFooterViewPlayModel.alloc initWithCollectionView:collectionView inFooterForSection:section];
}


- (BOOL)isPlayInScrollView { return NO; }
- (nullable UIView *)playerSuperview { return nil; }
- (nullable __kindof UIScrollView *)inScrollView { return nil; }
- (nullable NSIndexPath *)indexPath { return nil; }
@end


@implementation SJScrollViewPlayModel
- (instancetype)initWithScrollView:(__weak UIScrollView *)scrollView {
    self = [super init];
    if ( self ) {
        _scrollView = scrollView;
    }
    return self;
}

- (BOOL)isPlayInScrollView {
    return YES;
}

- (nullable UIView *)playerSuperview {
    return [_scrollView viewWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:self.superviewTag];
}

- (nullable __kindof UIScrollView *)inScrollView {
    return _scrollView;
}
@end


@implementation SJTableViewCellPlayModel
- (instancetype)initWithTableView:(__weak UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    self = [super init];
    if ( self ) {
        _tableView = tableView;
        _indexPath = indexPath;
    }
    return self;
}

- (BOOL)isPlayInScrollView {
    return YES;
}
- (nullable UIView *)playerSuperview {
    return [_tableView viewWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:self.superviewTag atIndexPath:_indexPath];
}
- (nullable __kindof UIScrollView *)inScrollView {
    return _tableView;
}
@end


@implementation SJTableViewTableHeaderViewPlayModel
- (instancetype)initWithTableView:(UITableView *__weak)tableView tableHeaderView:(__weak UIView *)tableHeaderView {
    self = [super init];
    if ( self ) {
        _tableView = tableView;
        _tableHeaderView = tableHeaderView;
    }
    return self;
}

- (BOOL)isPlayInScrollView {
    return YES;
}
- (nullable UIView *)playerSuperview {
    return [_tableHeaderView viewWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:self.superviewTag];
}
- (nullable __kindof UIScrollView *)inScrollView {
    return _tableView;
}
@end


@implementation SJTableViewTableFooterViewPlayModel
- (instancetype)initWithTableView:(UITableView *__weak)tableView tableFooterView:(__weak UIView *)tableFooterView {
    self = [super init];
    if ( self ) {
        _tableView = tableView;
        _tableFooterView = tableFooterView;
    }
    return self;
}

- (BOOL)isPlayInScrollView {
    return YES;
}
- (nullable UIView *)playerSuperview {
    return [_tableFooterView viewWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:self.superviewTag];
}
- (nullable __kindof UIScrollView *)inScrollView {
    return _tableView;
}
@end


@implementation SJTableViewSectionHeaderViewPlayModel
- (instancetype)initWithTableView:(__weak UITableView *)tableView inHeaderForSection:(NSInteger)section {
    self = [super init];
    if ( self ) {
        _tableView = tableView;
        _section = section;
    }
    return self;
}

- (BOOL)isPlayInScrollView {
    return YES;
}
- (nullable UIView *)playerSuperview {
    return [_tableView viewWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:self.superviewTag inHeaderForSection:_section];
}
- (nullable __kindof UIScrollView *)inScrollView {
    return _tableView;
}
@end


@implementation SJTableViewSectionFooterViewPlayModel
- (instancetype)initWithTableView:(__weak UITableView *)tableView inFooterForSection:(NSInteger)section {
    self = [super init];
    if ( self ) {
        _tableView = tableView;
        _section = section;
    }
    return self;
}

- (BOOL)isPlayInScrollView {
    return YES;
}
- (nullable UIView *)playerSuperview {
    return [_tableView viewWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:self.superviewTag inFooterForSection:_section];
}
- (nullable __kindof UIScrollView *)inScrollView {
    return _tableView;
}
@end


@implementation SJCollectionViewCellPlayModel
- (instancetype)initWithCollectionView:(__weak UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    self = [super init];
    if ( self ) {
        _collectionView = collectionView;
        _indexPath = indexPath;
    }
    return self;
}

- (void)setNextPlayModel:(nullable __kindof SJPlayModel *)nextPlayModel {
    [super setNextPlayModel:nextPlayModel];
    
    //
    // 嵌套情况需处理复用的问题
    //
    // 1. 需处理复用的有:(`cell`和`section`存在复用的情况)
    //      - SJCollectionViewCellPlayModel
    //      - SJCollectionViewSectionHeaderViewPlayModel
    //      - SJCollectionViewSectionFooterViewPlayModel
    //      - SJTableViewCellPlayModel
    //      - SJTableViewSectionHeaderViewPlayModel
    //      - SJTableViewSectionFooterViewPlayModel
    //
    // 2. 无需处理的有:(不存在复用的情况)
    //      - SJTableViewTableHeaderViewPlayModel
    //      - SJTableViewTableFooterViewPlayModel
    //
    //
    if ( [nextPlayModel isKindOfClass:SJCollectionViewCellPlayModel.class] ||
         [nextPlayModel isKindOfClass:SJCollectionViewSectionHeaderViewPlayModel.class] ||
         [nextPlayModel isKindOfClass:SJCollectionViewSectionFooterViewPlayModel.class] ||
         [nextPlayModel isKindOfClass:SJTableViewCellPlayModel.class] ||
         [nextPlayModel isKindOfClass:SJTableViewSectionHeaderViewPlayModel.class] ||
         [nextPlayModel isKindOfClass:SJTableViewSectionFooterViewPlayModel.class] ) {
        
        // 当前嵌入的CollectionView需要一个标识(SJPlayModelNestedView), 以便能够在复用的情况下也能获取到它
        
        NSAssert([_collectionView conformsToProtocol:@protocol(SJPlayModelNestedView)], @"`collectionView` must implement `SJPlayModelNestedView` protocol!");
    }
}

- (BOOL)isPlayInScrollView {
    return YES;
}

- (nullable UIView *)playerSuperview {
    return [[self inScrollView] viewWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:self.superviewTag atIndexPath:_indexPath];;
}

- (nullable __kindof UIScrollView *)inScrollView {
    if      ( [self.nextPlayModel isKindOfClass:SJCollectionViewCellPlayModel.class] ||
              [self.nextPlayModel isKindOfClass:SJTableViewCellPlayModel.class] ) {
        return [self.nextPlayModel.inScrollView viewWithProtocol:@protocol(SJPlayModelNestedView) tag:self.superviewTag atIndexPath:self.nextPlayModel.indexPath];
    }
    else if ( [self.nextPlayModel isKindOfClass:SJCollectionViewSectionHeaderViewPlayModel.class]) {
        SJCollectionViewSectionHeaderViewPlayModel *playModel = self.nextPlayModel;
        return [playModel.inScrollView viewWithProtocol:@protocol(SJPlayModelNestedView) tag:self.superviewTag inHeaderForSection:playModel.section];
    }
    else if ( [self.nextPlayModel isKindOfClass:SJCollectionViewSectionFooterViewPlayModel.class] ) {
        SJCollectionViewSectionFooterViewPlayModel *playModel = self.nextPlayModel;
        return [playModel.inScrollView viewWithProtocol:@protocol(SJPlayModelNestedView) tag:self.superviewTag inFooterForSection:playModel.section];
    }
    else if ( [self.nextPlayModel isKindOfClass:SJTableViewSectionHeaderViewPlayModel.class]) {
        SJTableViewSectionHeaderViewPlayModel *playModel = self.nextPlayModel;
        return [playModel.inScrollView viewWithProtocol:@protocol(SJPlayModelNestedView) tag:self.superviewTag inHeaderForSection:playModel.section];
    }
    else if ( [self.nextPlayModel isKindOfClass:SJTableViewSectionFooterViewPlayModel.class] ) {
        SJTableViewSectionFooterViewPlayModel *playModel = self.nextPlayModel;
        return [playModel.inScrollView viewWithProtocol:@protocol(SJPlayModelNestedView) tag:self.superviewTag inFooterForSection:playModel.section];
    }
    return _collectionView;
}
@end


@implementation SJCollectionViewSectionHeaderViewPlayModel
- (instancetype)initWithCollectionView:(__weak UICollectionView *)collectionView inHeaderForSection:(NSInteger)section {
    self = [super init];
    if ( self ) {
        _collectionView = collectionView;
        _section = section;
    }
    return self;
}

- (BOOL)isPlayInScrollView {
    return YES;
}

- (nullable UIView *)playerSuperview {
    return [[self inScrollView] viewWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:self.superviewTag inHeaderForSection:_section];;
}

- (nullable __kindof UIScrollView *)inScrollView {
    return _collectionView;
}
@end

@implementation SJCollectionViewSectionFooterViewPlayModel
- (instancetype)initWithCollectionView:(__weak UICollectionView *)collectionView inFooterForSection:(NSInteger)section {
    self = [super init];
    if ( self ) {
        _collectionView = collectionView;
        _section = section;
    }
    return self;
}
 
- (BOOL)isPlayInScrollView {
    return YES;
}

- (nullable UIView *)playerSuperview {
    return [[self inScrollView] viewWithProtocol:@protocol(SJPlayModelPlayerSuperview) tag:self.superviewTag inFooterForSection:_section];;
}

- (nullable __kindof UIScrollView *)inScrollView {
    return _collectionView;
}
@end

























































@implementation SJUITableViewCellPlayModel

- (instancetype)initWithPlayerSuperview:(__unused UIView *)playerSuperview
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
- (BOOL)isPlayInScrollView { return YES; }
- (nullable UIView *)playerSuperview {
    return [[self.tableView cellForRowAtIndexPath:self.indexPath] viewWithTag:self.playerSuperviewTag];
}
- (nullable __kindof UIScrollView *)inScrollView {
    return self.tableView;
}
@end

@implementation SJUICollectionViewCellPlayModel

- (instancetype)initWithPlayerSuperview:(__unused UIView *)playerSuperview
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
- (BOOL)isPlayInScrollView { return YES; }
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

- (BOOL)isPlayInScrollView { return YES; }
- (nullable __kindof UIScrollView *)inScrollView {
    return _tableView;
}
@end

@implementation SJUICollectionViewNestedInUITableViewHeaderViewPlayModel

- (instancetype)initWithPlayerSuperview:(UIView *)playerSuperview
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
 
- (BOOL)isPlayInScrollView { return YES; }
- (nullable UIView *)playerSuperview {
    return [[self.collectionView cellForItemAtIndexPath:self.indexPath] viewWithTag:self.playerSuperviewTag];
}
- (nullable __kindof UIScrollView *)inScrollView {
    return _collectionView;
}
@end

@implementation SJUICollectionViewNestedInUITableViewCellPlayModel

- (instancetype)initWithPlayerSuperview:(UIView *)playerSuperview
                            atIndexPath:(NSIndexPath * _Nonnull)indexPath
                         collectionView:(UICollectionView *)collectionView
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
 
- (BOOL)isPlayInScrollView { return YES; }
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
 
- (BOOL)isPlayInScrollView { return YES; }
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

- (BOOL)isPlayInScrollView { return YES; }
- (UIView *_Nullable)playerSuperview {
    return _isHeader?[[[self tableView] headerViewForSection:_inSection] viewWithTag:_playerSuperviewTag]:
    [[[self tableView] footerViewForSection:_inSection] viewWithTag:_playerSuperviewTag];
}
- (nullable __kindof UIScrollView *)inScrollView {
    return _tableView;
}
@end
 

@implementation SJPlayModel (SJDeprecated)
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
@end
NS_ASSUME_NONNULL_END
