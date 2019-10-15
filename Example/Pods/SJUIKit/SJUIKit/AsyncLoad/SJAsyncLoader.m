//
//  SJAsyncLoader.m
//  SJUIKit_Example
//
//  Created by BlueDancer on 2018/12/21.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "SJAsyncLoader.h"

@implementation SJAsyncLoader
+ (void)asyncLoadWithBlock:(id _Nullable(^)(void))loadBlock completionHandler:(void(^)(id _Nullable result))completionHandler {
    static dispatch_queue_t _queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _queue = dispatch_queue_create("com.SJUIKit.AsyncLoad", DISPATCH_QUEUE_SERIAL);
    });
    dispatch_async(_queue, ^{
        id result = loadBlock();
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completionHandler ) completionHandler(result);
        });
    });
}
@end
