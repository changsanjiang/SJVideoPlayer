//
//  SJFitOnScreenManagerDefines.h
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2018/12/31.
//

#ifndef SJFitOnScreenManagerProtocol_h
#define SJFitOnScreenManagerProtocol_h
#import <UIKit/UIKit.h>
@protocol SJFitOnScreenManagerObserver;

NS_ASSUME_NONNULL_BEGIN
@protocol SJFitOnScreenManager <NSObject>
- (instancetype)initWithTarget:(__strong UIView *)target targetSuperview:(__strong UIView *)superview;
- (id<SJFitOnScreenManagerObserver>)getObserver;

@property (nonatomic, readonly, getter=isTransitioning) BOOL transitioning;
@property (nonatomic) NSTimeInterval duration;

///
/// 是否已充满屏幕
///
@property (nonatomic, getter=isFitOnScreen) BOOL fitOnScreen;
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated;
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated completionHandler:(nullable void(^)(id<SJFitOnScreenManager> mgr))completionHandler;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@end


@protocol SJFitOnScreenManagerObserver <NSObject>
@property (nonatomic, copy, nullable) void(^fitOnScreenWillBeginExeBlock)(id<SJFitOnScreenManager> mgr);
@property (nonatomic, copy, nullable) void(^fitOnScreenDidEndExeBlock)(id<SJFitOnScreenManager> mgr);
@end
NS_ASSUME_NONNULL_END
#endif /* SJFitOnScreenManagerProtocol_h */
