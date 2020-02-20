//
//  UIButton+AsyncLoadImage.h
//  SJUIKit_Example
//
//  Created by 畅三江 on 2018/12/14.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIButton (AsyncLoadImage)
- (void)asyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock
              forState:(UIControlState)state;

- (void)asyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock
              forState:(UIControlState)state
      placeholderImage:(UIImage *_Nullable)placeholderImage;

- (void)asyncLoadBackgroundImage:(UIImage *_Nullable(^)(void))imageBlock
                        forState:(UIControlState)state;

- (void)asyncLoadBackgroundImage:(UIImage *_Nullable(^)(void))imageBlock
                        forState:(UIControlState)state
                placeholderImage:(UIImage *_Nullable)placeholderImage;

- (void)asyncLoadAttributedString:(NSAttributedString *_Nullable(^)(void))attributedStringBlock
                         forState:(UIControlState)state;
@end
NS_ASSUME_NONNULL_END
