//
//  SJVideoPlayerPresentView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SJVideoPlayerState.h"
#import "SJVideoPlayerBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@class SJVideoPlayerAssetCarrier;

@interface SJVideoPlayerPresentView : SJVideoPlayerBaseView

@property (nonatomic, weak, readwrite, nullable) SJVideoPlayerAssetCarrier *asset;

@property (nonatomic, copy, readwrite, nullable) void(^readyForDisplay)(SJVideoPlayerPresentView *view, CGRect videoRect);

@property (nonatomic, strong, readwrite, nullable) UIImage *placeholder;

@property (nonatomic, assign, readwrite) SJVideoPlayerPlayState state;

@property (nonatomic, copy, readwrite) AVLayerVideoGravity videoGravity; // default is AVLayerVideoGravityResizeAspect.

@end

NS_ASSUME_NONNULL_END
