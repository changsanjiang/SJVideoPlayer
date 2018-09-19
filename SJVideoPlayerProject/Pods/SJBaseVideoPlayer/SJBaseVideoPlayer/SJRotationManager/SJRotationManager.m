//
//  SJRotationManager.m
//  SJOrentationObserverProject
//
//  Created by 畅三江 on 2018/6/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJRotationManager.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJRotationManager()
@property (nonatomic, strong, readonly) UIView *blackView;
@property (nonatomic) SJOrientation currentOrientation;
@property (nonatomic) BOOL transitioning;
@property (nonatomic) UIDeviceOrientation rec_deviceOrientation;
@property (nonatomic) CGRect con_portraitRect;
@end

@implementation SJRotationManager
@synthesize autorotationSupportedOrientation = _autorotationSupportedOrientation;
@synthesize disableAutorotation = _disableAutorotation;
@synthesize rotationCondition = _rotationCondition;
@synthesize delegate = _delegate;
@synthesize duration = _duration;
@synthesize superview = _superview;
@synthesize target = _target;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    self = [super init];
    if ( !self ) return nil;
    _duration = 0.4;
    _rec_deviceOrientation = UIDeviceOrientationPortrait;
    _blackView = [UIView new]; _blackView.backgroundColor = [UIColor blackColor];
    _autorotationSupportedOrientation = SJAutoRotateSupportedOrientation_All;
    [self _observeNotifies];
    return self;
}

- (void)dealloc {
    [self.blackView removeFromSuperview];
    [self removeNotifies];
}

- (BOOL)isFullscreen {
    return _currentOrientation == SJOrientation_LandscapeLeft || _currentOrientation == SJOrientation_LandscapeRight;
}

- (void)_observeNotifies {
    if ( !UIDevice.currentDevice.isGeneratingDeviceOrientationNotifications ) {
         [UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];
    }
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deviceOrientationDidChangeNotify) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeNotifies {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)deviceOrientationDidChangeNotify {
    UIDeviceOrientation dev_orientation = [UIDevice currentDevice].orientation;

    switch ( dev_orientation ) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            _rec_deviceOrientation = dev_orientation;
        
            if ( self.disableAutorotation ) {
#ifdef DEBUG
                NSLog(@"%d - %s - SJRotationManager - 自动旋转被禁止, 暂时无法旋转!", (int)__LINE__, __func__);
#endif
                return;
            }
        }
            break;
        default:    break;
    }
    
    switch ( dev_orientation ) {
        case UIDeviceOrientationPortrait: {
            if ( [self isSupportedPortrait] ) {
                 [self rotate:SJOrientation_Portrait animated:YES];
            }
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            if ( [self isSupportedLandscapeLeft] ) {
                 [self rotate:SJOrientation_LandscapeLeft animated:YES];
            }
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            if ( [self isSupportedLandscapeRight] ) {
                 [self rotate:SJOrientation_LandscapeRight animated:YES];
            }
        }
            break;
        default:    break;
    }
}
/// 是否支持 Portrait
- (BOOL)isSupportedPortrait {
    return _autorotationSupportedOrientation & SJAutoRotateSupportedOrientation_Portrait;
}
/// 是否支持 LandscapeLeft
- (BOOL)isSupportedLandscapeLeft {
    return _autorotationSupportedOrientation & SJAutoRotateSupportedOrientation_LandscapeLeft;
}
/// 是否支持 LandscapeRight
- (BOOL)isSupportedLandscapeRight {
    return _autorotationSupportedOrientation & SJAutoRotateSupportedOrientation_LandscapeRight;
}
/// 当前方向是否与设备方向一致
- (BOOL)isCurrentOrientationAsDeviceOrientation {
    switch ( _rec_deviceOrientation ) {
        case UIDeviceOrientationLandscapeLeft: {
            if ( self.currentOrientation == SJOrientation_LandscapeLeft ) return YES;
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            if ( self.currentOrientation == SJOrientation_LandscapeRight ) return YES;
        }
            break;
        default: break;
    }
    return NO;
}

- (void)rotate {
    // 如果是全屏状态 并且 支持 Portrait
    if ( self.isFullscreen && [self isSupportedPortrait] ) {
         [self rotate:SJOrientation_Portrait animated:YES];

        return;
    }
    
    // 不是全屏或者不支持竖屏
    // 就是要全屏
    // 查看当前方向是否与设备方向一致
    // 如果不一致, 当前设备朝哪个方向, 就旋转到那个方向
    if ( ![self isCurrentOrientationAsDeviceOrientation] ) {
        switch ( _rec_deviceOrientation ) {
            case UIDeviceOrientationPortrait:
            case UIDeviceOrientationLandscapeLeft:
                if ( [self isSupportedLandscapeLeft] ) {
                     [self rotate:SJOrientation_LandscapeLeft animated:YES];
                }
                break;
            case UIDeviceOrientationLandscapeRight: {
                if ( [self isSupportedLandscapeRight] ) {
                     [self rotate:SJOrientation_LandscapeRight animated:YES];
                }
            }
                break;
            default: break;
        }
        
        return;
    }
    
    // 如果方向一致, 就旋转到相反的方向
    switch ( _rec_deviceOrientation ) {
        case UIDeviceOrientationLandscapeLeft:
            if ( [self isSupportedLandscapeRight] ) {
                 [self rotate:SJOrientation_LandscapeRight animated:YES];
            }
            break;
        case UIDeviceOrientationLandscapeRight: {
            if ( [self isSupportedLandscapeLeft] ) {
                 [self rotate:SJOrientation_LandscapeLeft animated:YES];
            }
        }
            break;
        default: break;
    }
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated {
    [self rotate:orientation animated:animated completionHandler:nil];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void (^)(SJRotationManager * _Nonnull))completionHandler {
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.transitioning ) return;
        if ( !self.superview ) return;
        if ( !self.target ) return;
        if ( self.rotationCondition ) { if ( !self.rotationCondition(self) ) return; }
        SJOrientation ori_old = self.currentOrientation;
        SJOrientation ori_new = orientation;
        if ( ori_old == ori_new ) { if ( completionHandler ) completionHandler(self); return; }
        UIWindow *window = [(id)[UIApplication sharedApplication].delegate valueForKey:@"window"];
        if ( !window ) return;
        CGAffineTransform transform = CGAffineTransformIdentity;
        UIInterfaceOrientation statusBarOrientation = UIInterfaceOrientationUnknown;
        switch ( ori_new ) {
            case SJOrientation_Portrait: {
                statusBarOrientation = UIInterfaceOrientationPortrait;
                if ( self.blackView.superview != nil ) { [self.blackView removeFromSuperview]; }
            }
                break;
            case SJOrientation_LandscapeLeft: {
                statusBarOrientation = UIInterfaceOrientationLandscapeRight;
                transform = CGAffineTransformMakeRotation(M_PI_2);
            }
                break;
            case SJOrientation_LandscapeRight: {
                statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
                transform = CGAffineTransformMakeRotation(-M_PI_2);

            }
                break;
        }
        
        // update
        self.con_portraitRect = [window convertRect:self.superview.bounds fromView:self.superview];

        if ( ori_old == SJOrientation_Portrait ) {
            self.target.translatesAutoresizingMaskIntoConstraints = YES;
            self.target.frame = self.con_portraitRect;
            [window addSubview:self.target];
        }

        // update
        self.currentOrientation = ori_new;
        self.transitioning = true;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarOrientation:statusBarOrientation animated:NO];
#pragma clang diagnostic pop
        
        if ( [self.delegate respondsToSelector:@selector(rotationManager:willRotateView:)] ) {
             [self.delegate rotationManager:self willRotateView:self.isFullscreen];
        }
        [UIView animateWithDuration:animated ? self.duration : 0 animations:^{
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( ori_new == SJOrientation_Portrait ) {
                self.target.transform = transform;
                self.target.bounds = (CGRect){CGPointZero, self.con_portraitRect.size};
                self.target.center =
                (CGPoint){self.con_portraitRect.origin.x +
                          self.con_portraitRect.size.width * 0.5,
                          self.con_portraitRect.origin.y +
                          self.con_portraitRect.size.height * 0.5};
                [self.target layoutIfNeeded];
            }
            else {
                CGFloat width  = window.bounds.size.width;
                CGFloat height = window.bounds.size.height;
                CGFloat max = MAX(width, height);
                CGFloat min = MIN(width, height);
                self.target.bounds = (CGRect){CGPointZero, (CGSize){max, min}};
                self.target.center = (CGPoint){min * 0.5, max * 0.5};
                [self.target layoutIfNeeded];
                self.target.transform = transform;
            }
        } completion:^(BOOL finished) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( self.currentOrientation == SJOrientation_Portrait ) {
                [self.superview addSubview:self.target];
                self.target.frame = self.superview.bounds;
            }
            else {
                self.blackView.bounds = self.target.bounds;
                self.blackView.center = self.target.center;
                self.blackView.transform = self.target.transform;
                [window insertSubview:self.blackView belowSubview:self.target];
            }
            self.transitioning = false;
            if ( [self.delegate respondsToSelector:@selector(rotationManager:didRotateView:)] ) {
                 [self.delegate rotationManager:self didRotateView:self.isFullscreen];
            }
            if ( completionHandler ) completionHandler(self);
        }];
    });
}
@end
NS_ASSUME_NONNULL_END
