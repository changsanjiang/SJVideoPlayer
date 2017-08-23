//
//  NSTimer+SJExtention.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/23.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (SJExtention)

+ (instancetype)sj_scheduledTimerWithTimeInterval:(NSTimeInterval)ti exeBlock:(void(^)())block repeats:(BOOL)yesOrNo;

@end
