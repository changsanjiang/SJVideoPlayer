//
//  SJFloatSmallViewController.m
//  Pods
//
//  Created by 畅三江 on 2019/6/6.
//

#import "SJFloatSmallViewController.h"
#import "UIView+SJBaseVideoPlayerExtended.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJFloatSmallView : UIView
@end

@implementation SJFloatSmallView
- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (CGFloat)w {
    return self.frame.size.width;
}

- (CGFloat)h {
    return self.frame.size.height;
}
@end




@interface SJFloatSmallViewControllerObserver : NSObject<SJFloatSmallViewControllerObserverProtocol>
- (instancetype)initWithController:(id<SJFloatSmallViewController>)controller;
@end

@implementation SJFloatSmallViewControllerObserver
@synthesize appearStateDidChangeExeBlock = _appearStateDidChangeExeBlock;
@synthesize enabledControllerExeBlock = _enabledControllerExeBlock;
@synthesize controller = _controller;

- (instancetype)initWithController:(id<SJFloatSmallViewController>)controller {
    self = [super init];
    if ( self ) {
        _controller = controller;
        
        sjkvo_observe(controller, @"isAppeared", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( self.appearStateDidChangeExeBlock )
                    self.appearStateDidChangeExeBlock(target);
            });
        });
        
        sjkvo_observe(controller, @"enabled", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( self.enabledControllerExeBlock )
                    self.enabledControllerExeBlock(target);
            });
        });
    }
    return self;
}
@end

@interface SJFloatSmallViewController ()<UIGestureRecognizerDelegate> {
    SJFloatSmallView *_Nullable _floatView;
}
@property (nonatomic) BOOL isAppeared;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGesture;
@end

@implementation SJFloatSmallViewController
// 由于tap手势会阻断事件响应链, 为了避免此种情况, 此处无需添加单击和双击手势, 已改为由播放器主动调用这两个block.
//
// 这两个block将来可能会直接移动到播放器中.
@synthesize singleTappedOnTheFloatViewExeBlock = _singleTappedOnTheFloatViewExeBlock;
@synthesize doubleTappedOnTheFloatViewExeBlock = _doubleTappedOnTheFloatViewExeBlock;

@synthesize floatViewShouldAppear = _floatViewShouldAppear;
@synthesize targetSuperview = _targetSuperview;
@synthesize enabled = _enabled;
@synthesize target = _target;
@synthesize safeMargin = _safeMargin;
@synthesize addFloatViewToKeyWindow = _addFloatViewToKeyWindow;

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _safeMargin = 12;
    }
    return self;
}

- (void)dealloc {
    [_floatView removeFromSuperview];
}

- (__kindof UIView *)floatView {
    if ( _floatView == nil ) {
        _floatView = [[SJFloatSmallView alloc] initWithFrame:CGRectZero];
        [self _addGesturesToFloatView:_floatView];
    }
    return _floatView;
}

- (void)showFloatView {
    if ( !self.isEnabled ) return;
    
    //
    if ( _floatViewShouldAppear && _floatViewShouldAppear(self) ) {
        //
        UIView *superview = nil;
        if ( _addFloatViewToKeyWindow == NO ) {
            UIViewController *currentViewController = [_targetSuperview lookupResponderForClass:UIViewController.class];
            superview = currentViewController.view;
        }
        else {
            superview = UIApplication.sharedApplication.keyWindow;
        }
        if ( self.floatView.superview != superview ) {
            [superview addSubview:_floatView];
            CGRect bounds = superview.bounds;
            CGFloat width = bounds.size.width;
            
            //
            CGFloat maxW = ceil(width * 0.48);
            CGFloat w = maxW>300?300:maxW;
            CGFloat h = w * 9 /16.0;
            CGFloat x = width - w - _safeMargin;
            CGFloat y = _safeMargin;
            if (@available(iOS 11.0, *)) {
                y += superview.safeAreaInsets.top;
            }

            _floatView.frame = CGRectMake(x, y, w, h);
        }
        
        //
        self.target.frame = _floatView.bounds;
        [_floatView addSubview:self.target];
        [self.target layoutIfNeeded];

        [UIView animateWithDuration:0.3 animations:^{
            self->_floatView.alpha = 1;
        }];
        
        self.isAppeared = YES;
    }
}

- (void)dismissFloatView {
    if ( !self.isEnabled ) return;
    
    self.target.frame = self.targetSuperview.bounds;
    [self.targetSuperview addSubview:self.target];
    [self.target layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        self->_floatView.alpha = 0.001;
    }];
    
    self.isAppeared = NO;
}

- (id<SJFloatSmallViewControllerObserverProtocol>)getObserver {
    return [[SJFloatSmallViewControllerObserver alloc] initWithController:self];
}

// - gestures -

- (void)_addGesturesToFloatView:(SJFloatSmallView *)floatView {
    [floatView addGestureRecognizer:self.panGesture];
}

- (void)setSlidable:(BOOL)slidable {
    self.panGesture.enabled = slidable;
}
- (BOOL)slidable {
    return self.panGesture.enabled;
}

@synthesize panGesture = _panGesture;
- (UIPanGestureRecognizer *)panGesture {
    if ( _panGesture == nil ) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
    }
    return _panGesture;
}

- (void)_handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    SJFloatSmallView *view = _floatView;
    UIView *superview = view.superview;
    CGPoint offset = [panGesture translationInView:superview];
    CGPoint center = view.center;
    view.center = CGPointMake(center.x + offset.x, center.y + offset.y);
    [panGesture setTranslation:CGPointZero inView:superview];
    
    switch ( panGesture.state ) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            CGFloat safeMargin = _safeMargin;
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGFloat left = safeMargin;
                CGFloat right = UIScreen.mainScreen.bounds.size.width - safeMargin - view.w;
                if ( view.x <= left ) {
                    [view setX:left];
                }
                else if ( view.x >= right ) {
                    [view setX:right];
                }
                
                UIEdgeInsets insets = UIEdgeInsetsZero;
                if (@available(iOS 11.0, *)) {
                    insets = superview.safeAreaInsets;
                }
                CGFloat top = insets.top + safeMargin;
                CGFloat bottom = superview.bounds.size.height - (insets.bottom + safeMargin + view.h);
                if ( view.y <= top ) {
                    [view setY:top];
                }
                else if ( view.y >= bottom ) {
                    [view setY:bottom];
                }
            } completion:nil];
        }
            break;
        default: break;
    }
}

@end
NS_ASSUME_NONNULL_END
