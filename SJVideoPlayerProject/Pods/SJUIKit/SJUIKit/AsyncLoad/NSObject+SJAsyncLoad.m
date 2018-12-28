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
static char AsyncLoadKey;
- (void)sj_asyncLoad:(id _Nullable(^)(void))loadBlock
              forKey:(NSString *)key {
    if ( !loadBlock )
        return;
    __weak typeof(self) _self = self;
    SJAsyncLoader *loader = [[SJAsyncLoader alloc] initWithBlock:loadBlock completionHandler:^(id  _Nullable result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self setValue:result forKey:key];
    }];
    objc_setAssociatedObject(self, &AsyncLoadKey, loader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
NS_ASSUME_NONNULL_END
