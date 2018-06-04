//
//  UIView+SJVideoPlayerSetting.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/3.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJEdgeControlLayerSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerControlSettingRecorder : NSObject

- (instancetype)initWithSettings:(void (^)(SJEdgeControlLayerSettings *setting))settings;

@end


#pragma mark -
@interface UIView (SJVideoPlayerSetting)

@property (nonatomic, strong, nullable) SJVideoPlayerControlSettingRecorder *settingRecroder;

@end

NS_ASSUME_NONNULL_END
