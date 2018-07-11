//
//  UIScrollView+ListViewAutoplaySJAdd.h
//  Masonry
//
//  Created by BlueDancer on 2018/7/9.
//

#import <UIKit/UIKit.h>
#import "SJPlayerAutoplayConfig.h"

NS_ASSUME_NONNULL_BEGIN

/// List view autoplay.
/// 列表自动播放功能
/// v1.3.0 新增
@interface UIScrollView (ListViewAutoplaySJAdd)

@property (nonatomic, readonly) BOOL sj_enabledAutoplay;

/// enable autoplay
/// 开启
- (void)sj_enableAutoplayWithConfig:(SJPlayerAutoplayConfig *)autoplayConfig;

/// 关闭
- (void)sj_disenableAutoplay;

@end


/// Developers don't need to care, this category is automatically maintained by the SJBaseVideoPlayer.
/// 开发者无需关心, 此分类由播放器自动维护
@interface UIScrollView (SJPlayerCurrentPlayingIndexPath)
@property (nonatomic, strong, nullable, readonly) NSIndexPath *sj_currentPlayingIndexPath;
- (void)setSj_currentPlayingIndexPath:(nullable NSIndexPath *)sj_currentPlayingIndexPath;
- (void)sj_needPlayNextAsset;
@end
NS_ASSUME_NONNULL_END
