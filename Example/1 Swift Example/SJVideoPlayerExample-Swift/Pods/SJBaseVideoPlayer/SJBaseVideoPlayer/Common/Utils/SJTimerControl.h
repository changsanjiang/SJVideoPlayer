//
//  SJTimerControl.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2017/12/6.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJTimerControl : NSObject

/// default is 3;
@property (nonatomic) NSTimeInterval interval;

@property (nonatomic, copy, nullable) void(^exeBlock)(SJTimerControl *control);

- (void)start;

- (void)clear;

@end
NS_ASSUME_NONNULL_END
