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
static char SJAsyncImageLoaderKey_Normal;
static char SJAsyncImageLoaderKey_High;
static char SJAsyncImageLoaderKey_Disabled;
static char SJAsyncImageLoaderKey_Selected;
static char SJAsyncImageLoaderKey_Default;

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
    SJAsyncLoader *loader = [[SJAsyncLoader alloc] initWithBlock:imageBlock completionHandler:^(id  _Nullable result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self setImage:result forState:state];
    }];
    objc_setAssociatedObject(self, _getKey(state), loader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)asyncLoadAttributedString:(NSAttributedString *_Nullable(^)(void))attributedStringBlock
                         forState:(UIControlState)state {
    if ( !attributedStringBlock ) return;
    __weak typeof(self) _self = self;
    SJAsyncLoader *loader = [[SJAsyncLoader alloc] initWithBlock:attributedStringBlock completionHandler:^(id  _Nullable result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self setAttributedTitle:result forState:state];
    }];
    objc_setAssociatedObject(self, _getKey(state), loader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void *_getKey(UIControlState state) {
    void *p = &SJAsyncImageLoaderKey_Default;
    switch ( state ) {
        case UIControlStateNormal: {
            p = &SJAsyncImageLoaderKey_Normal;
        }
            break;
        case UIControlStateHighlighted: {
            p = &SJAsyncImageLoaderKey_High;
        }
            break;
        case UIControlStateDisabled: {
            p = &SJAsyncImageLoaderKey_Disabled;
        }
            break;
        case UIControlStateSelected: {
            p = &SJAsyncImageLoaderKey_Selected;
        }
            break;
        default:
            break;
    }
    return p;
}
@end
NS_ASSUME_NONNULL_END
