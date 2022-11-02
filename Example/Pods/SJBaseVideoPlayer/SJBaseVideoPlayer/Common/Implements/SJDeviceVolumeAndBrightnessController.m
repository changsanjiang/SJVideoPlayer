//
//  SJDeviceVolumeAndBrightnessController.m
//  SJDeviceVolumeAndBrightnessController
//
//  Created by 畅三江 on 2017/12/10.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJDeviceVolumeAndBrightnessController.h"
#import "SJBaseVideoPlayerResourceLoader.h"
#import "SJBaseVideoPlayerConst.h"
#import "SJPlayerView.h"
#import "SJDeviceVolumeAndBrightness.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPVolumeView.h>
#import "UIView+SJBaseVideoPlayerExtended.h"

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#import <SJUIKit/SJRunLoopTaskQueue.h>
#else
#import "NSObject+SJObserverHelper.h"
#import "SJRunLoopTaskQueue.h"
#endif
@protocol SJDeviceVolumeAndBrightnessPopupViewDataSource;

static NSNotificationName const SJDeviceVolumeDidChangeNotification = @"SJDeviceVolumeDidChangeNotification";
static NSNotificationName const SJDeviceBrightnessDidChangeNotification = @"SJDeviceBrightnessDidChangeNotification";

@interface SJDeviceVolumeAndBrightnessControllerObserver : NSObject<SJDeviceVolumeAndBrightnessControllerObserver>
- (instancetype)initWithMgr:(id<SJDeviceVolumeAndBrightnessController>)mgr;
@end

@implementation SJDeviceVolumeAndBrightnessControllerObserver {
    id _volumeDidChangeToken;
    id _brightnessDidChangeToken;
}
@synthesize volumeDidChangeExeBlock = _volumeDidChangeExeBlock;
@synthesize brightnessDidChangeExeBlock = _brightnessDidChangeExeBlock;

- (instancetype)initWithMgr:(id<SJDeviceVolumeAndBrightnessController>)mgr {
    self = [super init];
    if ( !self )
        return nil;
    __weak typeof(self) _self = self;
    _volumeDidChangeToken = [NSNotificationCenter.defaultCenter addObserverForName:SJDeviceVolumeDidChangeNotification object:mgr queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        id<SJDeviceVolumeAndBrightnessController> mgr = note.object;
        if ( self.volumeDidChangeExeBlock ) self.volumeDidChangeExeBlock(mgr, mgr.volume);
    }];
    
    _brightnessDidChangeToken = [NSNotificationCenter.defaultCenter addObserverForName:SJDeviceBrightnessDidChangeNotification object:mgr queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        id<SJDeviceVolumeAndBrightnessController> mgr = note.object;
        if ( self.brightnessDidChangeExeBlock ) self.brightnessDidChangeExeBlock(mgr, mgr.brightness);
    }];
    return self;
}

- (void)dealloc {
    if ( _volumeDidChangeToken ) [NSNotificationCenter.defaultCenter removeObserver:_volumeDidChangeToken];
    if ( _brightnessDidChangeToken ) [NSNotificationCenter.defaultCenter removeObserver:_brightnessDidChangeToken];
}
@end


#pragma mark - SJDeviceVolumeAndBrightnessPopupView

@interface SJDeviceVolumeAndBrightnessPopupView : UIView<SJDeviceVolumeAndBrightnessPopupView>
@property (nonatomic, strong) id<SJDeviceVolumeAndBrightnessPopupViewDataSource> dataSource;

- (void)refreshData;
@end

@interface SJDeviceVolumeAndBrightnessPopupView ()
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIProgressView *progressView;
@end

@implementation SJDeviceVolumeAndBrightnessPopupView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)refreshData {
    _imageView.image = (_dataSource.progress > 0) ? _dataSource.image : (_dataSource.startImage ?: _dataSource.image);
    _progressView.progress = _dataSource.progress;
    _progressView.trackTintColor = _dataSource.trackColor;
    _progressView.progressTintColor = _dataSource.traceColor;
}

- (void)_setupView {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.layer.cornerRadius = 5;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_imageView];
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    _progressView.progress = 0.5;
    [self addSubview:_progressView];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.offset(0);
        make.width.equalTo(self.imageView.mas_height);
        make.height.offset(38);
    }];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.mas_right).offset(5);
        make.centerY.offset(0);
        make.right.offset(-12);
        make.height.offset(2);
        make.width.offset(100);
    }];
    
    [_imageView setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
    [_progressView setContentHuggingPriority:250 forAxis:UILayoutConstraintAxisHorizontal];
}
@end

@interface SJDeviceVolumeAndBrightnessPopupItem : NSObject<SJDeviceVolumeAndBrightnessPopupViewDataSource>
@property (nonatomic, strong, nullable) UIImage *startImage;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic) float progress;
@property (nonatomic, strong, null_resettable) UIColor *traceColor;
@property (nonatomic, strong, null_resettable) UIColor *trackColor;
@end
@implementation SJDeviceVolumeAndBrightnessPopupItem
- (UIColor *)traceColor {
    return _traceColor?:UIColor.whiteColor;
}

- (UIColor *)trackColor {
    return _trackColor?:[UIColor colorWithWhite:0.6 alpha:0.5];
}
@end

#pragma mark -

@interface SJDeviceVolumeAndBrightnessController ()<SJDeviceVolumeAndBrightnessObserver> {
    UIView *_sysVolumeView;
}
@end

@implementation SJDeviceVolumeAndBrightnessController
@synthesize target = _target;
@synthesize targetViewContext = _targetViewContext;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _sysVolumeView = SJDeviceVolumeAndBrightness.shared.sysVolumeView;
    [SJDeviceVolumeAndBrightness.shared addObserver:self];
    [SJDeviceSystemVolumeViewDisplayManager.shared addController:self];
    return self;
}

- (void)dealloc {
    [SJDeviceVolumeAndBrightness.shared removeObserver:self];
    [SJDeviceSystemVolumeViewDisplayManager.shared removeController:self];
}

- (void)device:(SJDeviceVolumeAndBrightness *)device onVolumeChanged:(float)volume {
    [self _onVolumeChanged];
}

- (void)device:(SJDeviceVolumeAndBrightness *)device onBrightnessChanged:(float)brightness {
    [self _onBrightnessChanged];
}

- (id<SJDeviceVolumeAndBrightnessControllerObserver>)getObserver {
    return [[SJDeviceVolumeAndBrightnessControllerObserver alloc] initWithMgr:self];
}

- (void)onTargetViewMoveToWindow {
    [SJDeviceSystemVolumeViewDisplayManager.shared update];
}

- (void)onTargetViewContextUpdated {
    [SJDeviceSystemVolumeViewDisplayManager.shared update];
}

#pragma mark - volume

- (void)_onVolumeChanged {
    [self _showVolumeViewIfNeeded];
    [self _updateContentsForVolumeViewIfNeeded];
    [NSNotificationCenter.defaultCenter postNotificationName:SJDeviceVolumeDidChangeNotification object:self];
}

- (void)setVolume:(float)volume {
    SJDeviceVolumeAndBrightness.shared.volume = volume;
}

- (float)volume {
    return SJDeviceVolumeAndBrightness.shared.volume;
}

- (nullable UIView<SJDeviceVolumeAndBrightnessPopupView> *)volumeView {
    if ( _volumeView == nil ) {
        _volumeView = [SJDeviceVolumeAndBrightnessPopupView new];
        SJDeviceVolumeAndBrightnessPopupItem *model = [SJDeviceVolumeAndBrightnessPopupItem new];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *muteImage = [SJBaseVideoPlayerResourceLoader imageNamed:@"mute"];
            UIImage *volumeImage = [SJBaseVideoPlayerResourceLoader imageNamed:@"volume"];
            dispatch_async(dispatch_get_main_queue(), ^{
                model.startImage = muteImage;
                model.image = volumeImage;
                [self->_volumeView refreshData];
            });
        });
        _volumeView.dataSource = model;
    }
    return _volumeView;
}

- (void)_showVolumeViewIfNeeded {
    if ( _sysVolumeView.superview == nil || !SJDeviceSystemVolumeViewDisplayManager.shared.automaticallyDisplaySystemVolumeView ) return;
    UIView *targetView = self.target;
    UIView *volumeView = self.volumeView;
    if ( targetView.window != nil && volumeView.superview != targetView ) {
        [targetView addSubview:volumeView];
        [volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.offset(0);
        }];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideVolumeView) object:nil];
    [self performSelector:@selector(_hideVolumeView)
               withObject:nil
               afterDelay:1
                  inModes:@[NSRunLoopCommonModes]];
}

- (void)_hideVolumeView {
    UIView *volumeView = self.volumeView;
    [volumeView removeFromSuperview];
}

- (void)_updateContentsForVolumeViewIfNeeded {
    if ( self.volumeView.superview == nil ) return;
    float volume = self.volume;
    self.volumeView.dataSource.progress = volume;
    [self.volumeView refreshData];
}

#pragma mark - brightness

- (void)_onBrightnessChanged {
    [self _showBrightnessView];
    [self _updateContentsForBrightnessViewIfNeeded];
    [NSNotificationCenter.defaultCenter postNotificationName:SJDeviceBrightnessDidChangeNotification object:self];
}

- (void)setBrightness:(float)brightness {
    SJDeviceVolumeAndBrightness.shared.brightness = brightness;
}

- (float)brightness {
    return SJDeviceVolumeAndBrightness.shared.brightness;
}

- (nullable UIView<SJDeviceVolumeAndBrightnessPopupView> *)brightnessView {
    if ( _brightnessView == nil ) {
        _brightnessView = [SJDeviceVolumeAndBrightnessPopupView new];
        
        SJDeviceVolumeAndBrightnessPopupItem *model = [SJDeviceVolumeAndBrightnessPopupItem new];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [SJBaseVideoPlayerResourceLoader imageNamed:@"brightness"];
            dispatch_async(dispatch_get_main_queue(), ^{
                model.startImage = image;
                model.image = image;
                [self->_brightnessView refreshData];
            });
        });
        _brightnessView.dataSource = model;
    }
    return _brightnessView;
}

- (void)_updateContentsForBrightnessViewIfNeeded {
    if (self.brightnessView.superview == nil ) return;
    float brightness = self.brightness;
    self.brightnessView.dataSource.progress = brightness;
    [self.brightnessView refreshData];
}

- (void)_showBrightnessView {
    UIView *targetView = self.target;
    UIView *brightnessView = self.brightnessView;
    
    if ( targetView != nil && brightnessView.superview != targetView ) {
        [targetView addSubview:brightnessView];
        [brightnessView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.offset(0);
        }];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideBrightnessView) object:nil];
    [self performSelector:@selector(_hideBrightnessView)
               withObject:nil
               afterDelay:1
                  inModes:@[NSRunLoopCommonModes]];
}

- (void)_hideBrightnessView {
    UIView *brightnessView = self.brightnessView;
    [brightnessView removeFromSuperview];
}
@end


@implementation SJDeviceSystemVolumeViewDisplayManager {
    NSHashTable<id<SJDeviceVolumeAndBrightnessController>> *mControllers;
    UIView *mSysVolumeView;
}

+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _automaticallyDisplaySystemVolumeView = YES;
        mControllers = NSHashTable.weakObjectsHashTable;
        mSysVolumeView = SJDeviceVolumeAndBrightness.shared.sysVolumeView;
        [self _makeHidingForSysVolumeView];
    }
    return self;
}

- (void)addController:(nullable id<SJDeviceVolumeAndBrightnessController>)controller {
    [mControllers addObject:controller];
}

- (void)removeController:(nullable id<SJDeviceVolumeAndBrightnessController>)controller {
    [mControllers removeObject:controller];
}

- (void)update {
//    1. 未显示或不在keyWindow中时则略过
//    2. 根据状态确定是否显示系统音量条
//       2.1 处于 fullscreen or fitOnScreen 隐藏系统条
//       2.2 小屏状态
//           2.2.1 在cell中播放, 显示系统条
//           2.2.2 小浮窗模式, 显示系统条
//           2.2.3 画中画模式, 显示系统条
//           2.2.x 常规模式隐藏系统条
    BOOL needsShowing = YES;
    if ( _automaticallyDisplaySystemVolumeView ) {
        for ( id<SJDeviceVolumeAndBrightnessController> controller in mControllers ) {
            UIView *targetView = controller.target;
            UIWindow *targetViewWindow = targetView.window;
            UIWindow *appKeyWindow = UIApplication.sharedApplication.keyWindow;
            if ( targetViewWindow == nil || targetViewWindow != appKeyWindow ) {
                // 1. 未显示或不在keyWindow中时则略过
                continue;
            }
            
            id<SJDeviceVolumeAndBrightnessTargetViewContext> ctx = controller.targetViewContext;
            // 2.1
            if ( ctx.isFullscreen || ctx.isFitOnScreen ) {
                needsShowing = NO;
                [self _makeHidingForSysVolumeView];
                break;
            }
            // 2.2
            else {
                // 2.2.1
                if ( ctx.isPlayOnScrollView ) {
                    needsShowing = NO;
                    [self _makeShowingForSysVolumeView];
                    break;
                }
                // 2.2.2
                if ( ctx.isFloatingMode ) {
                    needsShowing = NO;
                    [self _makeShowingForSysVolumeView];
                    break;
                }
                // 2.2.3
                if ( ctx.isPictureInPictureMode ) {
                    needsShowing = NO;
                    [self _makeShowingForSysVolumeView];
                    break;
                }
                // 2.2.x
                needsShowing = NO;
                [self _makeHidingForSysVolumeView];
            }
        }
    }
    if ( needsShowing ) [self _makeShowingForSysVolumeView];
}

#pragma mark - mark

// 隐藏系统音量条
- (void)_makeHidingForSysVolumeView {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if ( mSysVolumeView.superview != window ) [window addSubview:mSysVolumeView];
}

// 显示系统音量条
- (void)_makeShowingForSysVolumeView {
    if ( mSysVolumeView.superview != nil ) [mSysVolumeView removeFromSuperview];
}
@end
