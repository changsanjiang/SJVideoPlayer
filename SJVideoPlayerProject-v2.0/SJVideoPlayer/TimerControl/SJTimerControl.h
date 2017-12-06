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
@property (nonatomic, assign, readwrite) float interval;

- (void)start:(void(^)(SJTimerControl *control))block;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
