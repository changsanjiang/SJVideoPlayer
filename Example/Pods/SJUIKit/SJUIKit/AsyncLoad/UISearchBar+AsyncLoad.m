//
//  UISearchBar+AsyncLoad.m
//  Pods
//
//  Created by BlueDancer on 2019/1/8.
//

#import "UISearchBar+AsyncLoad.h"
#import "SJAsyncLoader.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation UISearchBar (AsyncLoad)
- (void)asyncLoadIconImage:(UIImage *_Nullable(^)(void))imageBlock forSearchBarIcon:(UISearchBarIcon)icon state:(UIControlState)state {
    __weak typeof(self) _self = self;
    [SJAsyncLoader asyncLoadWithBlock:imageBlock completionHandler:^(id  _Nullable result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self setImage:result forSearchBarIcon:icon state:state];
    }];
}

- (void)asyncLoadSearchFieldBackgroundImage:(UIImage *_Nullable(^)(void))imageBlock forState:(UIControlState)state {
    if ( !imageBlock ) return;
    __weak typeof(self) _self = self;
    [SJAsyncLoader asyncLoadWithBlock:imageBlock completionHandler:^(id  _Nullable result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self setSearchFieldBackgroundImage:result forState:state];
    }];
}
@end
NS_ASSUME_NONNULL_END
