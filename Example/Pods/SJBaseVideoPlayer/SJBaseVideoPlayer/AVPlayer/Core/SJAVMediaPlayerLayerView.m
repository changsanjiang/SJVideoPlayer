//
//  SJAVMediaPlayerLayerView.m
//  Pods
//
//  Created by 畅三江 on 2020/2/19.
//

#import "SJAVMediaPlayerLayerView.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlayerLayerView ()
@property (nonatomic, strong) CALayer *screenshotLayer;
@end

@implementation SJAVMediaPlayerLayerView
@dynamic layer;

+ (Class)layerClass {
    return AVPlayerLayer.class;
}

static NSString *kReadyForDisplay = @"readyForDisplay";

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        NSKeyValueObservingOptions ops = NSKeyValueObservingOptionNew;
        [self.layer addObserver:self forKeyPath:kReadyForDisplay options:ops context:&kReadyForDisplay];
        
        _screenshotLayer = [CALayer.alloc init];
        [self.layer addSublayer:_screenshotLayer];
    }
    return self;
}

- (BOOL)isReadyForDisplay {
    return self.layer.isReadyForDisplay;
}

- (void)setVideoGravity:(SJVideoGravity)videoGravity {
    self.layer.videoGravity = videoGravity;
    if      ( videoGravity == AVLayerVideoGravityResize ) {
        _screenshotLayer.contentsGravity = kCAGravityResize;
    }
    else if ( videoGravity == AVLayerVideoGravityResizeAspect ) {
        _screenshotLayer.contentsGravity = kCAGravityResizeAspect;
    }
    else if ( videoGravity == AVLayerVideoGravityResizeAspectFill ) {
        _screenshotLayer.contentsGravity = kCAGravityResizeAspectFill;
    }
}

- (SJVideoGravity)videoGravity {
    return self.layer.videoGravity;
}

- (void)setScreenshot:(nullable UIImage *)image {
    _screenshotLayer.contents = image != nil ? (__bridge id)(image.CGImage) : nil;
}

- (void)dealloc {
    [self.layer removeObserver:self forKeyPath:kReadyForDisplay];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( context == &kReadyForDisplay ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSNotificationCenter.defaultCenter postNotificationName:SJMediaPlayerViewReadyForDisplayNotification object:self];
        });
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _screenshotLayer.frame = self.bounds;
}
@end
NS_ASSUME_NONNULL_END
