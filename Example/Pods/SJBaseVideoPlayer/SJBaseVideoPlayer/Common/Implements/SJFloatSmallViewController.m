//
//  SJFloatSmallViewController.m
//  Pods
//
//  Created by 畅三江 on 2019/6/6.
//

#import "SJFloatSmallViewController.h"
#import <UIKit/UIGraphicsRendererSubclass.h>
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
@synthesize layoutInsets = _layoutInsets;
@synthesize layoutPosition = _layoutPosition;
@synthesize addFloatViewToKeyWindow = _addFloatViewToKeyWindow;
@synthesize layoutSize = _layoutSize;

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _layoutInsets = UIEdgeInsetsMake(20, 12, 20, 12);
        _layoutPosition = SJFloatViewLayoutPositionBottomRight;
    }
    return self;
}

- (void)dealloc {
    [_floatView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
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
                case SJFloatViewLayoutPositionTopLeft:
                case SJFloatViewLayoutPositionBottomLeft:
                    x = safeAreaInsets.left + _layoutInsets.left;
                    break;
                case SJFloatViewLayoutPositionTopRight:
                case SJFloatViewLayoutPositionBottomRight:
                    x = superViewWidth - w - _layoutInsets.right - safeAreaInsets.right;
                    break;
            }
              
            switch ( _layoutPosition ) {
                case SJFloatViewLayoutPositionTopLeft:
                case SJFloatViewLayoutPositionTopRight:
                    y = safeAreaInsets.top + _layoutInsets.top;
                    break;
                case SJFloatViewLayoutPositionBottomLeft:
                case SJFloatViewLayoutPositionBottomRight:
                    y = superViewHeight - h - _layoutInsets.bottom - safeAreaInsets.bottom;
                    break;
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
