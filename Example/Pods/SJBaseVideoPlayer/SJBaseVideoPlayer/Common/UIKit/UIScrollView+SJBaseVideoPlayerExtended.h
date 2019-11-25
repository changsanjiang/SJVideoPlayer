//
//  UIScrollView+SJBaseVideoPlayerExtended.h
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2019/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIScrollView (SJBaseVideoPlayerExtended)

- (nullable __kindof UIView *)viewWithTag:(NSInteger)tag atIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isViewAppearedWithTag:(NSInteger)tag atIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
