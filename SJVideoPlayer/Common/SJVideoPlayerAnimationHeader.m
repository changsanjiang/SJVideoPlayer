//
//  SJVideoPlayerAnimationHeader.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/3/21.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "SJVideoPlayerAnimationHeader.h"
#import <UIKit/UIKit.h>

@interface _SJAnimationContext : NSObject
@property (nonatomic, copy, nullable) Block completion;
- (instancetype)initWithCompletion:(nullable Block)completion;
@end

@implementation _SJAnimationContext
- (instancetype)initWithCompletion:(nullable Block)completion {
    self = [super init];
    if ( !self ) return nil;
    _completion = completion;
    return self;
}
- (void)dealloc {
    if ( _completion ) _completion();
}
@end

NSTimeInterval const CommonAnimaDuration = 0.4;

void UIView_Animations(NSTimeInterval duration, Block __nullable animations, Block __nullable completion) {
    [UIView animateWithDuration:duration animations:^{
        if ( animations ) animations();
    } completion:^(BOOL finished) {
        if ( completion ) completion();
    }];
}
