//
//  SJVideoPlayerPresentView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class SJVideoPlayerAssetCarrier;

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerPresentView : UIView

- (AVPlayerLayer *)avLayer;

@property (nonatomic, weak, readwrite, nullable) SJVideoPlayerAssetCarrier *asset;

@property (nonatomic, strong, readwrite, nullable) UIImage *placeholder;

@property (nonatomic) BOOL showPlaceholder;

@property (nonatomic, copy) void(^readyForDisplay)(SJVideoPlayerPresentView *view);

@property (nonatomic, copy) void(^receivedVideoRect)(SJVideoPlayerPresentView *view, CGRect bounds);

@property (nonatomic) AVLayerVideoGravity videoGravity;

@end

NS_ASSUME_NONNULL_END
