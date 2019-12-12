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
+ (NSTimer *)sj_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats;
+ (NSTimer *)sj_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats usingBlock:(void(^_Nullable)(NSTimer *timer))usingBlock;

@property (nonatomic, copy, nullable) void (^sj_usingBlock)(NSTimer *timer);

- (void)sj_fire;
@end


///
/// 已弃用
///
@interface NSTimer (SJDeprecated)
+ (NSTimer *)assetAdd_timerWithTimeInterval:(NSTimeInterval)ti
                                      block:(void(^)(NSTimer *timer))block
                                    repeats:(BOOL)repeats;
- (void)assetAdd_fire;
@end
NS_ASSUME_NONNULL_END
