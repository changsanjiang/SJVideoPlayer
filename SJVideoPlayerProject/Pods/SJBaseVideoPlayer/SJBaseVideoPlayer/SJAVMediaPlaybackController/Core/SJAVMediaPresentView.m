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
@interface _SJAVPlayerLayerPresentView: UIView<SJAVPlayerLayerPresenter>
@property (nonatomic, strong, readonly) AVPlayerLayer *avLayer;
@property (nonatomic, strong, nullable) AVPlayer *player;
@end

@implementation _SJAVPlayerLayerPresentView
@synthesize isReadyForDisplayExeBlock = _isReadyForDisplayExeBlock;

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

static NSString *kReadyForDisplay = @"readyForDisplay";
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self.layer sj_addObserver:self forKeyPath:@"readyForDisplay" context:&kReadyForDisplay];
    return self;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( context == &kReadyForDisplay ) {
        if ( self.avLayer.isReadyForDisplay && _isReadyForDisplayExeBlock )
            _isReadyForDisplayExeBlock(self);
    }
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


@implementation SJAVMediaPresentView
#ifdef SJ_MAC
- (void)dealloc {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
}
#endif

- (id<SJAVPlayerLayerPresenter>)createPresenterForPlayer:(AVPlayer *)player {
    _SJAVPlayerLayerPresentView *view = [[_SJAVPlayerLayerPresentView alloc] initWithFrame:self.bounds];
    view.player = player;
    return view;
}
- (NSArray<_SJAVPlayerLayerPresentView *> *)presenters {
    return self.subviews;
}
- (void)addPresenter:(id<SJAVPlayerLayerPresenter>)presenter {
    [self insertPresenter:presenter atIndex:0];
}
- (void)insertPresenter:(_SJAVPlayerLayerPresentView *)presenter atIndex:(NSInteger)idx {
    if ( idx >= self.presenters.count ) idx = self.presenters.count;
    if ( idx < 0 ) idx = 0;
    presenter.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    presenter.frame = self.bounds;
    [self insertSubview:presenter atIndex:idx];
}
- (void)insertPresenter:(id<SJAVPlayerLayerPresenter>)presenter belowPresenter:(id<SJAVPlayerLayerPresenter>)belowPresenter {
    NSInteger idx = [self.presenters indexOfObject:belowPresenter];
    if ( idx == NSNotFound ) return;
    [self insertPresenter:presenter atIndex:idx];
}
- (void)insertPresenter:(id<SJAVPlayerLayerPresenter>)presenter abovePresenter:(id<SJAVPlayerLayerPresenter>)abovePresenter {
    NSInteger idx = [self.presenters indexOfObject:abovePresenter];
    if ( idx == NSNotFound ) return;
    [self insertPresenter:presenter atIndex:idx + 1];
}
- (void)removePresenter:(_SJAVPlayerLayerPresentView *)presenter {
    [presenter removeFromSuperview];
}
- (void)removeAllPresenter {
    if ( self.presenters.count == 0 ) return;
    [self.presenters enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(_SJAVPlayerLayerPresentView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}
- (void)removeLastPresenter {
    [self.subviews.lastObject removeFromSuperview];
}
- (void)removeAllPresenterAndAddNewPresenter:(id<SJAVPlayerLayerPresenter>)presenter {
    if ( !presenter ) return;
    [self removeAllPresenter];
    [self addPresenter:presenter];
}
@end
NS_ASSUME_NONNULL_END
