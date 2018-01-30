//
//  SJVideoPlayerBaseView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/30.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJVideoPlayerControlViewEnumHeader.h"
#import "SJVideoPlayerSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerBaseView : UIView

@property (nonatomic, strong, readonly) UIView *containerView;

@property (nonatomic, copy, readwrite, nullable) void(^setting)(SJVideoPlayerSettings *setting);

@end

NS_ASSUME_NONNULL_END
