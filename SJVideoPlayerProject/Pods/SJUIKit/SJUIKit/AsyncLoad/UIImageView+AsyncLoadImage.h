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
#import <SDWebImage/UIImage+Transform.h>
NS_ASSUME_NONNULL_BEGIN
@interface UIImageView (AsyncLoadRoundCornerImage)
/// - radius: 请填百分比, 例如视图宽高为10, 切圆角2, 则填 2/10.0
- (void)asyncLoadImageWithURL:(NSURL *)URL cornerRadius:(float)radius corners:(SDRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(nullable UIColor *)borderColor;
@end
NS_ASSUME_NONNULL_END
#endif
