//
//  SJFlipTransitionManagerDefines.h
//  Pods
//
//  Created by 畅三江 on 2018/12/31.
//

#ifndef SJFlipTransitionManagerProtocol_h
#define SJFlipTransitionManagerProtocol_h
#import <UIKit/UIKit.h>
@protocol SJFlipTransitionManagerObserver;

typedef enum : NSUInteger {
    SJViewFlipTransition_Identity,
    SJViewFlipTransition_Horizontally, // 水平翻转
} SJViewFlipTransition;

NS_ASSUME_NONNULL_BEGIN
@protocol SJFlipTransitionManager <NSObject>
- (instancetype)initWithTarget:(__strong UIView *)target;
- (id<SJFlipTransitionManagerObserver>)getObserver;

@property (nonatomic, readonly, getter=isTransitioning) BOOL transitioning;
@property (nonatomic) NSTimeInterval duration;

@property (nonatomic) SJViewFlipTransition flipTransition;
- (void)setFlipTransition:(SJViewFlipTransition)t animated:(BOOL)animated;
- (void)setFlipTransition:(SJViewFlipTransition)t animated:(BOOL)animated completionHandler:(void(^_Nullable)(id<SJFlipTransitionManager> mgr))completionHandler;

@property (nonatomic, strong, nullable) UIView *target;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@end


@protocol SJFlipTransitionManagerObserver <NSObject>
@property (nonatomic, copy, nullable) void(^flipTransitionDidStartExeBlock)(id<SJFlipTransitionManager> mgr);
@property (nonatomic, copy, nullable) void(^flipTransitionDidStopExeBlock)(id<SJFlipTransitionManager> mgr);
@end
NS_ASSUME_NONNULL_END
#endif /* SJFlipTransitionManagerProtocol_h */
