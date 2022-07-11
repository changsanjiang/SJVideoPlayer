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
@interface SJPlayModel: NSObject
/**
 The selector of `playerSuperView`, the playModel will be get superview through the selector.
 
 \code
    /// case 1:
    ///
    /// `playerSuperView` => UICollectionViewCell => UICollectionView
    ///
    /// The selector is @selector(playerSuperview);
    @interface YourCollectionViewCell ()
    @property (nonatomic, strong) UIView *playerSuperview;
    @end
 
    /// case 2:
    ///
    /// `playerSuperview` => UITableViewCell => UITableView
    ///
    /// The selector is @selector(playerSuperview2);
    @interface YourTableViewCell ()
    @property (nonatomic, strong) UIView *playerSuperview2;
    @end

    /// case 3:
    ///
    /// `playerSuperview` => UIScrollView
    ///
    /// The selector is @selector(playerSuperview);
    @interface YourScrollView ()
    @property (nonatomic, strong) UIView *playerSuperview;
    @end
 
    /// case 4:
    ///
    /// `playerSuperview` => TableHeaderView
    ///
    /// The selector is @selector(playerSuperview);
    @interface YourTableHeaderView ()
    @property (nonatomic, strong) UIView *playerSuperview;
    @end
    _tableView.tableHeaderView = YourTableHeaderView;
 
    /// case 5:
    ///
    /// `playerSuperview` => TableViewSectionHeaderFooterView
    ///
    /// The selector is @selector(playerSuperview);
    @interface YourTableViewSectionHeaderFooterView
    @property (nonatomic, strong) UIView *playerSuperview;
    @end
    - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
        return YourTableViewSectionHeaderFooterView;
    }

    /// more ..

 \endcode
 */
@property (nonatomic, nullable) SEL superviewSelector;

/**
 The nextPlayModel is used in nested view hierarchy. Specify nested view with `scrollViewSelector`.
 
 \code
    // view hierarchy case 1:
    //
    // `playerSuperView`(1) => UICollectionViewCell(2) => `UICollectionView(nested view)`(3) => UICollectionViewCell(4) => UICollectionView(5)
    @interface YourCollectionViewCell () // (2)
    @property (nonatomic, strong) UIView *playerSuperview; // (1)
    @end

    @interface YourCollectionViewCell () // (4)
    @property (nonatomic, strong) UICollectionView *collectionView; // (3)
    @end
 
    SJPlayModel *next = [SJPlayModel playModelWithCollectionView:(5) indexPath:indexPath for (4)];
    next.scrollViewSelector = @selector(collectionView); // (3)

    SJPlayModel *one = [SJPlayModel playModelWithCollectionView:(3) indexPath:indexPath for (2)];
    one.superviewSelector = @selector(playerSuperview); // (1)
    one.nextPlayModel = next;
 
    // view hierarchy case 2:
    //
    // `playerSuperView`(1) => UICollectionViewCell(2) => `UICollectionView(nested view)`(3) => UITableViewCell(4) => UITableView(5)
    @interface YourCollectionViewCell () // (2)
    @property (nonatomic, strong) UIView *playerSuperview; // (1)
    @end

    @interface YourTableViewCell () // (4)
    @property (nonatomic, strong) UICollectionView *collectionView; // (3)
    @end

    SJPlayModel *next = [SJPlayModel playModelWithTableView:(5) indexPath:indexPath for (4)];
    next.scrollViewSelector = @selector(collectionView); // (3)

    SJPlayModel *one = [SJPlayModel playModelWithCollectionView:(3) indexPath:indexPath for (2)];
    one.superviewSelector = @selector(playerSuperview); // (1)
    one.nextPlayModel = next;
 \endcode
*/
@property (nonatomic, strong, nullable) __kindof SJPlayModel *nextPlayModel;

/**
 The selector of `scrollView` in the below cases.
 
 \code
    // view hierarchy case 1:
    //
    // `playerSuperView`(1) => UICollectionViewCell(2) => `UICollectionView(nested view)`(3) => UICollectionViewCell(4) => UICollectionView(5)
    @interface YourCollectionViewCell () // (2)
    @property (nonatomic, strong) UIView *playerSuperview; // (1)
    @end

    @interface YourCollectionViewCell () // (4)
    @property (nonatomic, strong) UICollectionView *collectionView; // (3)
    @end

    SJPlayModel *next = [SJPlayModel playModelWithCollectionView:(5) indexPath:indexPath for (4)];
    next.scrollViewSelector = @selector(collectionView); // (3)

    SJPlayModel *one = [SJPlayModel playModelWithCollectionView:(3) indexPath:indexPath for (2)];
    one.superviewSelector = @selector(playerSuperview); // (1)
    one.nextPlayModel = next;

    // view hierarchy case 2:
    //
    // `playerSuperView`(1) => UICollectionViewCell(2) => `UICollectionView(nested view)`(3) => UITableViewCell(4) => UITableView(5)
    @interface YourCollectionViewCell () // (2)
    @property (nonatomic, strong) UIView *playerSuperview; // (1)
    @end

    @interface YourTableViewCell () // (4)
    @property (nonatomic, strong) UICollectionView *collectionView; // (3)
    @end

    SJPlayModel *next = [SJPlayModel playModelWithTableView:(5) indexPath:indexPath for (4)];
    next.scrollViewSelector = @selector(collectionView); // (3)

    SJPlayModel *one = [SJPlayModel playModelWithCollectionView:(3) indexPath:indexPath for (2)];
    one.superviewSelector = @selector(playerSuperview); // (1)
    one.nextPlayModel = next;
 \endcode
 */
@property (nonatomic, nullable) SEL scrollViewSelector;

/// 可播区域的insets
///
///
@property (nonatomic) UIEdgeInsets playableAreaInsets;

#pragma mark - UIView

- (instancetype)init;

#pragma mark - UIScrollView

/// - UIScrollView
///     - PlayerSuperview<SJPlayModelPlayerSuperview>
///         - player
+ (instancetype)playModelWithScrollView:(__weak UIScrollView *)scrollView;
+ (instancetype)playModelWithScrollView:(__weak UIScrollView *)scrollView superviewSelector:(SEL)superviewSelector;

#pragma mark - UITableView

/// - UITableView
///     - UITableViewCell
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView indexPath:(NSIndexPath *)indexPath superviewSelector:(SEL)superviewSelector;

/// - UITableView
///     - UITableView.TableHeaderView
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView tableHeaderView:(__weak UIView *)tableHeaderView;
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView tableHeaderView:(__weak UIView *)tableHeaderView superviewSelector:(SEL)superviewSelector;

/// - UITableView
///     - UITableView.TableFooterView
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView tableFooterView:(__weak UIView *)tableFooterView;
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView tableFooterView:(__weak UIView *)tableFooterView superviewSelector:(SEL)superviewSelector;

/// - UITableView
///     - UITableViewSectionHeaderView
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView inHeaderForSection:(NSInteger)section;
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView inHeaderForSection:(NSInteger)section superviewSelector:(SEL)superviewSelector;

/// - UITableView
///     - UITableViewSectionFooterView
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView inFooterForSection:(NSInteger)section;
+ (instancetype)playModelWithTableView:(__weak UITableView *)tableView inFooterForSection:(NSInteger)section superviewSelector:(SEL)superviewSelector;


#pragma mark - UICollectionView

/// - UICollectionView
///     - UICollectionViewCell
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithCollectionView:(__weak UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
+ (instancetype)playModelWithCollectionView:(__weak UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath superviewSelector:(SEL)superviewSelector;

/// - UICollectionView
///     - UICollectionElementKindSectionHeader
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithCollectionView:(UICollectionView *__weak)collectionView inHeaderForSection:(NSInteger)section;
+ (instancetype)playModelWithCollectionView:(UICollectionView *__weak)collectionView inHeaderForSection:(NSInteger)section superviewSelector:(SEL)superviewSelector;

/// - UICollectionView
///     - UICollectionElementKindSectionFooter
///         - PlayerSuperview<SJPlayModelPlayerSuperview>
///             - player
+ (instancetype)playModelWithCollectionView:(UICollectionView *__weak)collectionView inFooterForSection:(NSInteger)section;
+ (instancetype)playModelWithCollectionView:(UICollectionView *__weak)collectionView inFooterForSection:(NSInteger)section superviewSelector:(SEL)superviewSelector;

#pragma mark -

//@property (nonatomic, readonly) BOOL isPlayInScrollView;
//@property (nonatomic, readonly, nullable) __kindof UIView<SJPlayModelPlayerSuperview> *superview;
//@property (nonatomic, readonly, nullable) __kindof UIScrollView *scrollView;
//@property (nonatomic, strong, readonly, nullable) NSIndexPath *indexPath;

- (BOOL)isPlayInScrollView;
- (nullable UIView<SJPlayModelPlayerSuperview> *)playerSuperview;
- (nullable __kindof UIScrollView *)inScrollView;
- (nullable NSIndexPath *)indexPath;
- (NSInteger)section;

/// 视图tag.
///
///     当一个界面中, 需要同时存在多个播放器时, 用此tag来进一步区分对应的父视图(请设置`SJPlayModelPlayerSuperview.tag`, 不可为 0)
///
///     当多个父视图设置不同的tag后, 管理类将通过此tag来定位对应父视图, 从而实现同一个页面中多个播放器同时播放的效果
///
@property (nonatomic) NSUInteger superviewTag;
@end


/// 用于标识: 播放器父视图. 父视图需遵守该协议. 将来播放器视图会被管理类自动添加到此视图中.
/// 已弃用, 已改为通过KVC获取父视图
__deprecated_msg("use `playModel.superviewSelector`;")
@protocol SJPlayModelPlayerSuperview 

@end

/// 用于标识: 嵌套的视图. 在嵌套场景中, 嵌套的视图需遵守该协议. 管理类将通过这条链一层一层找到父视图.
/// 例如: UITableViewCell 中内嵌的一个 UICollectionView<SJPlayModelNestedView>, 播放器将来要在 UICollectionViewCell 中的某个视图上播放.
///      由于`tableView`以及`collectionView`都存在复用的情况, 因此需要添加该标记建立视图层次链. 管理类通过这条链来定位具体位置.
/// 已弃用, 已改为通过KVC获取嵌套视图
__deprecated_msg("use `playModel.nextPlayModel` and `playModel.scrollViewSelector`;")
@protocol SJPlayModelNestedView

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

@protocol SJPlayerDefaultSelectors <NSObject>
@property (nonatomic, readonly) id playerSuperview;
@property (nonatomic, readonly) id collectionView;
@end
NS_ASSUME_NONNULL_END
