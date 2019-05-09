//
//  UIImageView+AsyncLoadImage.h
//  SJObjective-CTool_Example
//
//  Created by 畅三江 on 2016/5/28.
//  Copyright © 2018年 changsanjiang@gmail.com. All rights reserved.
//

#import "UIImageView+AsyncLoadImage.h"
#import <objc/message.h>
#import "SJAsyncLoader.h"

NS_ASSUME_NONNULL_BEGIN
@implementation UIImageView (AsyncLoadImage)
+ (instancetype)imageViewWithAsyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock {
    return [self imageViewWithAsyncLoadImage:imageBlock viewMode:UIViewContentModeScaleAspectFit];
}

+ (instancetype)imageViewWithAsyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock
                                   viewMode:(UIViewContentMode)viewMode {
    return [self imageViewWithAsyncLoadImage:imageBlock viewMode:viewMode backgroundColor:nil];
}

+ (instancetype)imageViewWithAsyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock
                                   viewMode:(UIViewContentMode)viewMode
                            backgroundColor:(UIColor *_Nullable)color {
    UIImageView *imageView = [self imageViewWithAsyncLoadImage:imageBlock viewMode:viewMode placeholderImage:nil];
    imageView.backgroundColor = color;
    return imageView;
}

+ (instancetype)imageViewWithAsyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock
                                   viewMode:(UIViewContentMode)viewMode
                           placeholderImage:(UIImage *_Nullable)placeholderImage {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = viewMode;
    imageView.clipsToBounds = YES;
    imageView.image = placeholderImage;
    [imageView asyncLoadImage:imageBlock];
    return imageView;
}

- (void)asyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock {
    [self asyncLoadImage:imageBlock placeholderImage:nil];
}

- (void)asyncLoadImage:(UIImage *_Nullable(^)(void))imageBlock placeholderImage:(UIImage *_Nullable)placeholderImage {
    if ( !imageBlock ) return;
    if ( placeholderImage ) self.image = placeholderImage;
    __weak typeof(self) _self = self;
    [SJAsyncLoader asyncLoadWithBlock:imageBlock completionHandler:^(id  _Nullable result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.image = result;
    }];
}
@end
NS_ASSUME_NONNULL_END

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#import "SJCornerMask.h"
NS_ASSUME_NONNULL_BEGIN
@implementation UIImageView (AsyncLoadRoundCornerImage)
- (void)asyncLoadImageWithURL:(NSURL *)URL cornerRadius:(CGFloat)radius corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(nullable UIColor *)borderColor placeholderImage:(nullable UIImage *)placeholderImage {
    [self sd_setImageWithURL:URL placeholderImage:placeholderImage];
    SJCornerMaskSetRectCorner(self, corners, radius, borderWidth, borderColor);
}

- (void)asyncLoadRoundedImageWithURL:(NSURL *)URL borderWidth:(CGFloat)borderWidth borderColor:(nullable UIColor *)borderColor placeholderImage:(nullable UIImage *)placeholderImage {
    [self sd_setImageWithURL:URL placeholderImage:placeholderImage];
    SJCornerMaskSetRound(self, borderWidth, borderColor);
}
@end
NS_ASSUME_NONNULL_END
#endif
