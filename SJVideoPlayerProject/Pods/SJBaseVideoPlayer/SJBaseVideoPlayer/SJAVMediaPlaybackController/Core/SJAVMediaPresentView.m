//
//  SJAVMediaPresentView.m
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2018/11/25.
//

#import "SJAVMediaPresentView.h"
#if __has_include(<SJObserverHelper/NSObject+SJObserverHelper.h>)
#import <SJObserverHelper/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJAVPlayerLayerPresenter: UIView<SJAVPlayerLayerPresenter>
@property (nonatomic, strong, null_resettable) AVLayerVideoGravity videoGravity;
@end

@interface SJAVPlayerLayerPresenterObserver : NSObject<SJAVPlayerLayerPresenterObserver>
- (instancetype)initWithPresenter:(SJAVPlayerLayerPresenter *)presenter;
@property (nonatomic, weak, readonly, nullable) SJAVPlayerLayerPresenter *presenter;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

@implementation SJAVPlayerLayerPresenterObserver
@synthesize isReadyForDisplayExeBlock = _isReadyForDisplayExeBlock;

static NSString *kReadyForDisplay = @"readyForDisplay";
- (instancetype)initWithPresenter:(SJAVPlayerLayerPresenter *)presenter {
    self = [super init];
    if ( !self ) return nil;
    _presenter = presenter;
    [presenter.layer sj_addObserver:self forKeyPath:@"readyForDisplay" context:&kReadyForDisplay];
    return self;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( context == &kReadyForDisplay ) {
        AVPlayerLayer *layer = object;
        if ( layer.isReadyForDisplay && _isReadyForDisplayExeBlock )
            _isReadyForDisplayExeBlock(_presenter);
    }
}
@end

@implementation SJAVPlayerLayerPresenter
@synthesize readyForDisplay = _readyForDisplay;
@synthesize player = _player;

#ifdef SJ_MAC
- (void)dealloc {
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), __func__);
}
#endif

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)avLayer {
    return (AVPlayerLayer *)self.layer;
}

- (void)setPlayer:(nullable AVPlayer *)player {
    if ( player == self.avLayer.player ) return;
    self.avLayer.player = player;
}

- (nullable AVPlayer *)player {
    return self.avLayer.player;
}

- (BOOL)isReadyForDisplay {
    return [self avLayer].isReadyForDisplay;
}

- (id<SJAVPlayerLayerPresenterObserver>)getObserver {
    return [[SJAVPlayerLayerPresenterObserver alloc] initWithPresenter:self];
}

- (UIView *)view {
    return self;
}

@synthesize videoGravity = _videoGravity;
- (void)setVideoGravity:(AVLayerVideoGravity _Nullable)videoGravity {
    _videoGravity = videoGravity;
    self.avLayer.videoGravity = self.videoGravity;
}

- (AVLayerVideoGravity)videoGravity {
    if ( !_videoGravity ) return AVLayerVideoGravityResizeAspect;
    return _videoGravity;
}
@end



@interface SJAVMediaPresentView ()

@end

@implementation SJAVMediaPresentView
#ifdef SJ_MAC
- (void)dealloc {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
}
#endif

@synthesize mainPresenter = _mainPresenter;
- (id<SJAVPlayerLayerPresenter>)mainPresenter {
    if ( !_mainPresenter ) {
        SJAVPlayerLayerPresenter *main = [[SJAVPlayerLayerPresenter alloc] initWithFrame:self.bounds];
        main.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:main];
        main.videoGravity = self.videoGravity;
        _mainPresenter = main;
    }
    return _mainPresenter;
}

@synthesize subPresenter = _subPresenter;
- (id<SJAVPlayerLayerPresenter>)subPresenter {
    if ( !_subPresenter ) {
        SJAVPlayerLayerPresenter *sub = [[SJAVPlayerLayerPresenter alloc] initWithFrame:self.bounds];
        sub.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:sub belowSubview:(id)self.mainPresenter];
        sub.videoGravity = self.videoGravity;
        _subPresenter = sub;
    }
    return _subPresenter;
}

@synthesize videoGravity = _videoGravity;
- (void)setVideoGravity:(AVLayerVideoGravity _Nullable)videoGravity {
    _videoGravity = videoGravity;
    [(SJAVPlayerLayerPresenter *)_mainPresenter setVideoGravity:videoGravity];
    [(SJAVPlayerLayerPresenter *)_subPresenter setVideoGravity:videoGravity];
}

- (AVLayerVideoGravity)videoGravity {
    if ( !_videoGravity ) return AVLayerVideoGravityResizeAspect;
    return _videoGravity;
}

- (void)exchangePresenter {
    SJAVPlayerLayerPresenter *main = (id)_mainPresenter;
    SJAVPlayerLayerPresenter *sub = (id)_subPresenter;
    
    _mainPresenter = sub;
    _subPresenter = main;
    
    [self exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
}

- (void)reset {
    [self resetMainPresenter];
    [self resetSubPresenter];
}

- (void)resetMainPresenter {
    _mainPresenter.player = nil;
}

- (void)resetSubPresenter {
    _subPresenter.player = nil;
}
@end
NS_ASSUME_NONNULL_END
