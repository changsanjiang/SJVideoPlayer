//
//  SJVideoPlayerAnimationHeader.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Block)(void);

extern NSTimeInterval const CommonAnimaDuration;

extern void UIView_Animations(NSTimeInterval duration, Block __nullable animations, Block __nullable completion);
