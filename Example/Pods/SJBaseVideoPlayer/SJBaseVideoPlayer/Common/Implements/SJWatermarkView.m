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
        _margin = 20.0;
    }
    return self;
}

- (void)layoutWatermarkInRect:(CGRect)rect videoPresentationSize:(CGSize)vSize videoGravity:(SJVideoGravity)videoGravity {
    self.hidden = CGSizeEqualToSize(vSize, CGSizeZero) ||
                  CGSizeEqualToSize(rect.size, CGSizeZero) ||
                  CGSizeEqualToSize(self.image.size, CGSizeZero);
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
    
    CGSize imageSize = self.image.size;
    CGFloat margin = _margin;
    CGFloat topMargin = (rect.size.height - videoDisplayedSize.height) * 0.5 + margin;
    CGFloat rightMargin = margin + (rect.size.width - videoDisplayedSize.width) * 0.5;

    self.frame = (CGRect){rect.size.width - imageSize.width - rightMargin, topMargin, imageSize};
}

@end
