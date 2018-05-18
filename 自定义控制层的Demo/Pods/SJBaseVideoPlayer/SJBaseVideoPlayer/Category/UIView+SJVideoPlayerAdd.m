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
    [self sj_fadeInAndCompletion:nil];
}

- (void)sj_fadeOut {
    [self sj_fadeOutAndCompletion:nil];
}

- (void)sj_fadeInAndCompletion:(void(^)(UIView *view))block {
    self.alpha = 0.001;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        if ( block ) block(self);
    }];
}

- (void)sj_fadeOutAndCompletion:(void(^)(UIView *view))block {
    self.alpha = 1;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.001;
    } completion:^(BOOL finished) {
        if ( block ) block(self);
    }];
}

@end
