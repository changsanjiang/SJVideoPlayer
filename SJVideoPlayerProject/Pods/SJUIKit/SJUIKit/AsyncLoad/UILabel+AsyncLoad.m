//
//  UILabel+AsyncLoad.m
//  SJUIKit_Example
//
//  Created by BlueDancer on 2018/12/22.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "UILabel+AsyncLoad.h"
#import "SJAsyncLoader.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation UILabel (AsyncLoad)
- (void)asyncLoadAttributedString:(NSAttributedString *_Nullable(^)(void))attributedStringBlock {
    if ( !attributedStringBlock )
        return;
    __weak typeof(self) _self = self;
    [SJAsyncLoader asyncLoadWithBlock:attributedStringBlock completionHandler:^(id  _Nullable result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.attributedText = result;
    }];
}
@end
NS_ASSUME_NONNULL_END
