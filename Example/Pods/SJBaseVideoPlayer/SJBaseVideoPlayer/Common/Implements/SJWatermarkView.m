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
    if (self) {
        _layoutPosition = SJWatermarkLayoutPositionTopRight;
        _layoutInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    }
    return self;
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
        videoDisplayedSize = CGSizeMake(vSize.width * rect.size.height / vSize.height, rect.size.height);
    }
    else if ( videoGravity == AVLayerVideoGravityResizeAspectFill ) {
        videoDisplayedSize = CGSizeMake(rect.size.width, vSize.height * rect.size.width / vSize.width);
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
