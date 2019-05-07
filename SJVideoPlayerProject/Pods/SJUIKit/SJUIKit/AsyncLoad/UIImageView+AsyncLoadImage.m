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
#import <SDWebImage/SDImageTransformer.h>
#import <SDWebImage/UIImage+Transform.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJImageRoundCornerTransformer : SDImageRoundCornerTransformer
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) SDRectCorner corners;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong, nullable) UIColor *borderColor;
@end

@implementation SJImageRoundCornerTransformer
@dynamic cornerRadius, corners, borderWidth, borderColor;
+ (instancetype)transformerWithRadius:(CGFloat)cornerRadius corners:(SDRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor *_Nullable)borderColor {
    SJImageRoundCornerTransformer *transformer = [SJImageRoundCornerTransformer new];
    transformer.cornerRadius = cornerRadius;
    transformer.corners = corners;
    transformer.borderWidth = borderWidth;
    transformer.borderColor = borderColor;
    return transformer;
}
- (nullable UIImage *)transformedImageWithImage:(nonnull UIImage *)image forKey:(nonnull NSString *)key {
    if ( !image )
        return nil;
    CGSize size = image.size;
    return [image sd_roundedCornerImageWithRadius:self.cornerRadius * MIN(size.width, size.height) corners:self.corners borderWidth:self.borderWidth borderColor:self.borderColor];
}
@end

@interface SJImageFittingSizeTransformer : NSObject<SDImageTransformer>
- (instancetype)initWithView:(UIView *)view;
@property (nonatomic, weak, readonly, nullable) UIView *view;
@end

@implementation SJImageFittingSizeTransformer
- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if ( self ) {
        _view = view;
    }
    return self;
}
- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"SJImageFittingSizeTransformer(%f, %f)", ceil(_view.bounds.size.width), ceil(_view.bounds.size.height)];
}

- (nullable UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image sd_resizedImageWithSize:_view.bounds.size scaleMode:SDImageScaleModeAspectFill];
}
@end

@implementation UIImageView (AsyncLoadRoundCornerImage)
/// - radius: 请填百分比
- (void)asyncLoadImageWithURL:(NSURL *)URL cornerRadius:(float)radius corners:(SDRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor * _Nullable)borderColor {
    [self sd_setImageWithURL:URL placeholderImage:nil options:SDWebImageDelayPlaceholder context:@{SDWebImageContextImageTransformer:[SJImageRoundCornerTransformer transformerWithRadius:radius corners:corners borderWidth:borderWidth borderColor:borderColor]}];
}
@end
NS_ASSUME_NONNULL_END
#endif
