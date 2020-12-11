//
//  SJPlayModel+SJPrivate.h
//  Pods
//
//  Created by BlueDancer on 2020/5/9.
//

#import "SJPlayModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJScrollViewPlayModel : SJPlayModel
- (instancetype)initWithScrollView:(__weak UIScrollView *)scrollView;

@property (nonatomic, weak, readonly, nullable) UIScrollView *scrollView;
@end

@interface SJTableViewCellPlayModel : SJPlayModel
- (instancetype)initWithTableView:(__weak UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, weak, readonly, nullable) UITableView *tableView;
@property (nonatomic, strong, readonly) NSIndexPath *indexPath;
@end


@interface SJTableViewTableHeaderViewPlayModel : SJPlayModel
- (instancetype)initWithTableView:(UITableView *__weak)tableView tableHeaderView:(__weak UIView *)tableHeaderView;

@property (nonatomic, weak, readonly, nullable) UITableView *tableView;
@property (nonatomic, weak, readonly, nullable) UIView *tableHeaderView;
@end


@interface SJTableViewTableFooterViewPlayModel : SJPlayModel
- (instancetype)initWithTableView:(UITableView *__weak)tableView tableFooterView:(__weak UIView *)tableFooterView;

@property (nonatomic, weak, readonly, nullable) UITableView *tableView;
@property (nonatomic, weak, readonly, nullable) UIView *tableFooterView;
@end


@interface SJTableViewSectionHeaderViewPlayModel : SJPlayModel
- (instancetype)initWithTableView:(__weak UITableView *)tableView inHeaderForSection:(NSInteger)section;

@property (nonatomic, weak, readonly, nullable) UITableView *tableView;
@property (nonatomic, readonly) NSInteger section;
@end


@interface SJTableViewSectionFooterViewPlayModel : SJPlayModel
- (instancetype)initWithTableView:(__weak UITableView *)tableView inFooterForSection:(NSInteger)section;

@property (nonatomic, weak, readonly, nullable) UITableView *tableView;
@property (nonatomic, readonly) NSInteger section;
@end


#pragma mark -

@interface SJCollectionViewCellPlayModel : SJPlayModel
- (instancetype)initWithCollectionView:(__weak UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, weak, readonly, nullable) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) NSIndexPath *indexPath;
@end


@interface SJCollectionViewSectionHeaderViewPlayModel : SJPlayModel
- (instancetype)initWithCollectionView:(__weak UICollectionView *)collectionView inHeaderForSection:(NSInteger)section;

@property (nonatomic, weak, readonly, nullable) UICollectionView *collectionView;
@property (nonatomic, readonly) NSInteger section;
@end

@interface SJCollectionViewSectionFooterViewPlayModel : SJPlayModel
- (instancetype)initWithCollectionView:(__weak UICollectionView *)collectionView inFooterForSection:(NSInteger)section;

@property (nonatomic, weak, readonly, nullable) UICollectionView *collectionView;
@property (nonatomic, readonly) NSInteger section;
@end

#pragma mark -


/// 视图层级
/// - UITableView
///     - UITableViewCell
///         - PlayerSuperview
///             - player
@interface SJUITableViewCellPlayModel: SJPlayModel

- (instancetype)initWithPlayerSuperview:(__unused UIView *)playerSuperview
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
///         - PlayerSuperview
///             - player
@interface SJUICollectionViewCellPlayModel: SJPlayModel

- (instancetype)initWithPlayerSuperview:(__unused UIView *)playerSuperview
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
///         - PlayerSuperview
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
///                 - PlayerSuperview
///                     - player
@interface SJUICollectionViewNestedInUITableViewHeaderViewPlayModel: SJPlayModel

- (instancetype)initWithPlayerSuperview:(__unused UIView *)playerSuperview
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
///                 - PlayerSuperview
///                     - player
@interface SJUICollectionViewNestedInUITableViewCellPlayModel: SJPlayModel

- (instancetype)initWithPlayerSuperview:(__unused UIView *)playerSuperview
                            atIndexPath:(__strong NSIndexPath *)indexPath
                         collectionView:(__unused UICollectionView *)collectionView
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

/// - UICollectionView
///     - UICollectionViewCell
///         - UICollectionView
///             - UICollectionViewCell
///                 - PlayerSuperview
///                     - player
@interface SJUICollectionViewNestedInUICollectionViewCellPlayModel: SJPlayModel
- (instancetype)initWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                               atIndexPath:(__strong NSIndexPath *)indexPath
                         collectionViewTag:(NSInteger)collectionViewTag
                 collectionViewAtIndexPath:(__strong NSIndexPath *)collectionViewAtIndexPath
                        rootCollectionView:(__weak UICollectionView *)rootCollectionView;

@property (nonatomic, readonly) NSInteger playerSuperviewTag;
@property (nonatomic, strong, readonly) NSIndexPath *indexPath;
@property (nonatomic, readonly) NSInteger collectionViewTag;
@property (nonatomic, strong, readonly) NSIndexPath *collectionViewAtIndexPath;
@property (nonatomic, weak, readonly) UICollectionView *rootCollectionView;
// top
- (UICollectionView *)collectionView;
@end

/// - UITableView
///     - UITableViewHeaderFooterView
///         - PlayerSuperview
///             - player
@interface SJUITableViewHeaderFooterViewPlayModel : SJPlayModel
- (instancetype)initWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                 inSection:(NSInteger)inSection
                                  isHeader:(BOOL)isHeader
                                 tableView:(__weak UITableView *)tableView;

@property (nonatomic, readonly) NSInteger playerSuperviewTag;
@property (nonatomic, readonly) NSInteger inSection;
@property (nonatomic, readonly) BOOL isHeader;
@property (nonatomic, strong, readonly) UITableView *tableView;
@end

NS_ASSUME_NONNULL_END
