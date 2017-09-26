//
//  SJPrompt.h
//  SJPromptProject
//
//  Created by BlueDancer on 2017/9/26.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView;

@interface SJPrompt : NSObject

+ (instancetype)promptWithPresentView:(UIView *)presentView;

/*!
 *  duration if value set -1. promptView will always show.
 */
- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration;

- (void)hidden;

@end

