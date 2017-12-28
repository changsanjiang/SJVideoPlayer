//
//  SJVolBrigControl.h
//  SJVolBrigControl
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJVolBrigControl : NSObject

@property (nonatomic, strong, readonly) UIView *brightnessView;

/// 0..1
@property (nonatomic, assign, readwrite) float volume;
@property (nonatomic, copy, readwrite, nullable) void(^volumeChanged)(float volume);

/// 0.1..1
@property (nonatomic, assign, readwrite) float brightness;
@property (nonatomic, copy, readwrite, nullable) void(^brightnessChanged)(float brightness);

@end

NS_ASSUME_NONNULL_END

