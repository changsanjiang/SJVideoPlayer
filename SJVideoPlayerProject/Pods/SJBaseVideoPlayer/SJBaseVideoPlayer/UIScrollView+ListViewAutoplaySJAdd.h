//
//  UIScrollView+ListViewAutoplaySJAdd.h
//  Masonry
//
//  Created by BlueDancer on 2018/7/9.
//

#import <UIKit/UIKit.h>
#import "SJPlayerAutoplayConfig.h"

NS_ASSUME_NONNULL_BEGIN
/// 列表自动播放功能
@interface UIScrollView (ListViewAutoplaySJAdd)

@property (nonatomic, readonly) BOOL sj_enabledAutoplay;

/// 开启
- (void)sj_enableAutoplayWithConfig:(SJPlayerAutoplayConfig *)autoplayConfig;

/// 关闭
- (void)sj_disenableAutoplay;

@end


@interface UIScrollView (SJPlayerCurrentPlayingIndexPath)
/// 开发者无需关心, 播放器将会自动维护
@property (nonatomic, strong, nullable, readonly) NSIndexPath *sj_currentPlayingIndexPath;
- (void)setSj_currentPlayingIndexPath:(nullable NSIndexPath *)sj_currentPlayingIndexPath;
- (void)sj_needPlayNextAsset;
@end
NS_ASSUME_NONNULL_END

/**
 示例:

 SJPlayerAutoplayConfig *config = [SJPlayerAutoplayConfig configWithPlayerSuperviewTag:101 autoplayDelegate:self];
 // 开启自动播放
 [self.tableView sj_enableAutoplayWithConfig:config];
 
 // 播放第一个视频
 [self sj_playerNeedPlayNewAssetAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
 
 */
