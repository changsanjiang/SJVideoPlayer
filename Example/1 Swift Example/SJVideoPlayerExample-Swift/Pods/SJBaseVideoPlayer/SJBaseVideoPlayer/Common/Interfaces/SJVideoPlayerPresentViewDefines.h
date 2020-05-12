//
//  SJVideoPlayerPresentViewDefines.h
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/9/10.
//

#ifndef SJVideoPlayerPresentViewDefines_h
#define SJVideoPlayerPresentViewDefines_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJVideoPlayerPresentView <NSObject>
@property (nonatomic, strong, readonly) UIImageView *placeholderImageView;
@property (nonatomic, readonly, getter=isPlaceholderImageViewHidden) BOOL placeholderImageViewHidden;

- (void)showPlaceholderAnimated:(BOOL)animated;
- (void)hiddenPlaceholderAnimated:(BOOL)animated;
- (void)hiddenPlaceholderAnimated:(BOOL)animated delay:(NSTimeInterval)secs;
@end
NS_ASSUME_NONNULL_END
#endif /* SJVideoPlayerPresentViewDefines_h */
