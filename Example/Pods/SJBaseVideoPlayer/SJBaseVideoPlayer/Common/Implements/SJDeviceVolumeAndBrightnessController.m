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

NS_ASSUME_NONNULL_BEGIN
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
    _imageView.image = (_dataSource.progress > 0) ? _dataSource.image : _dataSource.startImage;
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
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) UIImage *startImage;
@property (nonatomic) float progress;
@property (nonatomic, strong, nullable) UIColor *traceColor;
@property (nonatomic, strong, nullable) UIColor *trackColor;
@end
@implementation SJDeviceVolumeAndBrightnessPopupItem

@end

#pragma mark -

@interface SJDeviceVolumeAndBrightnessController ()<SJDeviceVolumeAndBrightnessObserver> {
    UIView *_sysVolumeView;
}
@end

@implementation SJDeviceVolumeAndBrightnessController
@synthesize showsPopupView = _showsPopupView;
@synthesize target = _target;
@synthesize volumeTracking = _volumeTracking;
@synthesize brightnessTracking = _brightnessTracking;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _showsPopupView = YES;
    _sysVolumeView = SJDeviceVolumeAndBrightness.shared.sysVolumeView;
    [SJDeviceVolumeAndBrightness.shared addObserver:self];
    return self;
}

- (void)dealloc {
    [SJDeviceVolumeAndBrightness.shared removeObserver:self];
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

#pragma mark - volume

- (void)_showSysVolumeViewIfPossible {
    UIView *targetView = self.target;
    UIWindow *targetWindow = targetView.window;
    if ( ![targetWindow isViewAppeared:targetView insets:UIEdgeInsetsZero] ) {
        if ( _sysVolumeView.superview != targetWindow ) [targetWindow addSubview:_sysVolumeView];
    }
}

- (void)_hideSysVolumeView {
    UIView *sysVolumeView = SJDeviceVolumeAndBrightness.shared.sysVolumeView;
    if ( sysVolumeView.superview != nil ) [sysVolumeView removeFromSuperview];
}

- (void)_onVolumeChanged {
    [self _showSysVolumeViewIfPossible];
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
        model.trackColor = self.trackColor;
        model.traceColor = self.traceColor;
        _volumeView.dataSource = model;
    }
    return _volumeView;
}

- (void)_showVolumeViewIfNeeded {
    if ( !_showsPopupView ) return;
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

- (void)_updateContentsForVolumeViewIfNeeded {
    if ( !_showsPopupView || self.volumeView.superview == nil ) return;
    float volume = self.volume;
    self.volumeView.dataSource.progress = volume;
    [self.volumeView refreshData];
}

- (void)_hideVolumeView {
    UIView *volumeView = self.volumeView;
    [volumeView removeFromSuperview];
    [self _hideSysVolumeView];
}

#pragma mark - brightness

- (void)_onBrightnessChanged {
    [self _showBrightnessViewIfNeeded];
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
        
        model.trackColor = self.trackColor;
        model.traceColor = self.traceColor;
        _brightnessView.dataSource = model;
    }
    return _brightnessView;
}

- (void)_showBrightnessViewIfNeeded {
    if ( !_showsPopupView ) return;
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

- (void)_updateContentsForBrightnessViewIfNeeded {
    if ( !_showsPopupView || self.brightnessView.superview == nil ) return;
    float brightness = self.brightness;
    self.brightnessView.dataSource.progress = brightness;
    [self.brightnessView refreshData];
}

- (void)_hideBrightnessView {
    UIView *brightnessView = self.brightnessView;
    [brightnessView removeFromSuperview];
}

#pragma mark - notifies

//- (void)handleVolumeDidChangeEvent {
//    UIView *targetView = self.targetView;
//    [self _addOrRemoveSysVolumeView:targetView.window];
//    if ( self.isVolumeTracking == NO ) {
//        [self _syncVolume];
//        if ( targetView.window != nil ) {
//            self.volumeTracking = YES;
//            [self _volumeDidChange];
//            self.volumeTracking = NO;
//        }
//    }
//
//    [NSNotificationCenter.defaultCenter postNotificationName:SJDeviceVolumeDidChangeNotification object:self];
//}
//
//- (void)handleBrightnessDidChangeNotification {
//    if ( !self.isBrightnessTracking )
//        [self _refreshDataForBrightnessView];
//    [NSNotificationCenter.defaultCenter postNotificationName:SJDeviceBrightnessDidChangeNotification object:self];
//}

#pragma mark - colors

@synthesize traceColor = _traceColor;
- (void)setTraceColor:(nullable UIColor *)traceColor {
    _traceColor = traceColor;
    
    self.volumeView.dataSource.traceColor = self.brightnessView.dataSource.traceColor = self.traceColor;
    [self.brightnessView refreshData];
    [self.volumeView refreshData];
}

- (UIColor *)traceColor {
    return _traceColor?:UIColor.whiteColor;
}

@synthesize trackColor = _trackColor;
- (void)setTrackColor:(nullable UIColor *)trackColor {
    _trackColor = trackColor;
    
    self.volumeView.dataSource.trackColor = self.brightnessView.dataSource.trackColor = self.trackColor;
    [self.brightnessView refreshData];
    [self.volumeView refreshData];
}
- (UIColor *)trackColor {
    return _trackColor?:[UIColor colorWithWhite:0.6 alpha:0.5];
}
@end
NS_ASSUME_NONNULL_END
