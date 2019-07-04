//
//  SJAVMediaMainPresenter.m
//  Pods
//
//  Created by BlueDancer on 2019/3/28.
//

#import "SJAVMediaMainPresenter.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
/**
 子层
    - 子层一直处于主层下面, 可以插入无数个子层
 
 主层
    - 主层一直处在最高层, 且不会改变, 只会改变content(接管子层的content)
 */
@interface SJAVMediaSubPresenter ()
@property (nonatomic, getter=isReadyForDisplay) BOOL readyForDisplay;
@property (nonatomic, strong, readonly) AVPlayerLayer *playerLayer;
@end
@implementation SJAVMediaSubPresenter
@synthesize readyForDisplay = _readyForDisplay;
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (instancetype)initWithAVPlayer:(AVPlayer *)player {
    self = [self initWithFrame:CGRectZero];
    if ( self ) {
        self.playerLayer.player = player;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        [self.playerLayer addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)dealloc {
    [self.playerLayer removeObserver:self forKeyPath:@"readyForDisplay"];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    self.readyForDisplay = self.playerLayer.isReadyForDisplay;
}

- (void)setVideoGravity:(AVLayerVideoGravity _Nullable)videoGravity {
    [self willChangeValueForKey:@"videoGravity"];
    self.playerLayer.videoGravity = videoGravity;
    [self didChangeValueForKey:@"videoGravity"];
}
- (AVLayerVideoGravity)videoGravity {
    return self.playerLayer.videoGravity?:AVLayerVideoGravityResizeAspect;
}

- (AVPlayer *_Nullable)player {
    return self.playerLayer.player;
}
@end


@interface SJAVMediaPresenterContainer : UIView
@property (nonatomic, strong, readonly) SJAVMediaSubPresenter *presenter;
- (void)resetPresenter:(SJAVMediaSubPresenter *_Nullable)presenter;
@end

@implementation SJAVMediaPresenterContainer {
    SJAVMediaSubPresenter *_Nullable _presenter;
}
- (void)resetPresenter:(SJAVMediaSubPresenter *_Nullable)presenter {
    if ( presenter == _presenter ) return;
    if ( _presenter ) [_presenter removeFromSuperview];
    _presenter = presenter;
    if ( presenter ) {
        presenter.frame = self.bounds;
        presenter.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:presenter];
    }
}
@end


@interface SJAVMediaMainPresenter ()
@property (nonatomic, getter=isReadyForDisplay) BOOL readyForDisplay;
@property (nonatomic, strong, readonly) SJAVMediaPresenterContainer *container;
@end

@implementation SJAVMediaMainPresenter
@synthesize readyForDisplay = _readyForDisplay;
@synthesize videoGravity = _videoGravity;

+ (instancetype)mainPresenter {
    return [[SJAVMediaMainPresenter alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithAVPlayer:(AVPlayer *)player {
    self = [self initWithFrame:CGRectZero];
    if ( self ) {
        [self takeOverSubPresenter:[[SJAVMediaSubPresenter alloc] initWithAVPlayer:player]];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _container = [[SJAVMediaPresenterContainer alloc] init];
        _container.frame = self.bounds;
        _container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_container];
    }
    return self;
}

- (void)setVideoGravity:(AVLayerVideoGravity _Nullable)videoGravity {
    _videoGravity = videoGravity;
    _container.presenter.videoGravity = videoGravity;
}
- (AVLayerVideoGravity)videoGravity {
    return _videoGravity?:AVLayerVideoGravityResizeAspect;
}
- (AVPlayer *_Nullable)player {
    return _container.presenter.player;
}

- (void)insertSubPresenterToBack:(SJAVMediaSubPresenter *)presenter {
    if ( !presenter )
        return;
    presenter.frame = self.bounds;
    presenter.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:presenter atIndex:0];
}
- (void)removeSubPresenter:(SJAVMediaSubPresenter *)presenter {
    if ( !presenter )
        return;
    [presenter removeFromSuperview];
}
- (void)takeOverSubPresenter:(SJAVMediaSubPresenter *)presenter {
    if ( !presenter )
        return;
    
    [self removeSubPresenter:presenter];
    [_container resetPresenter:presenter];
    presenter.videoGravity = _videoGravity;

    // observe `readyForDisplay` of sub presenter
    __weak typeof(self) _self = self;
    sjkvo_observe(presenter, @"readyForDisplay", ^(SJAVMediaSubPresenter *presenter, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.readyForDisplay = presenter.isReadyForDisplay;
    });
}
- (void)removeAllPresenters {
    while ( self.subviews.firstObject != _container ) {
        [self.subviews.firstObject removeFromSuperview];
    }
    [_container resetPresenter:nil];
    self.readyForDisplay = NO;
}
@end
NS_ASSUME_NONNULL_END
