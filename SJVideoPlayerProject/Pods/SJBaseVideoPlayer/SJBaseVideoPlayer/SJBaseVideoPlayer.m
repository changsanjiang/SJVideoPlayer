//
//  SJBaseVideoPlayer.m
//  SJBaseVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJBaseVideoPlayer.h"
#import <SJVideoPlayerAssetCarrier/SJVideoPlayerAssetCarrier.h>
#import <Masonry/Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import <SJOrentationObserver/SJOrentationObserver.h>
#import "SJPlayerGestureControl.h"
#import <SJVolBrigControl/SJVolBrigControl.h>
#import "UIView+SJVideoPlayerAdd.h"
#import <objc/message.h>
#import <SJObserverHelper/NSObject+SJObserverHelper.h>
#import "SJVideoPlayerRegistrar.h"
#import "SJVideoPlayerPresentView.h"

@interface SJVideoPlayerAssetCarrier (SJBaseVideoPlayerAdd)
/**
 视频的真实大小, 播放未准备好之前或者播放音频时该值为CGSizeZero.
 */
@property (nonatomic, assign) CGSize videoPresentationSize;
@end

@implementation SJVideoPlayerAssetCarrier (SJBaseVideoPlayerAdd)
- (void)setVideoPresentationSize:(CGSize)videoPresentationSize {
    objc_setAssociatedObject(self, @selector(videoPresentationSize), [NSValue valueWithCGSize:videoPresentationSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGSize)videoPresentationSize {
    return [objc_getAssociatedObject(self, _cmd) CGSizeValue];
}
@end


@interface SJBaseVideoPlayerView: UIView
@property (nonatomic, copy, nullable) void(^layoutSubViewsExeBlock)(SJBaseVideoPlayerView *view);
@end

@implementation SJBaseVideoPlayerView
- (void)layoutSubviews {
    [super layoutSubviews];
    if ( _layoutSubViewsExeBlock ) _layoutSubViewsExeBlock(self);
}
@end

#pragma mark -

NS_ASSUME_NONNULL_BEGIN

/**
 管理类: 控制层显示与隐藏
 */
@interface _SJControlLayerAppearStateManager : NSObject

/**
 初始化构造方法
 */
- (instancetype)initWithVideoPlayer:(SJBaseVideoPlayer *)videoPlayer;

/**
 是否开启管理类去管理控制层的显示与隐藏. 见 `videoPlayer.enableControlLayerDisplayController`
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

/**
 控制层的显示状态. YES -> appear, NO -> disappear.
 */
@property (nonatomic, readonly) BOOL controlLayerAppearedState;

/**
 在视频第一次播放之前, 控制层会默认在1秒后显示. 如果在这1秒期间, 用户点击触发显示控制层, 则这个值为YES. 否则1秒显示控制层后, 才会设置这个值为YES.
 这个属性用于是否1秒后显示控制层.
 */
@property (nonatomic, readonly) BOOL initialization;

/**
 当单击手势触发时, 会调用这个方法. 考虑是否显示或隐藏控制层, 或不做任何事情.
 */
- (void)considerChangeState;

/**
 在`self.enabled == YES`的情况下, 立即显示控制层.
 */
- (void)layerAppear;

/**
 在`self.enabled == YES`的情况下, 立即隐藏控制层.
 */
- (void)layerDisappear;

/**
 重置`self.initialization`, 当播放新的资源时, 改方法会被调用.
 */
- (void)resetInitialization;

/**
 当播放被暂停时, 是否保持控制层一直显示.  见 `videoPlayer.pausedToKeepAppearState`.
 */
@property (nonatomic) BOOL pausedToKeepAppearState;

/**
 当播放失败时, 是否保持控制层一直显示. 见 `videoPlayer.playFailedToKeepAppearState`
 */
@property (nonatomic) BOOL playFailedToKeepAppearState;

- (void)start;

@end
NS_ASSUME_NONNULL_END


#pragma mark -

NS_ASSUME_NONNULL_BEGIN

/**
 管理类: 监测 网络状态
 */
@interface _SJReachabilityObserver : NSObject

/**
 网络状态只需一个监测对象即可, 所以将其作为单例使用.
 */
+ (instancetype)sharedInstance;

/**
 当前的网络状态.
 */
@property (nonatomic, assign, readonly) SJNetworkStatus networkStatus;

/**
 当网络状态变更时, 将会调用这个Block.
 */
@property (nonatomic, copy, readwrite, nullable) void(^reachabilityChangedExeBlock)(_SJReachabilityObserver *observer, SJNetworkStatus status);
@end
NS_ASSUME_NONNULL_END


#pragma mark -

NS_ASSUME_NONNULL_BEGIN

/**
 Base Video Player
 */
@interface SJBaseVideoPlayer () {
    UIView *_view;
    SJVideoPlayerPresentView *_presentView;
    UIView *_controlContentView;
    SJOrentationObserver *_orentationObserver;
    SJPlayerGestureControl *_gestureControl;
    SJVolBrigControl *_volBrigControl;
    _SJControlLayerAppearStateManager *_displayRecorder;
    SJVideoPlayerRegistrar *_registrar;
    _SJReachabilityObserver *_reachabilityObserver;
    UITapGestureRecognizer *_lockStateTapGesture;
}

/**
 标识是用户暂停的, 还是开发者主动暂停的
 场景:
 当返回到播放界面时, 可以根据这个状态来处理是否播放
 如果是开发者暂停的, 则可以根据业务需求继续播放, 还是暂停
 如果是用户暂停, 体验好一点的话就继续暂停的, 你也可以继续播放
 */
@property (nonatomic, assign, readwrite) BOOL userClickedPause;

/**
 当前播放器播放视频的状态
 */
@property (nonatomic, assign, readwrite) SJVideoPlayerPlayState state;

/**
 当前播放如果出错, 可以查看这个error
 */
@property (nonatomic, strong, readwrite, nullable) NSError *error;

/**
 当前播放的资源载体,
 */
@property (nonatomic, strong, readwrite, nullable) SJVideoPlayerAssetCarrier *asset;

/**
 当播放器在TableView或者CollectionView中播放时, 播放器可能被滚动到窗口之外, 这个属性是用来标识是否滚入到窗口中. YES 表示在窗口中, 否则相反.
 */
@property (nonatomic, assign, readwrite) BOOL scrollIn;

/**
 当用户触摸到TableView或者ScrollView时, 这个值为YES.
 这个值用于旋转的条件之一, 如果用户触摸在TableView或者ScrollView上时, 将不开启旋转.
 */
@property (nonatomic, assign, readwrite) BOOL touchedScrollView; // 如果为`YES`, 则不旋转

/**
 这个值用于播放控制.
 场景:
 当在播放界面, 播放资源未加载完成还未播放时, 用户就跳入到下一个界面, 当资源加载完开始播放时, 就会出现这种尴尬的情况, 播放器不在当前页面播放...
 一般情况下, 我们会在viewWillAppear这些生命周期函数中写一些控制播放的方法, 所以我把切入点放到了这三个方法[`pause` || `play` || `stop`]
 当`suspend==YES`时, 播放器将不会进行播放
 */
@property (nonatomic, assign, readwrite) BOOL suspend; // Set it when the [`pause` || `play` || `stop`] is called.

/**
 App是否进入后台.
 当进入后台时, 将会禁止播放器旋转, 并依据这个属性`videoPlayer.pauseWhenAppResignActive`来暂停播放.
 */
@property (nonatomic, assign, readwrite) BOOL resignActive; // app 进入后台, 进入前台时会设置

/**
 管理对象: 监听 App在前台, 后台, 耳机插拔的通知
 */
@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;

/**
 控制层的父视图
 */
@property (nonatomic, strong, readonly) UIView *controlContentView;

/**
 视频画面的呈现层
 */
@property (nonatomic, strong, readonly) SJVideoPlayerPresentView *presentView;

/**
 管理对象: 指定旋转及管理视图的自动旋转
 */
@property (nonatomic, strong, readonly) SJOrentationObserver *orentationObserver;

/**
 管理对象: 单击+双击+上下左右移动+捏合手势
 */
@property (nonatomic, strong, readonly) SJPlayerGestureControl *gestureControl;

/**
 管理对象: 音量+声音
 */
@property (nonatomic, strong, readonly) SJVolBrigControl *volBrigControl;

/**
 管理对象: 控制层的显示与隐藏
 */
@property (nonatomic, strong, readonly) _SJControlLayerAppearStateManager *displayRecorder;

/**
 管理对象: 网络状态监测
 */
@property (nonatomic, strong, readonly) _SJReachabilityObserver *reachabilityObserver;

/**
 锁屏状态下触发的手势.
 当播放器被锁屏时, 用户单击后, 会触发这个手势, 调用`controlLayerDelegate`的方法: `tappedPlayerOnTheLockedState:`
 */
@property (nonatomic, strong, readonly) UITapGestureRecognizer *lockStateTapGesture;

/**
 清理资源
 */
- (void)clearAsset;

@end
NS_ASSUME_NONNULL_END

@implementation SJBaseVideoPlayer

+ (instancetype)player {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    NSError *error = nil;
    // 使播放器在静音状态下也能放出声音
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if ( error ) NSLog(@"%@", error.userInfo);
    self.autoPlay = YES;
    self.enableControlLayerDisplayController = YES;
    self.pauseWhenAppResignActive = YES;
    self.playFailedToKeepAppearState = YES;
    [self registrar];
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"SJVideoPlayerLog: %d - %s", (int)__LINE__, __func__);
#endif
    if ( self.asset && self.assetDeallocExeBlock ) self.assetDeallocExeBlock(self);
    [_presentView removeFromSuperview];
    [self clearAsset];
}

#pragma mark -

- (void)setAsset:(SJVideoPlayerAssetCarrier *)asset {
    _asset = asset;
    if ( !asset ) return;
    
    if ( self.mute ) self.mute = YES; // update
    
    [self _itemPrepareToPlay];
    
    __weak typeof(self) _self = self;
    
    asset.convertToOriginalExeBlock = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _itemPrepareToPlay];
    };
    
    asset.loadedPlayerExeBlock = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.presentView.player = asset.player;
    };
    
    if ( asset.loadedPlayer ) asset.loadedPlayerExeBlock(asset);
    
    asset.startBuffering = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( SJVideoPlayerPlayState_Paused == self.state ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(startLoading:)] ) {
            [self.controlLayerDelegate startLoading:self];
        }
        self.state = SJVideoPlayerPlayState_Buffing;
        [self.asset pause];
    };
    
    asset.cancelledBuffer = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(cancelLoading:)] ) {
            [self.controlLayerDelegate cancelLoading:self];
        }
    };
    
    asset.completeBuffer = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(loadCompletion:)] ) {
            [self.controlLayerDelegate loadCompletion:self];
        }
        if ( SJVideoPlayerPlayState_Paused != self.state ) [self play];
    };
    
    asset.playerItemStateChanged = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, AVPlayerItemStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.state == SJVideoPlayerPlayState_PlayEnd ) return;
        switch ( status ) {
            case AVPlayerItemStatusUnknown: {
                asset.startBuffering(asset);
            }
                break;
            case AVPlayerItemStatusFailed: {
                asset.cancelledBuffer(asset);
                [self _itemPlayFailed];
            }
                break;
            case AVPlayerItemStatusReadyToPlay: {
                asset.completeBuffer(asset);
                if ( !self.resignActive ) [self _itemReadyToPlay];
            }
                break;
        }
    };
    
    asset.playerItemStateChanged(asset, asset.playerItem.status);
    
    asset.playTimeChanged = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:currentTime:currentTimeStr:totalTime:totalTimeStr:)] ) {
            [self.controlLayerDelegate videoPlayer:self currentTime:currentTime currentTimeStr:self.currentTimeStr totalTime:duration totalTimeStr:self.totalTimeStr];
        }
    };
    
    asset.playDidToEnd = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _itemPlayDidToEnd];
    };
    
    asset.loadedTimeProgress = ^(float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:loadedTimeProgress:)] ) {
            [self.controlLayerDelegate videoPlayer:self loadedTimeProgress:progress];
        }
    };
    
    if ( 0 != asset.loadedTimeProgressValue ) asset.loadedTimeProgress(asset.loadedTimeProgressValue);
    
    asset.rateChanged = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, float rate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:rateChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self rateChanged:rate];
        }
        if ( self.rateChanged ) self.rateChanged(self);
        if ( SJVideoPlayerPlayState_PlayEnd == self.state ) [self replay];
    };
    
    BOOL isPlayOnScrollView = [asset.scrollView isKindOfClass:[UIScrollView class]];
    
    self.scrollIn = isPlayOnScrollView;
    
    if ( isPlayOnScrollView ) {
        
        // 进入窗口
        asset.scrollIn = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, UIView * _Nonnull superview) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.scrollIn ) return;
            self.scrollIn = YES;
            [self.displayRecorder layerAppear];
            if ( superview && self.view.superview != superview ) {
                [self.view removeFromSuperview];
                [superview addSubview:self.view];
                [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.view.superview);
                }];
            }
            
            if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayerWillAppearInScrollView:)] ) {
                [self.controlLayerDelegate videoPlayerWillAppearInScrollView:self];
            }
            // 这里不再使用, 由代理去决定是否播放
            //            if ( !self.userPaused &&
            //                 self.state != SJVideoPlayerPlayState_PlayEnd ) [self play];
        };
        
        // 退出窗口
        asset.scrollOut = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( !self.scrollIn ) return;
            self.scrollIn = NO;
            if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayerWillDisappearInScrollView:)] ) {
                [self.controlLayerDelegate videoPlayerWillDisappearInScrollView:self];
            }
        };
        
        // 触摸着
        asset.touchedScrollView = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, BOOL tracking) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.touchedScrollView = tracking;
        };
    }
    
    asset.presentationSize = ^(SJVideoPlayerAssetCarrier * _Nonnull asset, CGSize size) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( CGSizeEqualToSize(self.asset.videoPresentationSize, size) ) return;
        if ( self.presentationSize ) self.presentationSize(self, size);
        self.asset.videoPresentationSize = size;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:presentationSize:)] ) {
            [self.controlLayerDelegate videoPlayer:self presentationSize:size];
        }
    };
    
    if ( !CGSizeEqualToSize(asset.videoPresentationSize, CGSizeZero) ) {
        CGSize size = asset.videoPresentationSize;
        asset.videoPresentationSize = CGSizeZero;   // clear
        asset.presentationSize(asset, size);        // reset
    }
    
    if ( self.assetDeallocExeBlock ) {
        __weak typeof(self) _self = self;
        asset.deallocExeBlock = ^(SJVideoPlayerAssetCarrier * _Nonnull asset) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            self.assetDeallocExeBlock(self);
        };
    }
}

- (void)setControlLayerDataSource:(id<SJVideoPlayerControlLayerDataSource>)controlLayerDataSource {
    if ( controlLayerDataSource == _controlLayerDataSource ) return;

    [_controlLayerDataSource.controlView removeFromSuperview];
    
    _controlLayerDataSource = controlLayerDataSource;
    
    if ( !controlLayerDataSource ) return;
    
    _controlLayerDataSource.controlView.clipsToBounds = YES;
    // install
    [self.controlContentView addSubview:_controlLayerDataSource.controlView];
    [_controlLayerDataSource.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    if ( [self.controlLayerDataSource respondsToSelector:@selector(installedControlViewToVideoPlayer:)] ) {
        [self.controlLayerDataSource installedControlViewToVideoPlayer:self];
    }
}

- (void)setControlLayerDelegate:(id<SJVideoPlayerControlLayerDelegate>)controlLayerDelegate {
    if ( controlLayerDelegate == _controlLayerDelegate ) return;
    _controlLayerDelegate = controlLayerDelegate;
    
    if ( [controlLayerDelegate respondsToSelector:@selector(videoPlayer:volumeChanged:)] ) {
        [controlLayerDelegate videoPlayer:self volumeChanged:_volBrigControl.volume];
    }
    if ( [controlLayerDelegate respondsToSelector:@selector(videoPlayer:brightnessChanged:)] ) {
        [controlLayerDelegate videoPlayer:self brightnessChanged:_volBrigControl.brightness];
    }
}

- (void)setPlaceholder:(UIImage *)placeholder {
    self.presentView.placeholder = placeholder;
}

- (UIImage *)placeholder {
    return self.presentView.placeholder;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    self.presentView.videoGravity = videoGravity;
}

- (AVLayerVideoGravity)videoGravity {
    if ( _presentView ) return _presentView.videoGravity;
    return AVLayerVideoGravityResizeAspect;
}

#pragma mark -
- (void)_itemPrepareToPlay {
    self.userClickedPause = NO;
    self.state = SJVideoPlayerPlayState_Prepare;

    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:prepareToPlay:)] ) {
        [self.controlLayerDelegate videoPlayer:self prepareToPlay:self.URLAsset];
    }
}

- (void)_itemPlayFailed {
    self.error = self.asset.playerItem.error;
    
    self.state = SJVideoPlayerPlayState_PlayFailed;
}

- (void)_itemReadyToPlay {
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:currentTime:currentTimeStr:totalTime:totalTimeStr:)] ) {
        [self.controlLayerDelegate videoPlayer:self currentTime:self.currentTime currentTimeStr:self.currentTimeStr totalTime:self.totalTime totalTimeStr:self.totalTimeStr];
    }
    
    if ( !self.autoPlay ) return;
    
    if ( !self.userClickedPause && !self.suspend ) [self play];
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(loadCompletion:)] ) {
        [self.controlLayerDelegate loadCompletion:self];
    }
    
    [self.displayRecorder resetInitialization];
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.displayRecorder.initialization && !self.displayRecorder.controlLayerAppearedState ) [self controlLayerNeedAppear];
    });
}

- (void)_itemPlayDidToEnd {
    self.state = SJVideoPlayerPlayState_PlayEnd;
    if ( self.playDidToEnd ) self.playDidToEnd(self);
}

#pragma mark -
- (UIView *)view {
    if ( _view ) return _view;
    _view = [SJBaseVideoPlayerView new];
    _view.backgroundColor = [UIColor blackColor];
    [_view addSubview:self.presentView];

    __weak typeof(self) _self = self;
    [(SJBaseVideoPlayerView *)_view setLayoutSubViewsExeBlock:^(SJBaseVideoPlayerView *view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.presentView.superview == view ) {
            self.presentView.frame = view.bounds;
            [self.presentView addSubview:self.controlContentView];
            self.controlContentView.frame = view.bounds;
        }
    }];

    [self orentationObserver];
    [self gestureControl];
    [self reachabilityObserver];
    [self addInterceptTapGR];
    return _view;
}

- (void)addInterceptTapGR {
    UITapGestureRecognizer *intercept = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInterceptTapGR:)];
    [self.view addGestureRecognizer:intercept];
}
- (void)handleInterceptTapGR:(UITapGestureRecognizer *)tap {}

- (SJVideoPlayerPresentView *)presentView {
    if ( _presentView ) return _presentView;
    _presentView = [SJVideoPlayerPresentView new];
    return _presentView;
}

- (UIView *)controlContentView {
    if ( _controlContentView ) return _controlContentView;
    _controlContentView = [UIView new];
    _controlContentView.clipsToBounds = YES;
    return _controlContentView;
}

#pragma mark -
- (SJOrentationObserver *)orentationObserver {
    if ( _orentationObserver ) return _orentationObserver;
    _orentationObserver = [[SJOrentationObserver alloc] initWithTarget:self.presentView container:self.view];
    
    __weak typeof(self) _self = self;
    
    _orentationObserver.rotationCondition = ^BOOL(SJOrentationObserver * _Nonnull observer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        if ( !self.view.superview ) return NO;
        if ( self.touchedScrollView ) return NO;
        if ( self.isPlayOnScrollView && !self.scrollIn ) return NO;
        if ( self.disableRotation ) return NO;
        if ( self.isLockedScreen ) return NO;
        if ( self.resignActive ) return NO;
        return YES;
    };
    
    _orentationObserver.orientationWillChange = ^(SJOrentationObserver * _Nonnull observer, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [UIView animateWithDuration:observer.duration animations:^{
           self.controlContentView.frame = self.presentView.bounds;
            [self.controlContentView layoutIfNeeded];
        }];
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:willRotateView:)] ) {
            [self.controlLayerDelegate videoPlayer:self willRotateView:isFullScreen];
        }
        if ( self.willRotateScreen ) self.willRotateScreen(self, isFullScreen);
    };
    
    _orentationObserver.orientationChanged = ^(SJOrentationObserver * _Nonnull observer, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:didEndRotation:)] ) {
            [self.controlLayerDelegate videoPlayer:self didEndRotation:isFullScreen];
        }
        if ( self.rotatedScreen ) self.rotatedScreen(self, observer.isFullScreen);
    };
    
    return _orentationObserver;
}
- (SJPlayerGestureControl *)gestureControl {
    if ( _gestureControl ) return _gestureControl;
    _gestureControl = [[SJPlayerGestureControl alloc] initWithTargetView:self.controlContentView];
    __weak typeof(self) _self = self;
    _gestureControl.triggerCondition = ^BOOL(SJPlayerGestureControl * _Nonnull control, SJPlayerGestureType type, UIGestureRecognizer * _Nonnull gesture) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        
        if ( self.isLockedScreen ) return NO;

        SJDisablePlayerGestureTypes disableTypes = self.disableGestureTypes;
        if ( SJDisablePlayerGestureTypes_All == (disableTypes & SJDisablePlayerGestureTypes_All)  ) {
            disableTypes = SJDisablePlayerGestureTypes_Pan | SJDisablePlayerGestureTypes_Pinch | SJDisablePlayerGestureTypes_DoubleTap | SJDisablePlayerGestureTypes_SingleTap;
        }
        
        switch (type) {
            case SJPlayerGestureType_Unknown: break;
            case SJPlayerGestureType_Pan: {
                if ( SJDisablePlayerGestureTypes_Pan == (disableTypes & SJDisablePlayerGestureTypes_Pan ) ) {
                    return NO;
                }
            }
                break;
                
            case SJPlayerGestureType_Pinch: {
                if ( SJDisablePlayerGestureTypes_Pinch == (disableTypes & SJDisablePlayerGestureTypes_Pinch ) ) {
                    return NO;
                }
            }
                break;
            case SJPlayerGestureType_DoubleTap: {
                if ( SJDisablePlayerGestureTypes_DoubleTap == (disableTypes & SJDisablePlayerGestureTypes_DoubleTap) ) {
                    return NO;
                }
            }
                break;
            case SJPlayerGestureType_SingleTap: {
                if ( SJDisablePlayerGestureTypes_SingleTap == (disableTypes & SJDisablePlayerGestureTypes_SingleTap ) ) {
                    return NO;
                }
            }
                break;
        }
        
        if ( SJVideoPlayerPlayState_Unknown == self.state ||
             SJVideoPlayerPlayState_Prepare == self.state ||
             SJVideoPlayerPlayState_PlayFailed == self.state ) return NO;
        
        if ( SJPlayerGestureType_Pan == type &&
             self.isPlayOnScrollView &&
            !self.orentationObserver.isFullScreen ) return NO;
        
        if ( self.controlLayerDataSource &&
            ![self.controlLayerDataSource triggerGesturesCondition:[gesture locationInView:gesture.view]] ) return NO;
        
        if ( type == SJPlayerGestureType_Pan ) {
            switch ( control.panLocation ) {
                case SJPanLocation_Unknown: break;
                case SJPanLocation_Left: {
                    if ( self.disableBrightnessSetting ) return NO;
                }
                    break;
                case SJPanLocation_Right: {
                    if ( self.disableVolumeSetting ) return NO;
                }
                    break;
            }
        }
        return YES;
    };
    
    _gestureControl.singleTapped = ^(SJPlayerGestureControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.displayRecorder considerChangeState];
    };
    
    _gestureControl.doubleTapped = ^(SJPlayerGestureControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( SJVideoPlayerPlayState_Paused == self.state ) [self play];
        else if ( SJVideoPlayerPlayState_PlayEnd == self.state ) [self replay];
        else [self pauseForUser]; //  用户暂停
    };
    
    static CGFloat __increment;
    static NSTimeInterval __currentTime;
    static NSTimeInterval __totalTime;
    _gestureControl.beganPan = ^(SJPlayerGestureControl * _Nonnull control, SJPanDirection direction, SJPanLocation location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch (direction) {
            case SJPanDirection_H: {
                __increment = 0;
                __currentTime = self.currentTime;
                __totalTime = self.totalTime;
                if ( [self.controlLayerDelegate respondsToSelector:@selector(horizontalDirectionWillBeginDragging:)] ) {
                    [self.controlLayerDelegate horizontalDirectionWillBeginDragging:self];
                }
            }
                break;
            case SJPanDirection_V: {
                switch (location) {
                    case SJPanLocation_Right: break;
                    case SJPanLocation_Left: {
                        self.volBrigControl.brightnessView.transform = self.presentView.transform;
                        [[UIApplication sharedApplication].keyWindow addSubview:self.volBrigControl.brightnessView];
                        [self.volBrigControl.brightnessView sj_fadeIn];
                        [self.volBrigControl.brightnessView mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.size.mas_offset(CGSizeMake(155, 155));
                            make.center.equalTo([UIApplication sharedApplication].keyWindow);
                        }];
                    }
                        break;
                    case SJPanLocation_Unknown: break;
                }
            }
                break;
            case SJPanDirection_Unknown:
                break;
        }
    };
    
    _gestureControl.changedPan = ^(SJPlayerGestureControl * _Nonnull control, SJPanDirection direction, SJPanLocation location, CGPoint translate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch (direction) {
            case SJPanDirection_H: {
                if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:horizontalDirectionDidMove:)] ) {
                    float add = 0;
                    if ( __totalTime > 60 * 2 ) add = translate.x;
                    else add = translate.x * 0.1;
                    __increment += add;
                    CGFloat progress = (__currentTime + __increment) / __totalTime;
                    [self.controlLayerDelegate videoPlayer:self horizontalDirectionDidMove:progress];
                }
                else if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:horizontalDirectionDidDrag:)] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [self.controlLayerDelegate videoPlayer:self horizontalDirectionDidDrag:translate.x * 0.003];
#pragma clang diagnostic pop
                }
            }
                break;
            case SJPanDirection_V: {
                switch (location) {
                    case SJPanLocation_Left: {
                        CGFloat value = self.volBrigControl.brightness - translate.y * 0.006;
                        if ( value < 1.0 / 16 ) value = 1.0 / 16;
                        self.volBrigControl.brightness = value;
                    }
                        break;
                    case SJPanLocation_Right: {
                        CGFloat value = translate.y * 0.008;
                        self.volBrigControl.volume -= value;
                    }
                        break;
                    case SJPanLocation_Unknown: break;
                }
            }
                break;
            default:
                break;
        }
    };
    
    _gestureControl.endedPan = ^(SJPlayerGestureControl * _Nonnull control, SJPanDirection direction, SJPanLocation location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        switch ( direction ) {
            case SJPanDirection_H:{
                if ( [self.controlLayerDelegate respondsToSelector:@selector(horizontalDirectionDidEndDragging:)] ) {
                    [self.controlLayerDelegate horizontalDirectionDidEndDragging:self];
                }
            }
                break;
            case SJPanDirection_V:{
                if ( location == SJPanLocation_Left ) [self.volBrigControl.brightnessView sj_fadeOut];
            }
                break;
            case SJPanDirection_Unknown: break;
        }
    };
    
    _gestureControl.pinched = ^(SJPlayerGestureControl * _Nonnull control, float scale) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( scale > 1 ) {
            self.presentView.videoGravity = AVLayerVideoGravityResizeAspectFill;
        }
        else {
            self.presentView.videoGravity = AVLayerVideoGravityResizeAspect;
        }
    };
    return _gestureControl;
}
- (SJVolBrigControl *)volBrigControl {
    if ( _volBrigControl ) return _volBrigControl;
    _volBrigControl = [[SJVolBrigControl alloc] init];
    __weak typeof(self) _self = self;
    _volBrigControl.volumeChanged = ^(float volume) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:volumeChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self volumeChanged:volume];
        }
    };
    
    _volBrigControl.brightnessChanged = ^(float brightness) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:brightnessChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self brightnessChanged:brightness];
        }
    };
    
    return _volBrigControl;
}
- (_SJControlLayerAppearStateManager *)displayRecorder {
    if ( _displayRecorder ) return _displayRecorder;
    _displayRecorder = [[_SJControlLayerAppearStateManager alloc] initWithVideoPlayer:self];
    return _displayRecorder;
}
- (SJVideoPlayerRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [SJVideoPlayerRegistrar new];
    
    __weak typeof(self) _self = self;
    _registrar.willResignActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.resignActive = YES;
        if ( self.state != SJVideoPlayerPlayState_Paused && self.pauseWhenAppResignActive ) [self pause];
    };
    
    _registrar.didBecomeActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.resignActive = NO;
    };
    
    _registrar.oldDeviceUnavailable = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( !self.userClickedPause ) [self play];
    };
    
    //    _registrar.categoryChange = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
    //        __strong typeof(_self) self = _self;
    //        if ( !self ) return;
    //
    //    };
    
    return _registrar;
}

- (_SJReachabilityObserver *)reachabilityObserver {
    if ( _reachabilityObserver ) return _reachabilityObserver;
    _reachabilityObserver = [_SJReachabilityObserver sharedInstance];
    __weak typeof(self) _self = self;
    _reachabilityObserver.reachabilityChangedExeBlock = ^(_SJReachabilityObserver * _Nonnull observer, SJNetworkStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:reachabilityChanged:)] ) {
            [self.controlLayerDelegate videoPlayer:self reachabilityChanged:status];
        }
#if 0
        switch (status) {
            case SJNetworkStatus_NotReachable: {
                NSLog(@"网络状态: 无法连接网络");
            }
                break;
            case SJNetworkStatus_ReachableViaWiFi: {
                NSLog(@"网络状态: WiFi");
            }
                break;
            case SJNetworkStatus_ReachableViaWWAN: {
                NSLog(@"网络状态: WWAN");
            }
                break;
        }
#endif
    };
    return _reachabilityObserver;
}

#pragma mark -
- (void)setState:(SJVideoPlayerPlayState)state {
    if ( state == _state ) return;
    _state = state;
#if 0
    switch ( state ) {
        case SJVideoPlayerPlayState_Unknown: {
            NSLog(@"状态: 未知");
        }
            break;
        case SJVideoPlayerPlayState_Playing: {
            NSLog(@"状态: 播放");
        }
            break;
        case SJVideoPlayerPlayState_PlayFailed: {
            NSLog(@"状态: 失败");
        }
            break;
        case SJVideoPlayerPlayState_Prepare: {
            NSLog(@"状态: 准备");
        }
            break;
        case SJVideoPlayerPlayState_Paused: {
            NSLog(@"状态: 暂停");
        }
            break;
        case SJVideoPlayerPlayState_Buffing: {
            NSLog(@"状态: 缓冲");
        }
            break;
        case SJVideoPlayerPlayState_PlayEnd: {
            NSLog(@"状态: 完毕");
        }
            break;
        default:
            break;
    }
#endif
    _presentView.playState = state;
    
    if ( state == SJVideoPlayerPlayState_Paused && self.pausedToKeepAppearState && self.registrar.state == SJVideoPlayerBackstageState_Forground ) [self.displayRecorder layerAppear];
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:stateChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self stateChanged:state];
    }
}

- (void)clearAsset {
    [self.presentView.player replaceCurrentItemWithPlayerItem:nil];
    self.presentView.player = nil;
    self.URLAsset = nil;
}

- (UITapGestureRecognizer *)lockStateTapGesture {
    if ( _lockStateTapGesture ) return _lockStateTapGesture;
    _lockStateTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLockStateTapGesture:)];
    return _lockStateTapGesture;
}

- (void)handleLockStateTapGesture:(UITapGestureRecognizer *)tap {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(tappedPlayerOnTheLockedState:)] ) {
        [self.controlLayerDelegate tappedPlayerOnTheLockedState:self];
    }
}
@end


#pragma mark - 播放

@implementation SJBaseVideoPlayer (Play)

- (void)setAssetURL:(NSURL *)assetURL {
    [self playWithURL:assetURL];
}

- (NSURL *)assetURL {
    return self.asset.assetURL;
}

- (void)setURLAsset:(SJVideoPlayerURLAsset *)URLAsset {
    objc_setAssociatedObject(self, @selector(URLAsset), URLAsset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( !URLAsset ) {_asset = nil; return;}
    dispatch_async(dispatch_get_main_queue(), ^{
        self.asset = [URLAsset valueForKey:kSJVideoPlayerAssetKey];
    });
}

- (SJVideoPlayerURLAsset *)URLAsset {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)playWithURL:(NSURL *)playURL {
    [self playWithURL:playURL jumpedToTime:0];
}

- (void)playWithURL:(NSURL *)playURL jumpedToTime:(NSTimeInterval)time {
    self.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithAssetURL:playURL beginTime:time];
}

- (void)refresh {
    if ( !self.asset ) return;
    self.asset.startBuffering(self.asset);
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.asset refreshAVPlayer];
    });
}

- (void)setAssetDeallocExeBlock:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull))assetDeallocExeBlock {
    objc_setAssociatedObject(self, @selector(assetDeallocExeBlock), assetDeallocExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull))assetDeallocExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

@end


#pragma mark - Network

@implementation SJBaseVideoPlayer (Network)

- (SJNetworkStatus)networkStatus {
    return self.reachabilityObserver.networkStatus;
}

@end


#pragma mark - 时间

@implementation SJBaseVideoPlayer (Time)

- (NSString *)timeStringWithSeconds:(NSInteger)secs {
    return [self.asset timeString:secs];
}

- (float)progress {
    if ( 0 == self.totalTime ) return 0;
    return self.currentTime / self.totalTime;
}

- (NSTimeInterval)currentTime {
    return self.asset.currentTime;
}

- (NSTimeInterval)totalTime {
    return self.asset.duration;
}

- (NSString *)currentTimeStr {
    return [self timeStringWithSeconds:self.currentTime];
}

- (NSString *)totalTimeStr {
    return [self timeStringWithSeconds:self.totalTime];
}

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    if ( isnan(time) ) { return;}
    CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    [self seekToTime:seekTime completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    self.state = SJVideoPlayerPlayState_Buffing;
    if ( self.asset.startBuffering ) self.asset.startBuffering(self.asset);
    __weak typeof(self) _self = self;
    [self.asset seekToTime:time completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( finished ) self.asset.completeBuffer(self.asset);
        else self.asset.cancelledBuffer(self.asset);
        if ( completionHandler ) completionHandler(finished);
    }];
}
@end


#pragma mark - 控制

@implementation SJBaseVideoPlayer (Control)

- (void)setMute:(BOOL)mute {
    if ( mute == self.mute ) return;
    objc_setAssociatedObject(self, @selector(mute), @(mute), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.asset.player.volume = !mute;
    if ( [self.controlLayerDelegate respondsToSelector:@selector(videoPlayer:muteChanged:)] ) {
        [self.controlLayerDelegate videoPlayer:self muteChanged:mute];
    }
}

- (BOOL)mute {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)userPaused {
    return self.userClickedPause;
}

- (void)pauseForUser {
    [self pause];
    self.userClickedPause = YES;
}

- (void)setLockedScreen:(BOOL)lockedScreen {
    objc_setAssociatedObject(self, @selector(isLockedScreen), @(lockedScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( lockedScreen ) {
        [self.controlLayerDataSource.controlView addGestureRecognizer:self.lockStateTapGesture];
    }
    else {
        [self.controlLayerDataSource.controlView removeGestureRecognizer:self.lockStateTapGesture];
    }
    if      ( lockedScreen && [self.controlLayerDelegate respondsToSelector:@selector(lockedVideoPlayer:)] ) {
        [self.controlLayerDelegate lockedVideoPlayer:self];
    }
    else if ( !lockedScreen && [self.controlLayerDelegate respondsToSelector:@selector(unlockedVideoPlayer:)] ) {
        [self.controlLayerDelegate unlockedVideoPlayer:self];
    }
}

- (BOOL)isLockedScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setAutoPlay:(BOOL)autoPlay {
    objc_setAssociatedObject(self, @selector(isAutoPlay), @(autoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAutoPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setPauseWhenAppResignActive:(BOOL)pauseWhenAppResignActive {
    objc_setAssociatedObject(self, @selector(pauseWhenAppResignActive), @(pauseWhenAppResignActive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pauseWhenAppResignActive {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)play {
    self.suspend = NO;

    if ( self.state ==  SJVideoPlayerPlayState_PlayFailed ||
         self.state == SJVideoPlayerPlayState_Unknown ) return NO;
    
    self.userClickedPause = NO;
    if ( !self.asset ) return NO;
    [self.asset play];
    self.state = SJVideoPlayerPlayState_Playing;
    [self.displayRecorder start];
    return YES;
}

- (BOOL)pause {
    self.suspend = YES;
    
    if ( self.state ==  SJVideoPlayerPlayState_PlayFailed ||
         self.state == SJVideoPlayerPlayState_Unknown ) return NO;
    
    self.userClickedPause = NO;
    if ( !self.asset ) return NO;
    [self.asset pause];
    if ( SJVideoPlayerPlayState_PlayEnd != self.state ) self.state = SJVideoPlayerPlayState_Paused;
    return YES;
}

- (void)stop {
    self.suspend = YES;
    
    self.state = SJVideoPlayerPlayState_Unknown;
    
    if ( !self.asset ) return;
    [self clearAsset];
}

- (void)stopAndFadeOut {
    self.suspend = YES;
    
    [self.asset pause];
    [self.view sj_fadeOutAndCompletion:^(UIView *view) {
        [self stop];
        [self->_view removeFromSuperview];
    }];
}

- (void)replay {
    if ( !self.asset ) return;
    [self pause];
    __weak typeof(self) _self = self;
    [self jumpedToTime:0 completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self play];
    }];
}

- (void)setVolume:(float)volume {
    if ( self.disableVolumeSetting ) return;
    self.volBrigControl.volume = volume;
}

- (float)volume {
    return self.volBrigControl.volume;
}

- (void)setDisableVolumeSetting:(BOOL)disableVolumeSetting {
    objc_setAssociatedObject(self, @selector(disableVolumeSetting), @(disableVolumeSetting), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableVolumeSetting {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setBrightness:(float)brightness {
    if ( self.disableBrightnessSetting ) return;
    self.volBrigControl.brightness = brightness;
}

- (float)brightness {
    return self.volBrigControl.brightness;
}

- (void)setDisableBrightnessSetting:(BOOL)disableBrightnessSetting {
    objc_setAssociatedObject(self, @selector(disableBrightnessSetting), @(disableBrightnessSetting), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableBrightnessSetting {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setRate:(float)rate {
    self.asset.rate = rate;
    [self play];
}

- (float)rate {
    if ( nil == self.asset ) return 1;
    return self.asset.rate;
}

- (void)resetRate {
    self.asset.rate = 1;
}

- (void)setRateChanged:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull))rateChanged {
    objc_setAssociatedObject(self, @selector(rateChanged), rateChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull))rateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlayDidToEnd:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playDidToEnd {
    objc_setAssociatedObject(self, @selector(playDidToEnd), playDidToEnd, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull))playDidToEnd {
    return objc_getAssociatedObject(self, _cmd);
}

@end


#pragma mark - Gesture

@implementation SJBaseVideoPlayer (GestureControl)

- (void)setDisableGestureTypes:(SJDisablePlayerGestureTypes)disableGestureTypes {
    objc_setAssociatedObject(self, @selector(disableGestureTypes), @(disableGestureTypes), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJDisablePlayerGestureTypes)disableGestureTypes {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

@end


#pragma mark - 控制层

@implementation SJBaseVideoPlayer (ControlLayer)

- (BOOL)enableControlLayerDisplayController {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setEnableControlLayerDisplayController:(BOOL)enableControlLayerDisplayController {
    objc_setAssociatedObject(self, @selector(enableControlLayerDisplayController), @(enableControlLayerDisplayController), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.displayRecorder.enabled = enableControlLayerDisplayController;
}

- (BOOL)controlLayerAppeared {
    return self.displayRecorder.controlLayerAppearedState;
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlLayerAppearStateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setControlLayerAppearStateChanged:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlLayerAppearStateChanged {
    objc_setAssociatedObject(self, @selector(controlLayerAppearStateChanged), controlLayerAppearStateChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)controlLayerNeedAppear {
    [self.displayRecorder layerAppear];
}
- (void)controlLayerNeedDisappear {
    [self.displayRecorder layerDisappear];
}

- (void)setControlViewDisplayStatus:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlViewDisplayStatus {
    self.controlLayerAppearStateChanged = controlViewDisplayStatus;
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))controlViewDisplayStatus {
    return self.controlLayerAppearStateChanged;
}

- (BOOL)controlViewDisplayed {
    return self.controlLayerAppeared;
}

- (void)setPausedToKeepAppearState:(BOOL)pausedToKeepAppearState {
    self.displayRecorder.pausedToKeepAppearState = pausedToKeepAppearState;
}
- (BOOL)pausedToKeepAppearState {
    return self.displayRecorder.pausedToKeepAppearState;
}
- (void)setPlayFailedToKeepAppearState:(BOOL)playFailedToKeepAppearState {
    self.displayRecorder.playFailedToKeepAppearState = playFailedToKeepAppearState;
}
- (BOOL)playFailedToKeepAppearState {
    return self.displayRecorder.playFailedToKeepAppearState;
}
@end


#pragma mark - 屏幕旋转

@implementation SJBaseVideoPlayer (Rotation)

- (void)setSupportedRotateViewOrientation:(SJSupportedRotateViewOrientation)supportedRotateViewOrientation {
    self.orentationObserver.supportedRotateViewOrientation = supportedRotateViewOrientation;
}

- (SJSupportedRotateViewOrientation)supportedRotateViewOrientation {
    return self.orentationObserver.supportedRotateViewOrientation;
}

- (void)setRotateOrientation:(SJRotateViewOrientation)rotateOrientation {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.orentationObserver.rotateOrientation = rotateOrientation;
    });
}

- (SJRotateViewOrientation)rotateOrientation {
    return self.orentationObserver.rotateOrientation;
}

- (UIInterfaceOrientation)currentOrientation {
    UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
    switch ( self.rotateOrientation ) {
        case SJRotateViewOrientation_Portrait: {
            orientation = UIInterfaceOrientationPortrait;
        }
            break;
        case SJRotateViewOrientation_LandscapeLeft: {
            orientation = UIInterfaceOrientationLandscapeRight;
        }
            break;
        case SJRotateViewOrientation_LandscapeRight: {
            orientation = UIInterfaceOrientationLandscapeLeft;
        }
            break;
    }
    return orientation;
}

- (void)rotation {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 此方法为无条件旋转, 任何时候都可以旋转
        // 外界调用此方法, 就是想要旋转, 不管播放器有没有禁止旋转, 我都暂时解开, 最后恢复设置
        BOOL disableRotation = self.disableRotation;
        self.disableRotation = NO;
        [self.orentationObserver _changeOrientation];
        // 恢复
        self.disableRotation = disableRotation; // reset
    });
}

- (void)rotate:(SJRotateViewOrientation)orientation animated:(BOOL)animated {
    [self.orentationObserver rotate:orientation animated:animated];
}

- (void)rotate:(SJRotateViewOrientation)orientation animated:(BOOL)animated completion:(void (^ _Nullable)(__kindof SJBaseVideoPlayer *player))block {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL disableRotation = self.disableRotation;
        self.disableRotation = NO;
        __weak typeof(self) _self = self;
        [self.orentationObserver rotate:orientation animated:animated completion:^(SJOrentationObserver * _Nonnull observer) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.disableRotation = disableRotation; // reset
            if ( block ) block(self);
        }];
    });
}

- (void)setDisableRotation:(BOOL)disableRotation {
    objc_setAssociatedObject(self, @selector(disableRotation), @(disableRotation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableRotation {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setWillRotateScreen:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))willRotateScreen {
    objc_setAssociatedObject(self, @selector(willRotateScreen), willRotateScreen, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))willRotateScreen {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRotatedScreen:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))rotatedScreen {
    objc_setAssociatedObject(self, @selector(rotatedScreen), rotatedScreen, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull, BOOL))rotatedScreen {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)isFullScreen {
    return self.orentationObserver.isFullScreen;
}

@end


#pragma mark - 截图

@implementation SJBaseVideoPlayer (Screenshot)

- (void)setPresentationSize:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull, CGSize))presentationSize {
    objc_setAssociatedObject(self, @selector(presentationSize), presentationSize, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof SJBaseVideoPlayer * _Nonnull, CGSize))presentationSize {
    return objc_getAssociatedObject(self, _cmd);
}

- (UIImage * __nullable)screenshot {
    return [self.asset screenshot];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block {
    [self screenshotWithTime:time size:CGSizeZero completion:block];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage * __nullable image, NSError *__nullable error))block {
    __weak typeof(self) _self = self;
    [self.asset screenshotWithTime:time size:size completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, SJVideoPreviewModel * _Nullable images, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( block ) block(self, images.image, error);
        });
    }];
}

- (void)generatedPreviewImagesWithMaxItemSize:(CGSize)itemSize
                                   completion:(void(^)(__kindof SJBaseVideoPlayer *player, NSArray<id<SJVideoPlayerPreviewInfo>> *__nullable images, NSError *__nullable error))block {
    itemSize = CGSizeMake(ceil(itemSize.width), ceil(itemSize.height));
    __weak typeof(self) _self = self;
    [self.asset generatedPreviewImagesWithMaxItemSize:itemSize completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, NSArray<SJVideoPreviewModel *> * _Nullable images, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self, (id)images, error);
    }];
}

@end


#pragma mark - 输出

@implementation SJBaseVideoPlayer (Export)

- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    endTime:(NSTimeInterval)endTime
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, float progress))progressBlock
                 completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, NSURL *fileURL, UIImage *thumbnailImage))completion
                    failure:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, NSError *error))failure {
    if ( !self.asset.loadedPlayer ) {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"msg":@"Resources are being initialized and cannot be exported."}];
        if ( failure ) failure(self, error);
        return;
    }
    __weak typeof(self) _self = self;
    [self.asset exportWithBeginTime:beginTime endTime:endTime presetName:presetName progress:^(SJVideoPlayerAssetCarrier * _Nonnull asset, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( progressBlock ) progressBlock(self, progress);
    } completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, AVAsset * _Nonnull sandboxAsset, NSURL * _Nonnull fileURL, UIImage * _Nonnull thumbImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completion ) completion(self, fileURL, thumbImage);
    } failure:^(SJVideoPlayerAssetCarrier * _Nonnull asset, NSError * _Nonnull error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failure ) failure(self, error);
    }];
}

- (void)cancelExportOperation {
    [self.asset cancelExportOperation];
}

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                        progress:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, float progress))progressBlock
                      completion:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, UIImage *imageGIF, UIImage *thumbnailImage, NSURL *filePath))completion
                         failure:(void(^)(__kindof SJBaseVideoPlayer *videoPlayer, NSError *error))failure {
    if ( !self.asset ) {
        if ( failure ) {
            failure(self, [NSError errorWithDomain:NSCocoaErrorDomain
                                              code:-1
                                          userInfo:@{@"msg":@"Generate Gif Failed! Because `asset` is nil"}]);
        }
        return;
    }
    
    NSURL *filePath = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"SJGeneratedGif.gif"]];
    __weak typeof(self) _self = self;
    [self.asset generateGIFWithBeginTime:beginTime duration:duration maximumSize:CGSizeMake(375, 375) interval:0.25f gifSavePath:filePath progress:^(SJVideoPlayerAssetCarrier * _Nonnull asset, float progress) {
        if ( progressBlock ) progressBlock(self, progress);
    } completion:^(SJVideoPlayerAssetCarrier * _Nonnull asset, UIImage *imageGIF, UIImage * _Nonnull thumbnailImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completion ) completion(self, imageGIF, thumbnailImage, filePath);
    } failure:^(SJVideoPlayerAssetCarrier * _Nonnull asset, NSError * _Nonnull error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failure ) failure(self, error);
    }];
}

- (void)cancelGenerateGIFOperation {
    [self.asset cancelGenerateGIFOperation];
}
@end


#pragma mark - 在`tableView`或`collectionView`上播放

@implementation SJBaseVideoPlayer (ScrollView)

- (BOOL)isPlayOnScrollView {
    return self.asset.scrollView ? YES : NO;
}

- (BOOL)isScrollAppeared {
    return self.scrollIn;
}

- (BOOL)playOnCell {
    return self.asset.indexPath ? YES : NO;
}

- (BOOL)scrollIntoTheCell {
    return self.isScrollAppeared;
}

@end


#pragma mark - 提示

@implementation SJBaseVideoPlayer (Prompt)

- (SJPrompt *)prompt {
    SJPrompt *prompt = objc_getAssociatedObject(self, _cmd);
    if ( prompt ) return prompt;
    prompt = [SJPrompt promptWithPresentView:self.controlContentView];
    prompt.update(^(SJPromptConfig * _Nonnull config) {
        config.cornerRadius = 4;
        config.font = [UIFont systemFontOfSize:12];
    });
    objc_setAssociatedObject(self, _cmd, prompt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return prompt;
}

- (void)showTitle:(NSString *)title {
    [self showTitle:title duration:1];
}

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration {
    [self.prompt showTitle:title duration:duration];
}

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration hiddenExeBlock:(void (^)(__kindof SJBaseVideoPlayer * _Nonnull))hiddenExeBlock {
    __weak typeof(self) _self = self;
    [self.prompt showTitle:title duration:duration hiddenExeBlock:^(SJPrompt * _Nonnull prompt) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( hiddenExeBlock ) hiddenExeBlock(self);
    }];
}

- (void)showAttributedString:(NSAttributedString *)attributedString duration:(NSTimeInterval)duration {
    [self showAttributedString:attributedString duration:duration hiddenExeBlock:nil];
}

- (void)showAttributedString:(NSAttributedString *)attributedString duration:(NSTimeInterval)duration hiddenExeBlock:(void(^__nullable)(__kindof SJBaseVideoPlayer *player))hiddenExeBlock {
    __weak typeof(self) _self = self;
    [self.prompt showAttributedString:attributedString duration:duration hiddenExeBlock:^(SJPrompt * _Nonnull prompt) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( hiddenExeBlock ) hiddenExeBlock(self);
    }];
}

- (void)hiddenTitle {
    [self.prompt hidden];
}

@end


#pragma mark -
#import "SJTimerControl.h"
NS_ASSUME_NONNULL_BEGIN
@interface _SJControlLayerAppearStateManager ()
@property (nonatomic, weak, readonly) SJBaseVideoPlayer *videoPlayer;
@property (nonatomic, strong, readonly) SJTimerControl *controlHiddenTimer;
@property (nonatomic, readwrite) BOOL controlLayerAppearedState;
@end
NS_ASSUME_NONNULL_END

@implementation _SJControlLayerAppearStateManager
@synthesize controlHiddenTimer = _controlHiddenTimer;

- (instancetype)initWithVideoPlayer:(SJBaseVideoPlayer *)videoPlayer {
    self = [super init];
    if ( !self ) return nil;
    _videoPlayer = videoPlayer;
    [_videoPlayer sj_addObserver:self forKeyPath:@"locked"];
    [_videoPlayer sj_addObserver:self forKeyPath:@"state"];
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"locked"] ) {
        if ( _videoPlayer.isLockedScreen ) {
            [self.controlHiddenTimer clear];
        }
        else {
            [self.controlHiddenTimer start];
        }
    }
    else if ( [keyPath isEqualToString:@"state"] ) {
        if ( _videoPlayer.state == SJVideoPlayerPlayState_PlayFailed ) {
            [self layerAppear];
        }
    }
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if ( enabled ) [_controlHiddenTimer start];
    else [_controlHiddenTimer clear];
}

- (void)start {
    if ( !_enabled ) return;
    [_controlHiddenTimer start];
}

- (void)considerChangeState {
    if ( _playFailedToKeepAppearState && self.videoPlayer.state == SJVideoPlayerPlayState_PlayFailed ) return;
    if ( self.controlLayerAppearedState ) [self layerDisappear];
    else [self layerAppear];
}

- (void)layerAppear {
    if ( _pausedToKeepAppearState && self.videoPlayer.state == SJVideoPlayerPlayState_Paused ) [self.controlHiddenTimer clear];
    else if ( _playFailedToKeepAppearState && self.videoPlayer.state == SJVideoPlayerPlayState_PlayFailed ) [self.controlHiddenTimer clear];
    else [self.controlHiddenTimer start];
    [self _changing:YES];
    _initialization = YES;
}

- (void)layerDisappear {
    [self.controlHiddenTimer clear];
    [self _changing:NO];
}

- (void)resetInitialization {
    _initialization = NO;
}

- (SJTimerControl *)controlHiddenTimer {
    if ( _controlHiddenTimer ) return _controlHiddenTimer;
    _controlHiddenTimer = [[SJTimerControl alloc] init];
    __weak typeof(self) _self = self;
    _controlHiddenTimer.exeBlock = ^(SJTimerControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        // 如果控制层显示, 当达到隐藏的条件, `timer`将控制层隐藏. 否则, 清除`timer`.
        if ( self.controlLayerAppearedState &&
            self.videoPlayer.controlLayerDataSource.controlLayerDisappearCondition )
            [self layerDisappear];
        else [control clear];
    };
    return _controlHiddenTimer;
}

#pragma mark -
- (void)_changing:(BOOL)status {
    if ( !self.isEnabled ) return;
    if ( !self.videoPlayer.controlLayerDataSource ) return;
    self.controlLayerAppearedState = status;
    
    if ( status && [self.videoPlayer.controlLayerDelegate respondsToSelector:@selector(controlLayerNeedAppear:)] ) {
        [_videoPlayer.controlLayerDelegate controlLayerNeedAppear:_videoPlayer];
    }
    else if ( !status && [self.videoPlayer.controlLayerDelegate respondsToSelector:@selector(controlLayerNeedDisappear:)] ) {
        [_videoPlayer.controlLayerDelegate controlLayerNeedDisappear:_videoPlayer];
    }
    if ( _videoPlayer.controlLayerAppearStateChanged ) _videoPlayer.controlLayerAppearStateChanged(_videoPlayer, status);
}

@end


#pragma mark -

#import <Reachability/Reachability.h>

NS_ASSUME_NONNULL_BEGIN
@interface _SJReachabilityObserver ()
@property (nonatomic, strong, readonly) Reachability *reachability;
@end
NS_ASSUME_NONNULL_END

@implementation _SJReachabilityObserver

+ (instancetype)sharedInstance {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _reachability = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_reachabilityChangedNotification) name:kReachabilityChangedNotification object:_reachability];
    [_reachability startNotifier];
    return self;
}

- (void)_reachabilityChangedNotification {
    if ( self.reachabilityChangedExeBlock ) {
        SJNetworkStatus status = (NSInteger)[self.reachability currentReachabilityStatus];
        self.reachabilityChangedExeBlock(self, status);
    }
}

- (SJNetworkStatus)networkStatus {
    return (NSInteger)[self.reachability currentReachabilityStatus];
}

- (void)dealloc {
    [_reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:_reachability];
}
@end
