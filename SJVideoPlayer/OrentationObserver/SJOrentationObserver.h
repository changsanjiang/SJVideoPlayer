//
//  SJOrentationObserver.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJOrentationObserver : NSObject

- (instancetype)initWithTarget:(__weak UIView *)view container:(__weak UIView *)targetSuperview;

@property (nonatomic, assign, readonly, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, copy, readwrite, nullable) void(^orientationChanged)(SJOrentationObserver *observer);

@property (nonatomic, copy, readwrite, nullable) BOOL(^rotationCondition)(SJOrentationObserver *observer);

- (BOOL)_changeOrientation;

@end

NS_ASSUME_NONNULL_END
