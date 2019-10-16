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
@property (nonatomic, strong, readonly) AVPlayerLayer *layer;
@end

@implementation SJAVMediaPresentView
@dynamic layer;

static NSString *kReadyForDisplay = @"readyForDisplay";
+ (Class)layerClass { return [AVPlayerLayer class]; }
- (instancetype)initWithFrame:(CGRect)frame { return [self initWithFrame:frame player:nil]; }
- (instancetype)initWithFrame:(CGRect)frame player:(nullable AVPlayer *)player {
    self = [super initWithFrame:frame];
    if ( self != nil ) {
        self.player = player;
        NSKeyValueObservingOptions ops = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
        [self.layer addObserver:self forKeyPath:kReadyForDisplay options:ops context:&kReadyForDisplay];
    }
    return self;
}

- (void)dealloc {
    [self.layer removeObserver:self forKeyPath:kReadyForDisplay];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( context == &kReadyForDisplay ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSNotificationCenter.defaultCenter postNotificationName:SJAVMediaPresentViewReadyForDisplayDidChangeNotification object:self];
        });
    }
}

- (void)setPlayer:(nullable AVPlayer *)player {
    self.layer.player = player;
}
- (nullable AVPlayer *)player {
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
