//
//  SJMoreSettingControlLayer.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/26.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJControlLayerDefines.h"
@class SJVideoPlayerMoreSetting;

NS_ASSUME_NONNULL_BEGIN
@interface SJMoreSettingControlLayer : UIView<SJControlLayer>
@property (nonatomic, copy, nullable) void(^disappearExeBlock)(SJMoreSettingControlLayer *control);
@property (nonatomic, strong, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;
@end
NS_ASSUME_NONNULL_END
