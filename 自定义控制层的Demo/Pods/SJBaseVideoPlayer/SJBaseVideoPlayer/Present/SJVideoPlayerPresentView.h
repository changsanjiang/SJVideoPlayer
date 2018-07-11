//
//  SJVideoPlayerPresentView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVPlayer.h>
#import "SJVideoPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerPresentView : UIView

@property (nonatomic, strong, nullable) AVPlayer *player;

@property (nonatomic, strong, nullable) UIImage *placeholder;

@property (nonatomic, strong) AVLayerVideoGravity videoGravity; // default is AVLayerVideoGravityResizeAspect.

- (void)showPlaceholder;

- (void)hiddenPlaceholder;
@end

NS_ASSUME_NONNULL_END
