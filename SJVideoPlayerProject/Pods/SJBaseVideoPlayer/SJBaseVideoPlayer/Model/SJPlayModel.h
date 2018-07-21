//
//  SJPlayModel.h
//  SJVideoPlayerAssetCarrier
//
//  Created by 畅三江 on 2018/6/28.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SJPlayModelViewProtocol<NSObject>

/// 相关视图的Tag
@property (nonatomic) NSInteger tag;

@end


@protocol SJPlayModel<NSObject>
- (BOOL)isPlayInTableView;
- (BOOL)isPlayInCollectionView;
- (nullable UIView *)playerSuperview;
@end


/// SJPlayModel
///     -> SJUITableViewCellPlayModel
///     -> SJUICollectionViewCellPlayModel
///     -> SJUITableViewHeaderViewPlayModel
///     -> SJUICollectionViewNestedInUITableViewHeaderViewPlayModel
///     -> SJUICollectionViewNestedInUITableViewCellPlayModel
@interface SJPlayModel: NSObject<SJPlayModel>

- (instancetype)init;

+ (instancetype)UITableViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                   atIndexPath:(__strong NSIndexPath *)indexPath
                                                     tableView:(__weak UITableView *)tableView;

+ (instancetype)UICollectionViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                        atIndexPath:(__strong NSIndexPath *)indexPath
                                                     collectionView:(__weak UICollectionView *)collectionView;

+ (instancetype)UITableViewHeaderViewPlayModelWithPlayerSuperview:(__weak UIView *)playerSuperview
                                                        tableView:(__weak UITableView *)tableView;

+ (instancetype)UICollectionViewNestedInUITableViewHeaderViewPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                                                 atIndexPath:(NSIndexPath *)indexPath
                                                                              collectionView:(__weak UICollectionView *)collectionView
                                                                                   tableView:(__weak UITableView *)tableView;

+ (instancetype)UICollectionViewNestedInUITableViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                                           atIndexPath:(__strong NSIndexPath *)indexPath
                                                                     collectionViewTag:(NSInteger)collectionViewTag
                                                             collectionViewAtIndexPath:(__strong NSIndexPath *)collectionViewAtIndexPath
                                                                             tableView:(__weak UITableView *)tableView;
@end


/// 视图层级
/// - UITableView
///     - UITableViewCell
///         - player super view
///             - player
@interface SJUITableViewCellPlayModel: SJPlayModel

- (instancetype)initWithPlayerSuperview:(__unused UIView<SJPlayModelViewProtocol> *)playerSuperview
                            atIndexPath:(__strong NSIndexPath *)indexPath
                              tableView:(__weak UITableView *)tableView;

@property (nonatomic, readonly) NSInteger playerSuperviewTag;
@property (nonatomic, strong, readonly) NSIndexPath *indexPath;
@property (nonatomic, weak, readonly) UITableView *tableView;

- (instancetype)initWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                               atIndexPath:(__strong NSIndexPath *)indexPath
                                 tableView:(__weak UITableView *)tableView;
@end

/// 视图层级
/// - UICollectionView
///     - UICollectionViewCell
///         - player super view
///             - player
@interface SJUICollectionViewCellPlayModel: SJPlayModel

- (instancetype)initWithPlayerSuperview:(__unused UIView<SJPlayModelViewProtocol> *)playerSuperview
                            atIndexPath:(__strong NSIndexPath *)indexPath
                         collectionView:(__weak UICollectionView *)collectionView;

@property (nonatomic, readonly) NSInteger playerSuperviewTag;
@property (nonatomic, strong, readonly) NSIndexPath *indexPath;
@property (nonatomic, weak, readonly) UICollectionView *collectionView;

- (instancetype)initWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                               atIndexPath:(__strong NSIndexPath *)indexPath
                            collectionView:(__weak UICollectionView *)collectionView;
@end

/// 视图层级
/// - UITableView
///     - UITableViewHeaderView
///         - player super view
///             - player
@interface SJUITableViewHeaderViewPlayModel: SJPlayModel

- (instancetype)initWithPlayerSuperview:(__weak UIView *)playerSuperview
                              tableView:(__weak UITableView *)tableView;

@property (nonatomic, weak, readonly) UIView *playerSuperview;
@property (nonatomic, weak, readonly) UITableView *tableView;

@end

/// 视图层级
/// - UITableView
///     - UITableViewHeaderView
///         - UICollectionView
///             - UICollectionViewCell
///                 - player super view
///                     - player
@interface SJUICollectionViewNestedInUITableViewHeaderViewPlayModel: SJPlayModel

- (instancetype)initWithPlayerSuperview:(__unused UIView<SJPlayModelViewProtocol> *)playerSuperview
                            atIndexPath:(NSIndexPath *)indexPath
                         collectionView:(__weak UICollectionView *)collectionView
                              tableView:(__weak UITableView *)tableView;

@property (nonatomic, readonly) NSInteger playerSuperviewTag;
@property (nonatomic, strong, readonly) NSIndexPath *indexPath;
@property (nonatomic, weak, readonly) UICollectionView *collectionView;
@property (nonatomic, weak, readonly) UITableView *tableView;

- (instancetype)initWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                               atIndexPath:(NSIndexPath *)indexPath
                            collectionView:(__weak UICollectionView *)collectionView
                                 tableView:(__weak UITableView *)tableView;
@end

/// 视图层级
/// - UITableView
///     - UITableViewCell
///         - UICollectionView
///             - UICollectionViewCell
///                 - player super view
///                     - player
@interface SJUICollectionViewNestedInUITableViewCellPlayModel: SJPlayModel

- (instancetype)initWithPlayerSuperview:(__unused UIView<SJPlayModelViewProtocol> *)playerSuperview
                            atIndexPath:(__strong NSIndexPath *)indexPath
                         collectionView:(__unused UICollectionView<SJPlayModelViewProtocol> *)collectionView
              collectionViewAtIndexPath:(__strong NSIndexPath *)collectionViewAtIndexPath
                              tableView:(__weak UITableView *)tableView;

@property (nonatomic, readonly) NSInteger playerSuperviewTag;
@property (nonatomic, strong, readonly) NSIndexPath *indexPath;
@property (nonatomic, readonly) NSInteger collectionViewTag;
@property (nonatomic, strong, readonly) NSIndexPath *collectionViewAtIndexPath;
@property (nonatomic, weak, readonly) UITableView *tableView;

- (instancetype)initWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                               atIndexPath:(__strong NSIndexPath *)indexPath
                         collectionViewTag:(NSInteger)collectionViewTag
                 collectionViewAtIndexPath:(__strong NSIndexPath *)collectionViewAtIndexPath
                                 tableView:(__weak UITableView *)tableView;

- (UICollectionView *)collectionView;
@end
NS_ASSUME_NONNULL_END
