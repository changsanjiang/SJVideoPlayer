//
//  MCSLogger.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSLogger.h"
#import <stdarg.h>

@implementation MCSLogger
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
