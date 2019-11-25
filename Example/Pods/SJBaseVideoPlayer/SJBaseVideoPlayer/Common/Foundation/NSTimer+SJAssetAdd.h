//
//  NSTimer+SJAssetAdd.h
//  SJVideoPlayerAssetCarrier
//
//  Created by 畅三江 on 2018/5/21.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSTimer (SJAssetAdd)

+ (NSTimer *)assetAdd_timerWithTimeInterval:(NSTimeInterval)ti
                                      block:(void(^)(NSTimer *timer))block
                                    repeats:(BOOL)repeats;
- (void)assetAdd_fire;

@end
NS_ASSUME_NONNULL_END
