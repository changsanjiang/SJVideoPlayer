//
//  NSDate+SJAdded.m
//  SJUIKit
//
//  Created by 畅三江 on 2018/12/23.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "NSDate+SJAdded.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSDate (SJAdded)
- (NSString *)sj_yyyy_MM_dd_HH_mm_ss {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        //        RFC3339DateFormatter = [[NSDateFormatter alloc] init];
        //        RFC3339DateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        //        RFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        //        RFC3339DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        //
        //        /* 39 minutes and 57 seconds after the 16th hour of December 19th, 1996 with an offset of -08:00 from UTC (Pacific Standard Time) */
        //        NSString *string = @"1996-12-19T16:39:57-08:00";
        //        NSDate *date = [RFC3339DateFormatter dateFromString:string];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    });
    return [dateFormatter stringFromDate:self];
}
- (NSString *)sj_yyyy_MM_dd_HH_mm {
    return [self.sj_yyyy_MM_dd_HH_mm_ss substringToIndex:16];
}
- (NSString *)sj_yyyy_MM_dd {
    return [self.sj_yyyy_MM_dd_HH_mm_ss substringToIndex:10];
}
- (NSString *)sj_HH_mm_ss {
    return [self.sj_yyyy_MM_dd_HH_mm_ss substringFromIndex:11];
}
- (NSString *)sj_yyyy {
    return [self.sj_yyyy_MM_dd substringToIndex:4];
}
- (NSString *)sj_MM {
    return [self.sj_yyyy_MM_dd substringWithRange:NSMakeRange(5, 2)];
}
- (NSString *)sj_dd {
    return [self.sj_yyyy_MM_dd substringWithRange:NSMakeRange(8, 2)];
}
- (NSString *)sj_HH {
    return [self.sj_HH_mm_ss substringWithRange:NSMakeRange(0, 2)];
}
- (NSString *)sj_mm {
    return [self.sj_HH_mm_ss substringWithRange:NSMakeRange(3, 2)];
}
- (NSString *)sj_ss {
    return [self.sj_HH_mm_ss substringWithRange:NSMakeRange(6, 2)];
}
@end
NS_ASSUME_NONNULL_END
