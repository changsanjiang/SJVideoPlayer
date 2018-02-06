//
//  SJTimerControl.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/6.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJTimerControl : NSObject

/// default is 3;
@property (nonatomic, assign, readwrite) short interval;

@property (nonatomic, copy, readwrite, nullable) void(^exeBlock)(SJTimerControl *control);

- (void)start;

- (void)clear;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
