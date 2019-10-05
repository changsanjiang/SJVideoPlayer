//
//  SJAVMediaPresentView.m
//  Pods
//
//  Created by 畅三江 on 2019/10/5.
//

#import "SJAVMediaPresentView.h"

NS_ASSUME_NONNULL_BEGIN
NSNotificationName const SJAVMediaPresentViewReadyForDisplayDidChangeNotification = @"SJAVMediaPresentViewReadyForDisplayDidChangeNotification";

@interface SJAVMediaPresentView ()
@property (nonatomic, getter=isReadyForDisplay) BOOL readyForDisplay;
@property (nonatomic, strong, readonly) AVPlayerLayer *playerLayer;
@property (nonatomic, strong, readonly) AVPlayerLayer *layer;
@end

@implementation SJAVMediaPresentView
@synthesize readyForDisplay = _readyForDisplay;
@dynamic layer;

static NSString *kReadyForDisplay = @"readyForDisplay";
+ (Class)layerClass { return [AVPlayerLayer class]; }
- (instancetype)initWithFrame:(CGRect)frame player:(AVPlayer *)player {
    self = [super initWithFrame:frame];
    if ( self != nil ) {
        NSKeyValueObservingOptions ops = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
        [self.layer addObserver:self forKeyPath:kReadyForDisplay options:ops context:&kReadyForDisplay];
        self.layer.player = player;
    }
    return self;
}

- (void)dealloc {
    [self.layer removeObserver:self forKeyPath:kReadyForDisplay];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( context == &kReadyForDisplay ) {
        [NSNotificationCenter.defaultCenter postNotificationName:SJAVMediaPresentViewReadyForDisplayDidChangeNotification object:self];
    }
}

- (AVPlayer *_Nullable)player {
    return self.layer.player;
}

- (BOOL)isReadyForDisplay {
    return self.layer.isReadyForDisplay;
}

- (void)setVideoGravity:(AVLayerVideoGravity _Nullable)videoGravity {
    self.layer.videoGravity = videoGravity ? : AVLayerVideoGravityResizeAspect;
}

- (AVLayerVideoGravity)videoGravity {
    return self.layer.videoGravity;
}
@end
NS_ASSUME_NONNULL_END
