//
//  UITextField+AsyncLoadImage.m
//  LWZBarrageKit
//
//  Created by BlueDancer on 2019/9/9.
//

#import "UITextField+AsyncLoadImage.h"
#import "SJAsyncLoader.h"

@implementation UITextField (AsyncLoadImage)

- (void)asyncLoadBackgroundImage:(UIImage *_Nullable(^)(void))imageBlock {
    if ( imageBlock != nil ) {
        __weak typeof(self) _self = self;
        [SJAsyncLoader asyncLoadWithBlock:imageBlock completionHandler:^(id  _Nullable result) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.background = result;
        }];
    }
}

@end
