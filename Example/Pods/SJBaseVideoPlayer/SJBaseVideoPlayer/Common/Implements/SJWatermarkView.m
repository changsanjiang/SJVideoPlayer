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
        _height_normal = 20.0;
        _height_fullscreen = 30.0;
        _referPos = SJPosTopLeft;
        _margin_normal = CGPointMake(20, 20);
        _margin_fullscreen = CGPointMake(20, 20);
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
        if (videoDisplayedSize.width > rect.size.width) {
            videoDisplayedSize = CGSizeMake(rect.size.width, vSize.height * rect.size.width / vSize.width);
        }
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
    BOOL isFullScreen = [[UIApplication sharedApplication] statusBarOrientation]==UIInterfaceOrientationPortrait ? NO : YES;
    CGFloat height = isFullScreen ? _height_fullscreen : _height_normal;
    CGFloat paddingX = isFullScreen ? _margin_fullscreen.x : _margin_normal.x;
    CGFloat paddingY = isFullScreen ? _margin_fullscreen.y : _margin_normal.y;
    CGFloat originX = (rect.size.width - videoDisplayedSize.width) * 0.5;
    CGFloat originY = (rect.size.height - videoDisplayedSize.height) * 0.5;
    CGFloat width = (imageSize.width/imageSize.height) * height;
    CGPoint origin = CGPointMake(0, 0);
    NSString *pos = _referPos;
    if ([pos isEqualToString:SJPosTopLeft]) {
        origin = CGPointMake(originX + paddingX, originY + paddingY);
    } else if ([pos isEqualToString:SJPosTopRight]) {
        origin = CGPointMake(originX + videoDisplayedSize.width - paddingX - width, originY + paddingY);
    } else if ([pos isEqualToString:SJPosBottomLeft]) {
        origin = CGPointMake(originX + paddingX, originY + videoDisplayedSize.height - paddingY - height);
    } else if ([pos isEqualToString:SJPosBottomRight]) {
        origin = CGPointMake(originX + videoDisplayedSize.width - paddingX - width, originY + videoDisplayedSize.height - paddingY - height);
    }
    CGRect frame = CGRectMake(origin.x, origin.y, width, height);
    self.frame = frame;
}

@end
