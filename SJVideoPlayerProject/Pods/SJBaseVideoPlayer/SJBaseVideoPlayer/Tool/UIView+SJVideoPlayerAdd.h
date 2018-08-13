//
//  UIView+SJVideoPlayerAdd.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SJVideoPlayerAdd)

- (void)sj_fadeIn;

- (void)sj_fadeOut;

- (void)sj_fadeInAndCompletion:(void(^)(UIView *view))block;

- (void)sj_fadeOutAndCompletion:(void(^)(UIView *view))block;

@end
