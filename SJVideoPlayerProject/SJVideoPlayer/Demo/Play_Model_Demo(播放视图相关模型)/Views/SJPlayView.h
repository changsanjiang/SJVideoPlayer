//
//  SJPlayView.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJPlayView : UIView
@property (nonatomic, strong, readonly) UIImageView *coverImageView;
@property (nonatomic, strong, readonly) UIButton *playButton;

@property (nonatomic, copy, nullable) void(^clickedPlayButtonExeBlock)(SJPlayView *view);
@end
NS_ASSUME_NONNULL_END
