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
@end
NS_ASSUME_NONNULL_END

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
NS_ASSUME_NONNULL_BEGIN
@interface UIImageView (AsyncLoadRoundCornerImage)
/// 四边切圆角
- (void)asyncLoadImageWithURL:(NSURL *)URL cornerRadius:(CGFloat)radius corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(nullable UIColor *)borderColor placeholderImage:(nullable UIImage *)placeholderImage;

/// 切圆
- (void)asyncLoadRoundedImageWithURL:(NSURL *)URL borderWidth:(CGFloat)borderWidth borderColor:(nullable UIColor *)borderColor placeholderImage:(nullable UIImage *)placeholderImage;
@end
NS_ASSUME_NONNULL_END
#endif
