//
//  UIScrollView+ListViewAutoplaySJAdd.h
//  Masonry
//
//  Created by BlueDancer on 2018/7/9.
//

#import <UIKit/UIKit.h>
#import "SJPlayerAutoplayConfig.h"

NS_ASSUME_NONNULL_BEGIN
@interface UIScrollView (ListViewAutoplaySJAdd)

/// 开启
- (void)sj_enableAutoplayWithConfig:(SJPlayerAutoplayConfig *)autoplayConfig;

/// 关闭
- (void)sj_disenableAutoplay;

@end


@interface UIScrollView (SJPlayerCurrentPlayingIndexPath)
/// 开发者无需关心, 播放器将会自动维护
@property (nonatomic, strong, nullable, readonly) NSIndexPath *sj_currentPlayingIndexPath;
- (void)setSj_currentPlayingIndexPath:(nullable NSIndexPath *)sj_currentPlayingIndexPath;
@end
NS_ASSUME_NONNULL_END
