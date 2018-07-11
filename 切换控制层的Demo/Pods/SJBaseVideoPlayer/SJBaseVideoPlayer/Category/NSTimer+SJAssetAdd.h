//
//  NSTimer+SJAssetAdd.h
//  SJVideoPlayerAssetCarrier
//
//  Created by BlueDancer on 2018/5/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (SJAssetAdd)

+ (NSTimer *)assetAdd_timerWithTimeInterval:(NSTimeInterval)ti
                                      block:(void(^)(NSTimer *timer))block
                                    repeats:(BOOL)repeats;
- (void)assetAdd_fire;

@end
