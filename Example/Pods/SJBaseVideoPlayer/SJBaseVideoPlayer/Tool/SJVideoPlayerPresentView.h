//
//  SJVideoPlayerPresentView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJVideoPlayerPresentView : UIView
@property (nonatomic, strong, readonly) UIImageView *placeholderImageView;
@property (nonatomic, copy, nullable) void(^layoutSubviewsExeBlock)(SJVideoPlayerPresentView *view);

@property (nonatomic, readonly) BOOL placeholderImageViewIsHidden;
- (void)showPlaceholderAnimated:(BOOL)animated;
- (void)hiddenPlaceholderAnimated:(BOOL)animated delay:(NSTimeInterval)secs;
@end
NS_ASSUME_NONNULL_END
