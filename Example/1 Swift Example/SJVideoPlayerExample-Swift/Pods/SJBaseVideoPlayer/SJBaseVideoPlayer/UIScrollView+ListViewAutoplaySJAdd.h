//
//  UIScrollView+ListViewAutoplaySJAdd.h
//  Masonry
//
//  Created by 畅三江 on 2018/7/9.
//

#import <UIKit/UIKit.h>
#import "SJPlayerAutoplayConfig.h"

NS_ASSUME_NONNULL_BEGIN

///
/// List view autoplay.
/// 列表自动播放功能
/// v1.3.0 新增
///
@interface UIScrollView (ListViewAutoplaySJAdd)

@property (nonatomic, readonly) BOOL sj_enabledAutoplay;

///
/// enable autoplay
/// 开启
///
- (void)sj_enableAutoplayWithConfig:(SJPlayerAutoplayConfig *)autoplayConfig;

///
/// 关闭
///
- (void)sj_disenableAutoplay;

///
/// 播放下一个(在已显示的cell中查找)
///
- (void)sj_playNextVisibleAsset;

///
/// 移除当前播放视图
///
- (void)sj_removeCurrentPlayerView;
@end


/// Developers don't need to care, this category is automatically maintained by the SJBaseVideoPlayer.
/// 开发者无需关心, 此分类由播放器自动维护
@interface UIScrollView (SJPlayerCurrentPlayingIndexPath)
@property (nonatomic, strong, nullable, readonly) NSIndexPath *sj_currentPlayingIndexPath;
- (void)setSj_currentPlayingIndexPath:(nullable NSIndexPath *)sj_currentPlayingIndexPath;
@end


@interface UIScrollView (SJAutoplayDeprecated)
- (void)sj_needPlayNextAsset __deprecated_msg("use `sj_playNextVisibleAsset`");
@end
NS_ASSUME_NONNULL_END
