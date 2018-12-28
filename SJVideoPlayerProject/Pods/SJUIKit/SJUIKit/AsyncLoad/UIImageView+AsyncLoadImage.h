//
//  UIImageView+AsyncLoadImage.h
//  SJObjective-CTool_Example
//
//  Created by 畅三江 on 2016/5/28.
//  Copyright © 2018年 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIImageView (AsyncLoadImage)

+ (instancetype)imageViewWithAsyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock;

+ (instancetype)imageViewWithAsyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock
                                    viewMode:(UIViewContentMode)viewMode;

+ (instancetype)imageViewWithAsyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock
                                    viewMode:(UIViewContentMode)viewMode
                             backgroundColor:(UIColor *_Nullable)color;

+ (instancetype)imageViewWithAsyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock
                                   viewMode:(UIViewContentMode)viewMode
                           placeholderImage:(UIImage *_Nullable)placeholderImage;

- (void)asyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock;

- (void)asyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock placeholderImage:(UIImage *_Nullable)placeholderImage;

- (void)cancelPreviousLoadRequest;

@end
NS_ASSUME_NONNULL_END
