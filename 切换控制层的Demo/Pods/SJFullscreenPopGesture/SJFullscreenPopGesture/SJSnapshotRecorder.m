//
//  SJSnapshotServer.m
//  SJBackGRProject
//
//  Created by BlueDancer on 2018/4/16.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJSnapshotRecorder.h"
#import <objc/message.h>
#import "UIViewController+SJVideoPlayerAdd.h"

NS_ASSUME_NONNULL_BEGIN

static const char *kSJSnapshot = "kSJSnapshot";

@interface SJSnapshotRecorder : NSObject
@property (nonatomic, strong, readonly) UIView *rootView;
@property (nonatomic, strong, readonly, nullable) UIView *nav_bar_snapshotView;
@property (nonatomic, strong, readonly, nullable) UIView *tab_bar_snapshotView;
@property (nonatomic, strong, readonly, nullable) UIView *preSnapshotView;
@property (nonatomic, strong, readonly) UIView *preViewContainerView;
@property (nonatomic, strong, readonly) UIView *shadeView;
- (instancetype)initWithNavigationController:(__weak UINavigationController *__nullable)nav index:(NSInteger)index;
- (instancetype)init;

- (void)preparePopViewController;
- (void)endPopViewController;
@end

@interface SJSnapshotRecorder () {
    __weak UINavigationController *_nav;
    NSInteger _index;
}
@end

@implementation SJSnapshotRecorder
- (instancetype)init {
    return [self initWithNavigationController:nil index:0];
}
- (instancetype)initWithNavigationController:(__weak UINavigationController *__nullable)nav index:(NSInteger)index {
    self = [super init];
    if ( !self ) return nil;
    _rootView = [UIView new];
    _rootView.frame = [UIScreen mainScreen].bounds;
    
    _preViewContainerView = [UIView new];
    _preViewContainerView.frame = _rootView.bounds;
    [_rootView addSubview:_preViewContainerView];
    
    
    switch ( nav.childViewControllers[index].sj_displayMode ) {
        case SJPreViewDisplayMode_Origin: {
            // nav bar
            if ( nav ) {
                if ( !nav.navigationBarHidden ) {
                    _nav_bar_snapshotView = [nav.view.window resizableSnapshotViewFromRect:CGRectMake(0, 0, nav.navigationBar.frame.size.width, nav.navigationBar.frame.size.height - nav.navigationBar.subviews.firstObject.frame.origin.y + 1) afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
                    [_rootView addSubview:_nav_bar_snapshotView];
                }
            }
            
            // tab bar
            UITabBar *tabBar = nav.tabBarController.tabBar;
            if ( !tabBar.hidden ) {
                _tab_bar_snapshotView = [nav.view.window resizableSnapshotViewFromRect:CGRectMake(0, nav.view.bounds.size.height - tabBar.frame.size.height - 1, tabBar.bounds.size.width, tabBar.bounds.size.height + 1) afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
                _tab_bar_snapshotView.frame = CGRectMake(0, nav.view.bounds.size.height - tabBar.bounds.size.height - 1, tabBar.bounds.size.width, tabBar.bounds.size.height);
                [_rootView addSubview:_tab_bar_snapshotView];
            }
        }
            break;
        case SJPreViewDisplayMode_Snapshot: {
            _preSnapshotView = [nav.view.window snapshotViewAfterScreenUpdates:NO];
        }
            break;
    }
    
    _shadeView = [UIView new];
    _shadeView.frame = _rootView.bounds;
    _shadeView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    [_rootView addSubview:_shadeView];
    
    _nav = nav;
    _index = index;

    return self;
}

- (void)preparePopViewController {
    if ( !_nav ) return;
    
    UIViewController *vc = _nav.childViewControllers[_index];
    switch ( vc.sj_displayMode ) {
        case SJPreViewDisplayMode_Origin: {
            UIView *preView = _nav.childViewControllers[_index].view;
            [_preViewContainerView insertSubview:preView atIndex:0];
//            if ( @available(iOS 11, *) ) { /**/ break; }
//            else {
//                if ( !vc.automaticallyAdjustsScrollViewInsets || vc.edgesForExtendedLayout == UIRectEdgeNone ) break;
//
//                UIScrollView *scrollView = [self _searchScrollViewWithTarget:vc.view];
//                if ( !scrollView ) break;
//                if ( _nav_bar_snapshotView ) {
//                    // fix frame
//                    CGRect frame = preView.frame;
//                    frame.origin.y = _nav.navigationBar.frame.origin.y + _nav.navigationBar.frame.size.height;
//                    preView.frame = frame;
//                }
//            }
        }
            break;
        case SJPreViewDisplayMode_Snapshot: {
            [_preViewContainerView addSubview:_preSnapshotView];
        } break;
    }
}

- (void)endPopViewController {
    [_preViewContainerView.subviews.firstObject removeFromSuperview];
}

#pragma mark -
- (UIScrollView *)_searchScrollViewWithTarget:(UIView *)target {
    if ( [target isKindOfClass:[UIScrollView class]] ) return (UIScrollView *)target;
    __block UIView *scrollView = nil;
    [target.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( [obj isKindOfClass:[UIScrollView class]] ) {
            if ( CGRectEqualToRect(obj.frame, target.frame) ) {
                *stop = YES;
                scrollView = obj;
            }
        }
    }];
    return (UIScrollView *)scrollView;
}
@end

@interface SJSnapshotServer ()
@property (nonatomic, readonly) CGFloat shift;
@end

@implementation SJSnapshotServer

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
    if ( !self ) return nil;
    _shift = -[UIScreen mainScreen].bounds.size.width * 0.382;
    return self;
}

#pragma mark - action
- (void)nav:(UINavigationController *)nav pushViewController:(UIViewController *)viewController {
    if ( nav.childViewControllers.count == 0 ) return;
    NSInteger currentIndex = nav.childViewControllers.count - 1;
    UIViewController *currentVC = nav.childViewControllers[currentIndex];
    if ( [nav isKindOfClass:[UIImagePickerController class]] ) currentVC.sj_displayMode = SJPreViewDisplayMode_Snapshot;
    SJSnapshotRecorder *recorder = [[SJSnapshotRecorder alloc] initWithNavigationController:nav index:currentIndex];
    objc_setAssociatedObject(viewController, kSJSnapshot, recorder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -
- (void)nav:(UINavigationController *)nav preparePopViewController:(UIViewController *)viewController {
    SJSnapshotRecorder *recorder = objc_getAssociatedObject(viewController, kSJSnapshot);
    if ( !recorder ) return;
    [recorder preparePopViewController];
    
    // add recorder view
    [nav.view.superview insertSubview:recorder.rootView belowSubview:nav.view];
    
    recorder.rootView.transform = CGAffineTransformMakeTranslation( self.shift, 0);

    switch ( _transitionMode ) {
        case SJScreenshotTransitionModeShifting: {
            recorder.shadeView.alpha = 0.001;
        } break;
        case SJScreenshotTransitionModeShadeAndShifting: {
            recorder.shadeView.alpha = 1;
            CGFloat width = recorder.rootView.frame.size.width;
            recorder.shadeView.transform = CGAffineTransformMakeTranslation(- (self.shift + width), 0);
        } break;
    }
}

- (void)nav:(UINavigationController *)nav poppingViewController:(UIViewController *)viewController offset:(double)offset {
    SJSnapshotRecorder *recorder = objc_getAssociatedObject(viewController, kSJSnapshot);
    if ( !recorder ) return;
    CGFloat width = recorder.rootView.frame.size.width;
    CGFloat rate = offset / width;
    switch ( _transitionMode ) {
        case SJScreenshotTransitionModeShifting: {
            recorder.rootView.transform = CGAffineTransformMakeTranslation( self.shift * ( 1 - rate ), 0 );
        } break;
        case SJScreenshotTransitionModeShadeAndShifting: {
            recorder.rootView.transform = CGAffineTransformMakeTranslation( self.shift * ( 1 - rate ), 0 );
            recorder.shadeView.alpha = 1 - rate;
            recorder.shadeView.transform = CGAffineTransformMakeTranslation( - (self.shift + width) + (self.shift * rate) + offset, 0 );
        } break;
    }
}

- (void)nav:(UINavigationController *)nav willEndPopViewController:(UIViewController *)viewController pop:(BOOL)pop {
    SJSnapshotRecorder *recorder = objc_getAssociatedObject(viewController, kSJSnapshot);
    if ( !recorder ) return;
    if ( pop ) {
        recorder.rootView.transform = CGAffineTransformIdentity;
        recorder.shadeView.transform = CGAffineTransformIdentity;
        recorder.shadeView.alpha = 0.001;
    }
    else {
        switch ( _transitionMode ) {
            case SJScreenshotTransitionModeShifting: {} break;
            case SJScreenshotTransitionModeShadeAndShifting: {
                recorder.shadeView.alpha = 1;
                CGFloat width = recorder.rootView.frame.size.width;
                recorder.shadeView.transform = CGAffineTransformMakeTranslation(- (self.shift + width), 0);
            } break;
        }
    }
}

- (void)nav:(UINavigationController *)nav endPopViewController:(UIViewController *)viewController {
    SJSnapshotRecorder *recorder = objc_getAssociatedObject(viewController, kSJSnapshot);
    if ( !recorder ) return;
    [recorder endPopViewController];
    [recorder.rootView removeFromSuperview];
}
@end
NS_ASSUME_NONNULL_END
