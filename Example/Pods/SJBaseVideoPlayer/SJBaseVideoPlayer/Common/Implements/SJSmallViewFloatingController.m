//
//  SJSmallViewFloatingController.m
//  Pods
//
//  Created by 畅三江 on 2019/6/6.
//

#import "SJSmallViewFloatingController.h"
#import <UIKit/UIGraphicsRendererSubclass.h>
#import "UIView+SJBaseVideoPlayerExtended.h"
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJSmallFloatingView : UIView
@end

@implementation SJSmallFloatingView
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




@interface SJSmallViewFloatingControllerObserver : NSObject<SJSmallViewFloatingControllerObserverProtocol>
- (instancetype)initWithController:(id<SJSmallViewFloatingController>)controller;
@end

@implementation SJSmallViewFloatingControllerObserver
@synthesize onAppearChanged = _onAppearChanged;
@synthesize onEnabled = _onEnabled;
@synthesize controller = _controller;

- (instancetype)initWithController:(id<SJSmallViewFloatingController>)controller {
    self = [super init];
    if ( self ) {
        _controller = controller;
        
        sjkvo_observe(controller, @"isAppeared", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( self.onAppearChanged )
                    self.onAppearChanged(target);
            });
        });
        
        sjkvo_observe(controller, @"enabled", ^(id  _Nonnull target, NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( self.onEnabled )
                    self.onEnabled(target);
            });
        });
    }
    return self;
}
@end

@interface SJSmallViewFloatingController ()<UIGestureRecognizerDelegate> {
    SJSmallFloatingView *_Nullable _floatingView;
}
@property (nonatomic) BOOL isAppeared;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGesture;
@end

@implementation SJSmallViewFloatingController
// 由于tap手势会阻断事件响应链, 为了避免此种情况, 此处无需添加单击和双击手势, 已改为由播放器主动调用这两个block.
//
// 这两个block将来可能会直接移动到播放器中.
@synthesize onSingleTapped = _onSingleTapped;
@synthesize onDoubleTapped = _onDoubleTapped;

@synthesize floatingViewShouldAppear = _floatingViewShouldAppear;
@synthesize targetSuperview = _targetSuperview;
@synthesize enabled = _enabled;
@synthesize target = _target;
@synthesize layoutInsets = _layoutInsets;
@synthesize layoutPosition = _layoutPosition;
@synthesize layoutSize = _layoutSize;

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _layoutInsets = UIEdgeInsetsMake(20, 12, 20, 12);
        _layoutPosition = SJSmallViewLayoutPositionBottomRight;
    }
    return self;
}

- (void)dealloc {
    [_floatingView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
}

- (__kindof UIView *)floatingView {
    if ( _floatingView == nil ) {
        _floatingView = [[SJSmallFloatingView alloc] initWithFrame:CGRectZero];
        [self _addGesturesToFloatView:_floatingView];
    }
    return _floatingView;
}

- (void)show {
    if ( !self.isEnabled ) return;
    
    //
    if ( _floatingViewShouldAppear && _floatingViewShouldAppear(self) ) {
        //
        UIView *superview = nil;
        if ( _addFloatViewToKeyWindow == NO ) {
            UIViewController *currentViewController = [_targetSuperview lookupResponderForClass:UIViewController.class];
            superview = currentViewController.view;
        }
        else {
            superview = UIApplication.sharedApplication.keyWindow;
        }
        
        if ( self.floatingView.superview != superview ) {
            [superview addSubview:_floatingView];
            CGRect superViewBounds = superview.bounds;
            CGFloat superViewWidth = superViewBounds.size.width;
            CGFloat superViewHeight = superViewBounds.size.height;
            
            UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
            if (@available(iOS 11.0, *)) {
                if ( !_ignoreSafeAreaInsets ) safeAreaInsets = superview.safeAreaInsets;
            }

            //
            CGSize size = _layoutSize;
            CGFloat w = size.width;
            CGFloat h = size.height;
            CGFloat x = 0;
            CGFloat y = 0;
            
            if ( CGSizeEqualToSize(CGSizeZero, size) ) {
                CGFloat maxW = ceil(superViewWidth * 0.48);
                w = maxW > 300.0 ? 300.0 : maxW;
                h = w * 9.0 / 16.0;
            }
            
            switch ( _layoutPosition ) {
                case SJSmallViewLayoutPositionTopLeft:
                case SJSmallViewLayoutPositionBottomLeft:
                    x = safeAreaInsets.left + _layoutInsets.left;
                    break;
                case SJSmallViewLayoutPositionTopRight:
                case SJSmallViewLayoutPositionBottomRight:
                    x = superViewWidth - w - _layoutInsets.right - safeAreaInsets.right;
                    break;
            }
              
            switch ( _layoutPosition ) {
                case SJSmallViewLayoutPositionTopLeft:
                case SJSmallViewLayoutPositionTopRight:
                    y = safeAreaInsets.top + _layoutInsets.top;
                    break;
                case SJSmallViewLayoutPositionBottomLeft:
                case SJSmallViewLayoutPositionBottomRight:
                    y = superViewHeight - h - _layoutInsets.bottom - safeAreaInsets.bottom;
                    break;
            }
 
            _floatingView.frame = CGRectMake(x, y, w, h);
        }
        
        //
        self.target.frame = _floatingView.bounds;
        [_floatingView addSubview:self.target];
        [self.target layoutIfNeeded];

        [UIView animateWithDuration:0.3 animations:^{
            self->_floatingView.alpha = 1;
        }];
        
        self.isAppeared = YES;
    }
}

- (void)dismiss {
    if ( !self.isEnabled ) return;
    
    self.target.frame = self.targetSuperview.bounds;
    [self.targetSuperview addSubview:self.target];
    [self.target layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        self->_floatingView.alpha = 0.001;
    }];
    
    self.isAppeared = NO;
}

- (id<SJSmallViewFloatingControllerObserverProtocol>)getObserver {
    return [[SJSmallViewFloatingControllerObserver alloc] initWithController:self];
}

// - gestures -

- (void)_addGesturesToFloatView:(SJSmallFloatingView *)floatingView {
    [floatingView addGestureRecognizer:self.panGesture];
}

- (void)setSlidable:(BOOL)slidable {
    self.panGesture.enabled = slidable;
}
- (BOOL)isSlidable {
    return self.panGesture.enabled;
}

@synthesize panGesture = _panGesture;
- (UIPanGestureRecognizer *)panGesture {
    if ( _panGesture == nil ) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( [otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class] ) {
        otherGestureRecognizer.state = UIGestureRecognizerStateCancelled;
        return YES;
    }
    return NO;
}

- (void)_handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    SJSmallFloatingView *view = _floatingView;
    UIView *superview = view.superview;
    CGPoint offset = [panGesture translationInView:superview];
    CGPoint center = view.center;
    view.center = CGPointMake(center.x + offset.x, center.y + offset.y);
    [panGesture setTranslation:CGPointZero inView:superview];
    
    switch ( panGesture.state ) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
                if (@available(iOS 11.0, *)) {
                    if ( !self.ignoreSafeAreaInsets ) safeAreaInsets = superview.safeAreaInsets;
                }

                CGFloat left = safeAreaInsets.left + self.layoutInsets.left;
                CGFloat right = superview.bounds.size.width - view.w - self.layoutInsets.right - safeAreaInsets.right;
                if ( view.x <= left ) {
                    [view setX:left];
                }
                else if ( view.x >= right ) {
                    [view setX:right];
                }
                
                CGFloat top = safeAreaInsets.top + self.layoutInsets.top;
                CGFloat bottom = superview.bounds.size.height - view.h - self.layoutInsets.bottom - safeAreaInsets.bottom;
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
