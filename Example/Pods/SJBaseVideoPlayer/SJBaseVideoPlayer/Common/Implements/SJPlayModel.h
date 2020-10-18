//
//  SJPlayModel.h
//  SJVideoPlayerAssetCarrier
//
//  Created by 畅三江 on 2018/6/28.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SJPlayModelPlayerSuperview, SJPlayModelNestedView;

NS_ASSUME_NONNULL_BEGIN
/// 用于标识: 播放器父视图. 父视图需遵守该协议. 将来播放器视图会被管理类自动添加到此视图中.
@protocol SJPlayModelPlayerSuperview

@end

/// 用于标识: 嵌套的视图. 在嵌套场景中, 嵌套的视图需遵守该协议. 管理类将通过这条链一层一层找到父视图.
/// 例如: UITableViewCell 中内嵌的一个 UICollectionView<SJPlayModelNestedView>, 播放器将来要在 UICollectionViewCell 中的某个视图上播放.
///      由于`tableView`以及`collectionView`都存在复用的情况, 因此需要添加该标记建立视图层次链. 管理类通过这条链来定位具体位置.
@protocol SJPlayModelNestedView

@end


@interface SJPlayModel: NSObject

#pragma mark - UIView

- (instancetype)init;

#pragma mark - UIScrollView

/// - UIScrollView
///     - PlayerSuperview<SJPlayModelPlayerSuperview>
///         - player
+ (instancetype)playModelWithScrollView:(__weak UIScrollView *)scrollView;
 
#pragma mark - UITableView

/// - UITableView
///     - UITableViewCell
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

/// - UITableView
///     - UITableView.TableHeaderView
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView tableHeaderView:(__weak UIView *)tableHeaderView;

/// - UITableView
///     - UITableView.TableFooterView
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView tableFooterView:(__weak UIView *)tableFooterView;

/// - UITableView
///     - UITableViewSectionHeaderView
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView inHeaderForSection:(NSInteger)section;

/// - UITableView
///     - UITableViewSectionFooterView
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView inFooterForSection:(NSInteger)section;


#pragma mark - UICollectionView

/// - UICollectionView
///     - UICollectionViewCell
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithCollectionView:(__weak UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

/// - UICollectionView
///     - UICollectionElementKindSectionHeader
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithCollectionView:(UICollectionView *__weak)collectionView inHeaderForSection:(NSInteger)section;

/// - UICollectionView
///     - UICollectionElementKindSectionFooter
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithCollectionView:(UICollectionView *__weak)collectionView inFooterForSection:(NSInteger)section;


/// 视图tag.
///
///     当一个界面中, 需要同时存在多个播放器时, 用此tag来进一步区分对应的父视图(请设置`SJPlayModelPlayerSuperview.tag`, 不可为 0)
///
///     当多个父视图设置不同的tag后, 管理类将通过此tag来定位对应父视图, 从而实现同一个页面中多个播放器同时播放的效果
///
@property (nonatomic) NSUInteger superviewTag;

/// 可播区域的insets
///
///
@property (nonatomic) UIEdgeInsets playableAreaInsets;

#pragma mark - 视图嵌套情况下使用

/**
  嵌套链.  当存在视图嵌套情况时, 可以通过该方法与`nextPlayModel`建立视图层次链接
 
 1. - UITableView
      - UITableViewHeaderView
          - UICollectionView<SJPlayModelNestedView>
              - UICollectionViewCell
                  - PlayerSuperview<SJPlayModelPlayerSuperview>
                      - player
 
 \code
 SJPlayModel *one = [SJPlayModel playModelWithCollectionView:collectionView indexPath:cellIndexPath];
 one.nextPlayModel = [SJPlayModel playModelWithTableView:tableView tableHeaderView:tableHeaderView];
 \endcode
 
 2. - UITableView
      - UITableViewCell1
          - UICollectionView<SJPlayModelNestedView>
              - UICollectionViewCell2
                  - PlayerSuperview<SJPlayModelPlayerSuperview>
                      - player

 \code
 SJPlayModel *one = [SJPlayModel playModelWithCollectionView:collectionView indexPath:cellIndexPath2];
 one.nextPlayModel = [SJPlayModel playModelWithTableView:tableView indexPath:cellIndexPath1];
 \endcode
 
 3. - UICollectionView1
      - UICollectionViewCell1
          - UICollectionView2<SJPlayModelNestedView>
              - UICollectionViewCell2
                  - PlayerSuperview<SJPlayModelPlayerSuperview>
                      - player
 \code
 SJPlayModel *one = [SJPlayModel playModelWithCollectionView:collectionView2 indexPath:cellIndexPath2];
 one.nextPlayModel = [SJPlayModel playModelWithCollectionView:collectionView1 indexPath:cellIndexPath1];
 \endcode
 */
@property (nonatomic, strong, nullable) __kindof SJPlayModel *nextPlayModel;

#pragma mark -

//@property (nonatomic, readonly) BOOL isPlayInScrollView;
//@property (nonatomic, readonly, nullable) __kindof UIView<SJPlayModelPlayerSuperview> *superview;
//@property (nonatomic, readonly, nullable) __kindof UIScrollView *scrollView;
//@property (nonatomic, strong, readonly, nullable) NSIndexPath *indexPath;

- (BOOL)isPlayInScrollView;
- (nullable UIView<SJPlayModelPlayerSuperview> *)playerSuperview;
- (nullable __kindof UIScrollView *)inScrollView;
- (nullable NSIndexPath *)indexPath;
@end























#pragma mark -  以下内容已过期, 将来可能会删除


/// SJPlayModel
///     -> SJUITableViewCellPlayModel
///     -> SJUICollectionViewCellPlayModel
///     -> SJUITableViewHeaderViewPlayModel
///     -> SJUICollectionViewNestedInUITableViewHeaderViewPlayModel
///     -> SJUICollectionViewNestedInUITableViewCellPlayModel
@interface SJPlayModel (SJDeprecated)

+ (instancetype)UIViewPlayModel __deprecated_msg("use `SJPlayModel.alloc.init`!");

/// - UITableView
///     - UITableViewCell
///         - PlayerSuperview
///             - player
+ (instancetype)UITableViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                   atIndexPath:(__strong NSIndexPath *)indexPath
                                                     tableView:(__weak UITableView *)tableView __deprecated_msg("use `playModelWithTableView:indexPath`!");

/// - UICollectionView
///     - UICollectionViewCell
///         - PlayerSuperview
///             - player
+ (instancetype)UICollectionViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                        atIndexPath:(__strong NSIndexPath *)indexPath
                                                     collectionView:(__weak UICollectionView *)collectionView __deprecated_msg("use `playModelWithCollectionView:indexPath`!");



/// - UITableView
///     - UITableViewHeaderView
///         - PlayerSuperview
///             - player
+ (instancetype)UITableViewHeaderViewPlayModelWithPlayerSuperview:(__weak UIView *)playerSuperview
                                                        tableView:(__weak UITableView *)tableView __deprecated_msg("use `playModelWithTableView:tableHeaderView`!");

/// - UITableView
///     - UITableViewHeaderFooterView
///         - PlayerSuperview
///             - player
+ (instancetype)UITableViewHeaderFooterViewPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                                        inSection:(NSInteger)section
                                                                         isHeader:(BOOL)isHeader    // 是否是Header, 如果是传YES, 如果是Footer传NO
                                                                        tableView:(__weak UITableView *)tableView __deprecated_msg("use `playModelWithTableView:tableFooterView`!");

/// - UITableView
///     - UITableViewHeaderView
///         - UICollectionView
///             - UICollectionViewCell
///                 - PlayerSuperview
///                     - player
+ (instancetype)UICollectionViewNestedInUITableViewHeaderViewPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                                                 atIndexPath:(NSIndexPath *)indexPath
                                                                              collectionView:(__weak UICollectionView *)collectionView
                                                                                   tableView:(__weak UITableView *)tableView __deprecated_msg("use `nextPlayModel`!");

/// - UITableView
///     - UITableViewCell
///         - UICollectionView
///             - UICollectionViewCell
///                 - PlayerSuperview
///                     - player
+ (instancetype)UICollectionViewNestedInUITableViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                                           atIndexPath:(__strong NSIndexPath *)indexPath
                                                                     collectionViewTag:(NSInteger)collectionViewTag
                                                             collectionViewAtIndexPath:(__strong NSIndexPath *)collectionViewAtIndexPath
                                                                             tableView:(__weak UITableView *)tableView __deprecated_msg("use `nextPlayModel`!");

/// - UICollectionView
///     - UICollectionViewCell
///         - UICollectionView
///             - UICollectionViewCell
///                 - PlayerSuperview
///                     - player
+ (instancetype)UICollectionViewNestedInUICollectionViewCellPlayModelWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                                                                                atIndexPath:(__strong NSIndexPath *)indexPath
                                                                          collectionViewTag:(NSInteger)collectionViewTag
                                                                  collectionViewAtIndexPath:(__strong NSIndexPath *)collectionViewAtIndexPath
                                                                         rootCollectionView:(__weak UICollectionView *)rootCollectionView __deprecated_msg("use `nextPlayModel`!");
@end

NS_ASSUME_NONNULL_END
