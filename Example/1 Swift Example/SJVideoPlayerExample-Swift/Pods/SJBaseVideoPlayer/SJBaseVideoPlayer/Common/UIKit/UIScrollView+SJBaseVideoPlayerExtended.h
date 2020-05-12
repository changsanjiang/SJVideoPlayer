//
//  UIScrollView+SJBaseVideoPlayerExtended.h
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIScrollView (SJBaseVideoPlayerExtended)

- (nullable __kindof UIView *)viewWithTag:(NSInteger)tag atIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isViewAppearedWithTag:(NSInteger)tag atIndexPath:(NSIndexPath *)indexPath;

- (nullable __kindof UIView *)viewWithProtocol:(Protocol *)protocol atIndexPath:(NSIndexPath *)indexPath;
- (nullable __kindof UIView *)viewWithProtocol:(Protocol *)protocol inHeaderForSection:(NSInteger)section;
- (nullable __kindof UIView *)viewWithProtocol:(Protocol *)protocol inFooterForSection:(NSInteger)section;
- (BOOL)isViewAppearedWithProtocol:(Protocol *)protocol atIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
