//
//  MCSLogger.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSLogger.h"
#import <SJUIKit/SJSQLite3Logger.h>
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

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _options = MCSLogOptionDefault;
    }
    return self;
}

- (void)setOptions:(MCSLogOptions)options {
    _options = options;
    SJSQLite3Logger.shared.enabledConsoleLog = options & MCSLogOptionSQLite;
}

- (void)option:(MCSLogOptions)option level:(MCSLogLevel)level addLog:(NSString *)format, ... NS_FORMAT_FUNCTION(3,4) {
    if ( format == nil ) return;
    if ( level < _level ) return;
    
    if ( _enabledConsoleLog && (option & _options) ) {
        va_list ap;
        va_start(ap, format);
        NSString *string = [NSString.alloc initWithFormat:format arguments:ap];
        va_end(ap);
        
        printf("%s", string.UTF8String);
    }
}
@end
