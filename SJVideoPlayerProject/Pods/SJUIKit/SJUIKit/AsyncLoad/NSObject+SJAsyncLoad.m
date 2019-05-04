//
//  NSObject+SJAsyncLoad.m
//  SJUIKit_Example
//
//  Created by BlueDancer on 2018/12/24.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "NSObject+SJAsyncLoad.h"
#import "SJAsyncLoader.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation NSObject (SJAsyncLoad)
- (void)sj_asyncLoad:(id _Nullable(^)(void))loadBlock
              forKey:(NSString *)key {
    [self sj_asyncLoad:loadBlock forKey:key completionHandler:nil];
}

- (void)sj_asyncLoad:(id  _Nullable (^)(void))loadBlock
              forKey:(NSString *)key
   completionHandler:(nullable void(^)(void))completionHandler {
    if ( !loadBlock )
        return;
    __weak typeof(self) _self = self;
    [SJAsyncLoader asyncLoadWithBlock:loadBlock completionHandler:^(id  _Nullable result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self setValue:result forKey:key];
        if ( completionHandler ) completionHandler();
    }];
}
@end
NS_ASSUME_NONNULL_END
