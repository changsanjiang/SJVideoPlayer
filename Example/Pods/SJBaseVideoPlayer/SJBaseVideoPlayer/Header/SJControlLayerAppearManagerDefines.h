//
//  SJControlLayerAppearManagerDefines.h
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2018/12/31.
//

#ifndef SJControlLayerAppearManagerProtocol_h
#define SJControlLayerAppearManagerProtocol_h
#import <UIKit/UIKit.h>
@protocol SJControlLayerAppearManagerObserver;

NS_ASSUME_NONNULL_BEGIN
@protocol SJControlLayerAppearManager
- (id<SJControlLayerAppearManagerObserver>)getObserver;
@property (nonatomic, getter=isDisabled) BOOL disabled;
@property (nonatomic) NSTimeInterval interval;

/// Appear state
@property (nonatomic, readonly) BOOL isAppeared;
- (void)switchAppearState;
- (void)needAppear;
- (void)needDisappear;

- (void)resume;
- (void)keepAppearState;
- (void)keepDisappearState;

@property (nonatomic, copy, nullable) BOOL(^canAutomaticallyDisappear)(id<SJControlLayerAppearManager> mgr);
@end

@protocol SJControlLayerAppearManagerObserver
@property (nonatomic, copy, nullable) void(^appearStateDidChangeExeBlock)(id<SJControlLayerAppearManager> mgr);
@end
NS_ASSUME_NONNULL_END
#endif /* SJControlLayerAppearManagerProtocol_h */
