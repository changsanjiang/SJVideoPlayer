//
//  SJWatermarkView.m
//  Pods
//
//  Created by BlueDancer on 2020/6/13.
//

#import "SJWatermarkView.h"

@implementation SJWatermarkView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if ( self ) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if ( self ) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    _layoutPosition = SJWatermarkLayoutPositionBottomLeft;
    _layoutInsets = UIEdgeInsetsMake(20, 20, 20, 20);
}

- (void)layoutWatermarkInRect:(CGRect)rect videoPresentationSize:(CGSize)vSize videoGravity:(SJVideoGravity)videoGravity {
    CGSize imageSize = self.image.size;
    self.hidden = CGSizeEqualToSize(vSize, CGSizeZero) ||
                  CGSizeEqualToSize(rect.size, CGSizeZero) ||
                  CGSizeEqualToSize(imageSize, CGSizeZero);
    if ( self.isHidden )
        return;
    
    CGSize videoDisplayedSize = CGSizeZero;
    if      ( videoGravity == AVLayerVideoGravityResizeAspect ) {
        // 等比例模式
        // 16/9 的会将宽度进行等比缩放, 以显示全部高度
        // 9/16 的会将高度进行等比缩放, 以显示全部宽度
        videoDisplayedSize = vSize.width > vSize.height ?
                                CGSizeMake(rect.size.width, vSize.height * rect.size.width / vSize.width) :
                                CGSizeMake(vSize.width * rect.size.height / vSize.height, rect.size.height);
    }
    else if ( videoGravity == AVLayerVideoGravityResizeAspectFill ) {
        // 填充模式
        // 16/9 的会将宽度进行等比拉伸, 以显示全部高度
        // 9/16 的会将高度进行等比拉伸, 以显示全部宽度
        videoDisplayedSize = vSize.width > vSize.height ?
                                CGSizeMake(vSize.width * rect.size.height / vSize.height, rect.size.height) :
                                CGSizeMake(rect.size.width, vSize.height * rect.size.width / vSize.width);
    }
    else if ( videoGravity == AVLayerVideoGravityResizeAspect ) {
        videoDisplayedSize = rect.size;
    }
    
    self.hidden = CGSizeEqualToSize(videoDisplayedSize, CGSizeZero);
    if ( self.isHidden )
        return;
    
    // frame 计算
    CGFloat height = _layoutHeight ?: imageSize.height;
    CGFloat width = imageSize.width * height / imageSize.height;
    CGSize size = CGSizeMake(width, height);
    CGRect frame = (CGRect){0, 0, size};
    switch ( _layoutPosition ) {
        case SJWatermarkLayoutPositionTopLeft:
        case SJWatermarkLayoutPositionBottomLeft:
            frame.origin.x = _layoutInsets.left;
            break;
        case SJWatermarkLayoutPositionTopRight:
        case SJWatermarkLayoutPositionBottomRight:
            frame.origin.x = videoDisplayedSize.width - width - _layoutInsets.right;
            break;
    }
    
    switch ( _layoutPosition ) {
        case SJWatermarkLayoutPositionTopLeft:
        case SJWatermarkLayoutPositionTopRight:
            frame.origin.y = _layoutInsets.top;
            break;
        case SJWatermarkLayoutPositionBottomLeft:
        case SJWatermarkLayoutPositionBottomRight:
            frame.origin.y = videoDisplayedSize.height - height - _layoutInsets.bottom;
            break;
    }
    
    // convert
    frame.origin.x -= (videoDisplayedSize.width - rect.size.width) * 0.5;
    frame.origin.y -= (videoDisplayedSize.height - rect.size.height) * 0.5;
    self.frame = frame;
}

@end
