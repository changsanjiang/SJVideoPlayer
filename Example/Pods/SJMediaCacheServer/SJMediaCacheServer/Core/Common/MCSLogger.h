//
//  MCSLogger.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
#ifdef DEBUG
#define MCSLog(format, arg...)         [MCSLogger.shared addLog:format, ##arg]
#else
#define MCSLog(format, arg...)
#endif

@interface MCSLogger : NSObject
+ (instancetype)shared;

/// If yes, the log will be output on the console. The default value is NO.
@property (nonatomic, getter=isEnabledConsoleLog) BOOL enabledConsoleLog;

- (void)addLog:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
@end

NS_ASSUME_NONNULL_END
