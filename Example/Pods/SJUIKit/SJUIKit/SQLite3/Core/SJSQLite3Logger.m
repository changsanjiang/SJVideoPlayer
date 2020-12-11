//
//  SJSQLite3Logger.m
//  SJUIKit
//
//  Created by BlueDancer on 2020/7/17.
//

#import "SJSQLite3Logger.h"

@implementation SJSQLite3Logger

+ (instancetype)shared {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)addLog:(NSString *)format, ... {
    if ( format == nil )
        return;
    
    if ( _enabledConsoleLog ) {
        va_list ap;
        va_start(ap, format);
        NSString *string = [NSString.alloc initWithFormat:format arguments:ap];
        va_end(ap);
        
        printf("%s", string.UTF8String);
    }
}

@end
