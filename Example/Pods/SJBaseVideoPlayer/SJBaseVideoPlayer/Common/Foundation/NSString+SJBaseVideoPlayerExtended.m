//
//  NSString+SJBaseVideoPlayerExtended.m
//  Pods
//
//  Created by 畅三江 on 2019/12/12.
//

#import "NSString+SJBaseVideoPlayerExtended.h"

NS_ASSUME_NONNULL_BEGIN
@implementation NSString (SJBaseVideoPlayerExtended)

///
/// 将当前时间转为字符串格式
///
///     e.g.
///     
///         @"12:12"       => duration 小于1个小时
///
///         @"00:12:12"    => duration 大于1个小时
///
///         @"12:12:12"    => duration 大于1个小时
///
///         @"123:12:12"   => duration 大于24个小时
///
+ (instancetype)stringWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    long min = 60;
    long hour = 60 * min;
    
    long hours, seconds, minutes;
    hours = currentTime / hour;
    minutes = (currentTime - hours * hour) / 60;
    seconds = (NSInteger)currentTime % 60;
    if ( duration < hour ) {
        return [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
    }
    else if ( hours < 100 ) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
    }
    else {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", hours, minutes, seconds];
    }
}
@end
NS_ASSUME_NONNULL_END
