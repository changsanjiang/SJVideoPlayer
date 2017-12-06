//
//  SJVolumeAndBrightness.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/6.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJVolumeAndBrightness : NSObject

@property (nonatomic, copy, readwrite, nullable) void(^volumeChanged)(float volume);
@property (nonatomic, copy, readwrite, nullable) void(^brightnessChanged)(float brightness);

@property (nonatomic, strong, readonly) UIView *volumeView;
@property (nonatomic, strong, readonly) UIView *brightnessView;

/// 0..1
@property (nonatomic, assign, readwrite) float volume;
/// 0.1..1
@property (nonatomic, assign, readwrite) float brightness;

@end

NS_ASSUME_NONNULL_END
