//
//  UIView+SJVideoPlayerAdd.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "UIView+SJVideoPlayerAdd.h"

@implementation UIView (SJVideoPlayerAdd)

- (void)sj_fadeIn {
    [self sj_fadeInWithCompletion:nil];
}

- (void)sj_fadeOut {
    [self sj_fadeOutWithCompletion:nil];
}

- (void)sj_fadeInWithCompletion:(void(^)(UIView *view))block {
    self.alpha = 0.001;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        if ( block ) block(self);
    }];
}

- (void)sj_fadeOutWithCompletion:(void(^)(UIView *view))block {
    self.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.001;
    } completion:^(BOOL finished) {
        if ( block ) block(self);
    }];
}

@end
