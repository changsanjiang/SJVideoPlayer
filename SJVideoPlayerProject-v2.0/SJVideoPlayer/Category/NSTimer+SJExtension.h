//
//  NSTimer+SJExtension.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/6.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (SJExtension)

+ (instancetype)sj_scheduledTimerWithTimeInterval:(NSTimeInterval)ti exeBlock:(void(^)(void))block repeats:(BOOL)yesOrNo;

@end
