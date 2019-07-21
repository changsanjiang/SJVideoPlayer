//
//  SJVideoPlayerPresentView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJPlayerGestureControlDefines.h"

@protocol SJVideoPlayerPresentViewDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerPresentView : UIView<SJPlayerGestureControl>
@property (nonatomic, weak, nullable) id<SJVideoPlayerPresentViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIImageView *placeholderImageView;
@property (nonatomic, readonly, getter=isPlaceholderImageViewHidden) BOOL placeholderImageViewHidden;
- (void)showPlaceholderAnimated:(BOOL)animated;
- (void)hiddenPlaceholderAnimated:(BOOL)animated delay:(NSTimeInterval)secs;
@end

@protocol SJVideoPlayerPresentViewDelegate <NSObject>
- (void)presentViewDidLayoutSubviews:(SJVideoPlayerPresentView *)presentView;
@end
NS_ASSUME_NONNULL_END
