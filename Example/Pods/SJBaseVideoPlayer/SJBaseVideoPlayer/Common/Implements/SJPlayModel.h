//
//  SJPlayModel.h
//  SJVideoPlayerAssetCarrier
//
//  Created by 畅三江 on 2018/6/28.
//  Copyright © 2018年 changsanjiang. All rights reserved.
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
- (nullable __kindof UIScrollView *)inScrollView;
@end


/// SJPlayModel
///     -> SJUITableViewCellPlayModel
///     -> SJUICollectionViewCellPlayModel
///     -> SJUITableViewHeaderViewPlayModel
///     -> SJUICollectionViewNestedInUITableViewHeaderViewPlayModel
///     -> SJUICollectionViewNestedInUITableViewCellPlayModel
@interface SJPlayModel: NSObject<SJPlayModel>

- (instancetype)init;

+ (instancetype)UIViewPlayModel;

/// - UITableView
///     - UITableViewCell
///         - player super view
///             - player
+ (instancetype)UITableViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                   atIndexPath:(__strong NSIndexPath *)indexPath
                                                     tableView:(__weak UITableView *)tableView;

/// - UICollectionView
///     - UICollectionViewCell
///         - player super view
///             - player
+ (instancetype)UICollectionViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                        atIndexPath:(__strong NSIndexPath *)indexPath
                                                     collectionView:(__weak UICollectionView *)collectionView;

/// - UITableView
///     - UITableViewHeaderView
///         - player super view
///             - player
+ (instancetype)UITableViewHeaderViewPlayModelWithPlayerSuperview:(__weak UIView *)playerSuperview
                                                        tableView:(__weak UITableView *)tableView;

/// - UITableView
///     - UITableViewHeaderView
///         - UICollectionView
///             - UICollectionViewCell
///                 - player super view
///                     - player
+ (instancetype)UICollectionViewNestedInUITableViewHeaderViewPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                                                 atIndexPath:(NSIndexPath *)indexPath
                                                                              collectionView:(__weak UICollectionView *)collectionView
                                                                                   tableView:(__weak UITableView *)tableView;

/// - UITableView
///     - UITableViewCell
///         - UICollectionView
///             - UICollectionViewCell
///                 - player super view
///                     - player
+ (instancetype)UICollectionViewNestedInUITableViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                                           atIndexPath:(__strong NSIndexPath *)indexPath
                                                                     collectionViewTag:(NSInteger)collectionViewTag
                                                             collectionViewAtIndexPath:(__strong NSIndexPath *)collectionViewAtIndexPath
                                                                             tableView:(__weak UITableView *)tableView;

/// - UICollectionView
///     - UICollectionViewCell
///         - UICollectionView
///             - UICollectionViewCell
///                 - player super view
///                     - player
+ (instancetype)UICollectionViewNestedInUICollectionViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                                                atIndexPath:(__strong NSIndexPath *)indexPath
                                                                          collectionViewTag:(NSInteger)collectionViewTag
                                                                  collectionViewAtIndexPath:(__strong NSIndexPath *)collectionViewAtIndexPath
                                                                         rootCollectionView:(__weak UICollectionView *)rootCollectionView;

/// - UITableView
///     - UITableViewHeaderFooterView
///         - player super view
///             - player
+ (instancetype)UITableViewHeaderFooterViewPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                                        inSection:(NSInteger)section
                                                                         isHeader:(BOOL)isHeader    // 是否是Header, 如果是传YES, 如果是Footer传NO
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

/// - UICollectionView
///     - UICollectionViewCell
///         - UICollectionView
///             - UICollectionViewCell
///                 - player super view
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
///         - player super view
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
