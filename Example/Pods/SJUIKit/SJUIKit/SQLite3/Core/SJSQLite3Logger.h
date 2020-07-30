//
//  SJSQLite3Logger.h
//  SJUIKit
//
//  Created by BlueDancer on 2020/7/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJSQLite3Logger : NSObject
+ (instancetype)shared;

/// If yes, the log will be output on the console. The default value is NO.
@property (nonatomic, getter=isEnabledConsoleLog) BOOL enabledConsoleLog;

- (void)addLog:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end

#ifdef DEBUG
#define SJSQLite3Log(format, arg...) \
[SJSQLite3Logger.shared addLog:format, ##arg]

#else
#define SJSQLite3Log(format, arg...)
#endif

NS_ASSUME_NONNULL_END
