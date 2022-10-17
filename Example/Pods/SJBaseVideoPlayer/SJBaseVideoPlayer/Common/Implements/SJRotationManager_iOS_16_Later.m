//
//  SJRotationManager_iOS_16_Later.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJRotationManager_iOS_16_Later.h"
#import "SJRotationManagerInternal.h"
#import "SJRotationFullscreenViewController.h"

API_AVAILABLE(ios(16.0))
@interface SJRotationPortraitOrientationFixingWindow : UIWindow
+ (instancetype)shared;
@end

@implementation SJRotationPortraitOrientationFixingWindow
+ (instancetype)shared {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SJRotationPortraitOrientationFixingWindow.alloc initWithWindowScene:UIApplication.sharedApplication.keyWindow.windowScene ?: (UIWindowScene *)UIApplication.sharedApplication.connectedScenes.anyObject];
    });
    return instance;
}

- (void)setBackgroundColor:(nullable UIColor *)backgroundColor {}

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
#else
API_AVAILABLE(ios(16.0)) @protocol _SJ_iOS_16_IDE_InvisibleMethods <NSObject>
- (void)setNeedsUpdateOfSupportedInterfaceOrientations;
@end
#endif

@interface SJRotationManager_iOS_16_Later ()
@property (nonatomic, strong, readonly) SJRotationFullscreenViewController *rotationFullscreenViewController;
@end

@implementation SJRotationManager_iOS_16_Later
@synthesize rotationFullscreenViewController = _rotationFullscreenViewController;
- (SJRotationFullscreenViewController *)rotationFullscreenViewController {
    if ( _rotationFullscreenViewController == nil ) {
        _rotationFullscreenViewController = [SJRotationFullscreenViewController.alloc init];
    }
    return _rotationFullscreenViewController;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES;
}

- (BOOL)prefersStatusBarHiddenForRotationFullscreenViewController:(SJRotationFullscreenViewController *)viewController {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    if ( window == SJRotationPortraitOrientationFixingWindow.shared )
        return 1 << UIInterfaceOrientationPortrait;
    if ( window == self.window )
        return 1 << self.currentOrientation;
    return UIInterfaceOrientationMaskPortrait;
}

- (void)onDeviceOrientationChanged:(SJOrientation)deviceOrientation {
#ifdef SJDEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
    if ( [self allowsRotation] ) {
        [self rotateToOrientation:deviceOrientation animated:YES complete:nil];
    }
}

- (void)rotateToOrientation:(SJOrientation)orientation animated:(BOOL)animated complete:(void (^)(SJRotationManager * _Nonnull))completionHandler {
    SJOrientation fromOrientation = self.currentOrientation;
    SJOrientation toOrientation = orientation;
    if ( fromOrientation == toOrientation ) {
        if ( completionHandler != nil ) completionHandler(self);
        return;
    }

    self.currentOrientation = orientation;
    [self rotationBegin];
    
    [self transitionBegin];
    UIWindow *sourceWindow = self.superview.window;
    CGRect sourceFrame = [self.superview convertRect:self.superview.bounds toView:sourceWindow];
        
    // prepare
    CGRect screenBounds = UIScreen.mainScreen.bounds;
    CGFloat maxSize = MAX(screenBounds.size.width, screenBounds.size.height);
    CGFloat minSize = MIN(screenBounds.size.width, screenBounds.size.height);

    [self.target setAutoresizingMask:UIViewAutoresizingNone];
    if      ( fromOrientation == SJOrientation_Portrait ) {
        [self.target setFrame:sourceFrame];
        [sourceWindow addSubview:self.target];
        [self.target layoutIfNeeded];
        
        if ( self.window.isHidden ) [self.window makeKeyAndVisible];
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
    }
    else if ( toOrientation == SJOrientation_Portrait ) {
        [self.target removeFromSuperview];
        [self.target setBounds:(CGRect){ CGPointZero, (CGSize){maxSize, minSize} }];
        [self.target setCenter:(CGPoint){ minSize * 0.5, maxSize * 0.5 }];
        switch ( fromOrientation ) {
            case SJOrientation_Portrait: break;
            case SJOrientation_LandscapeLeft:
                self.target.transform = CGAffineTransformMakeRotation(M_PI_2);
                break;
            case SJOrientation_LandscapeRight:
                self.target.transform = CGAffineTransformMakeRotation(-M_PI_2);
                break;
        }
        
        [sourceWindow addSubview:self.target];
        [self.target snapshotViewAfterScreenUpdates:YES];
        [self.target layoutIfNeeded];
        [UIView performWithoutAnimation:^{
            [SJRotationPortraitOrientationFixingWindow.shared makeKeyAndVisible];
            [self.window setHidden:YES];
            [self setNeedsUpdateOfSupportedInterfaceOrientations];
        }];
    }
    
    CGRect rotationBounds = CGRectZero;
    CGPoint rotationCenter = CGPointZero;
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    
    // bounds & center
    switch ( toOrientation ) {
        case SJOrientation_Portrait: {
            rotationBounds = (CGRect){ CGPointZero, sourceFrame.size };
            rotationCenter = (CGPoint){
                sourceFrame.origin.x + rotationBounds.size.width * 0.5,
                sourceFrame.origin.y + rotationBounds.size.height * 0.5,
            };
        }
            break;
        case SJOrientation_LandscapeRight:
        case SJOrientation_LandscapeLeft: {
            rotationBounds = (CGRect){ CGPointZero, (CGSize){maxSize, minSize} };
            rotationCenter = fromOrientation == SJOrientation_Portrait ? (CGPoint){ minSize * 0.5, maxSize * 0.5 } : (CGPoint){ maxSize * 0.5, minSize * 0.5 };
        }
            break;
    }
    
    // transform
    switch ( fromOrientation ) {
        case SJOrientation_Portrait: {
            switch ( toOrientation ) {
                case SJOrientation_Portrait: break;
                case SJOrientation_LandscapeLeft:
                    rotationTransform = CGAffineTransformMakeRotation(M_PI_2);
                    break;
                case SJOrientation_LandscapeRight:
                    rotationTransform = CGAffineTransformMakeRotation(-M_PI_2);
                    break;
            }
        }
            break;
        case SJOrientation_LandscapeLeft: {
            switch ( toOrientation ) {
                case SJOrientation_LandscapeLeft: break;
                case SJOrientation_Portrait:
                case SJOrientation_LandscapeRight:
                    rotationTransform = CGAffineTransformIdentity;
                    break;
            }
        }
            break;
        case SJOrientation_LandscapeRight: {
            switch ( toOrientation ) {
                case SJOrientation_LandscapeRight: break;
                case SJOrientation_Portrait:
                case SJOrientation_LandscapeLeft:
                    rotationTransform = CGAffineTransformIdentity;
                    break;
            }
        }
            break;
    }

    [UIView animateWithDuration:0.0 animations:^{ /* next */ } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.target setBounds:rotationBounds];
            [self.target setCenter:rotationCenter];
            [self.target setTransform:rotationTransform];
            [self.target layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.target setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            if      ( toOrientation == SJOrientation_Portrait ) {
                [sourceWindow becomeKeyWindow];
                [SJRotationPortraitOrientationFixingWindow.shared setHidden:YES];
                [self.superview addSubview:self.target];
                self.target.transform = CGAffineTransformIdentity;
                self.target.bounds = self.superview.bounds;
                self.target.center = (CGPoint){
                    self.target.bounds.size.width * 0.5,
                    self.target.bounds.size.height * 0.5
                };
            }
            else {
                [self setNeedsUpdateOfSupportedInterfaceOrientations];
                if ( self.target.superview != self.rotationFullscreenViewController.view ) [self.rotationFullscreenViewController.view addSubview:self.target];
                self.target.transform = CGAffineTransformIdentity;
                self.target.bounds = self.window.bounds;
                self.target.center = (CGPoint){
                    self.target.bounds.size.width * 0.5,
                    self.target.bounds.size.height * 0.5
                };
            }
            [self.target layoutIfNeeded];
            [self transitionEnd];
            [self rotationEnd];
            if ( completionHandler != nil ) completionHandler(self);
        }];
    }];
}

- (void)setNeedsUpdateOfSupportedInterfaceOrientations {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
    [UIApplication.sharedApplication.keyWindow.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
    [self.window.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
#else
    if ( [self.window.rootViewController respondsToSelector:@selector(setNeedsUpdateOfSupportedInterfaceOrientations)] ) {
        [(id)UIApplication.sharedApplication.keyWindow.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
        [(id)self.window.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
    }
    else {
        [UIViewController attemptRotationToDeviceOrientation];
    }
#endif
}
@end
