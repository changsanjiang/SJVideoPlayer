//
//  SJPrompt.h
//  SJPromptProject
//
//  Created by BlueDancer on 2017/9/26.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJPromptConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class UIView;

@interface SJPrompt : NSObject

+ (instancetype)promptWithPresentView:(__weak UIView *)presentView;

- (instancetype)initWithPresentView:(__weak UIView *)presentView;

/// update config.
@property (nonatomic, strong, readonly) void(^update)(void(^block)(SJPromptConfig *config));

/// reset config.
- (void)reset;

/*!
 *  duration if value set -1. promptView will always show.
 *
 *  duration 如果设置为 -1, 提示视图将会一直显示.
 */
- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration;

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration hiddenExeBlock:(void(^__nullable)(SJPrompt *prompt))hiddenExeBlock;

- (void)hidden;

- (void)showAttributedString:(NSAttributedString *)attributedString duration:(NSTimeInterval)duration;

- (void)showAttributedString:(NSAttributedString *)attributedString duration:(NSTimeInterval)duration hiddenExeBlock:(void(^__nullable)(SJPrompt *prompt))hiddenExeBlock;

@end

NS_ASSUME_NONNULL_END
