//
//  SJFullscreenPopGesture.h
//  SJBackGRProject
//
//  Created by 畅三江 on 2019/7/17.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WKWebView;

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    SJFullscreenPopGestureTypeEdgeLeft,
    SJFullscreenPopGestureTypeFull,
} SJFullscreenPopGestureType;

typedef enum : NSUInteger {
    SJFullscreenPopGestureTransitionModeShifting,
    SJFullscreenPopGestureTransitionModeMaskAndShifting,
} SJFullscreenPopGestureTransitionMode;

typedef enum : NSUInteger {
    SJPreViewDisplayModeSnapshot,
    SJPreViewDisplayModeOrigin,
} SJPreViewDisplayMode;

@interface SJFullscreenPopGesture : NSObject
@property (class, nonatomic) SJFullscreenPopGestureType gestureType;
@property (class, nonatomic) SJFullscreenPopGestureTransitionMode transitionMode;
@property (class, nonatomic) CGFloat maxOffsetToTriggerPop;
@end

@interface UIViewController (SJExtendedFullscreenPopGesture)
@property (nonatomic) SJPreViewDisplayMode sj_displayMode;
@property (nonatomic) BOOL sj_disableFullscreenGesture;
@property (nonatomic, copy, nullable) NSArray<NSValue *> *sj_blindArea;
@property (nonatomic, copy, nullable) NSArray<UIView *> *sj_blindAreaViews;

@property (nonatomic, copy, nullable) void(^sj_viewWillBeginDragging)(__kindof UIViewController *vc);
@property (nonatomic, copy, nullable) void(^sj_viewDidDrag)(__kindof UIViewController *vc);
@property (nonatomic, copy, nullable) void(^sj_viewDidEndDragging)(__kindof UIViewController *vc);

@property (nonatomic, strong, nullable) WKWebView *sj_considerWebView;
@end

@interface UINavigationController (SJExtendedFullscreenPopGesture)
@property (nonatomic, readonly) UIGestureRecognizerState sj_fullscreenGestureState;
@end
NS_ASSUME_NONNULL_END
