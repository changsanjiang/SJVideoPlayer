//
//  UIButton+AsyncLoadImage.m
//  SJUIKit_Example
//
//  Created by BlueDancer on 2018/12/14.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "UIButton+AsyncLoadImage.h"
#import "SJAsyncLoader.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation UIButton (AsyncLoadImage)
- (void)asyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock
              forState:(UIControlState)state {
    [self asyncLoadImage:imageBlock forState:state placeholderImage:nil];
}

- (void)asyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock
              forState:(UIControlState)state
      placeholderImage:(UIImage *_Nullable)placeholderImage {
    if ( !imageBlock ) return;
    if ( placeholderImage ) [self setImage:placeholderImage forState:state];
    __weak typeof(self) _self = self;
    [SJAsyncLoader asyncLoadWithBlock:imageBlock completionHandler:^(id  _Nullable result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self setImage:result forState:state];
    }];
}

- (void)asyncLoadBackgroundImage:(UIImage *_Nullable(^)(void))imageBlock
                        forState:(UIControlState)state {
    [self asyncLoadBackgroundImage:imageBlock forState:state placeholderImage:nil];
}

- (void)asyncLoadBackgroundImage:(UIImage *_Nullable(^)(void))imageBlock
                        forState:(UIControlState)state
                placeholderImage:(UIImage *_Nullable)placeholderImage {
    if ( !imageBlock ) return;
    if ( placeholderImage ) [self setBackgroundImage:placeholderImage forState:state];
    __weak typeof(self) _self = self;
    [SJAsyncLoader asyncLoadWithBlock:imageBlock completionHandler:^(id  _Nullable result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self setBackgroundImage:result forState:state];
    }];
}

- (void)asyncLoadAttributedString:(NSAttributedString *_Nullable(^)(void))attributedStringBlock
                         forState:(UIControlState)state {
    if ( !attributedStringBlock ) return;
    __weak typeof(self) _self = self;
    [SJAsyncLoader asyncLoadWithBlock:attributedStringBlock completionHandler:^(id  _Nullable result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self setAttributedTitle:result forState:state];
    }];
}
@end
NS_ASSUME_NONNULL_END
