//
//  SJRotationObserver.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJRotationManager.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJRotationObserver : NSObject<SJRotationManagerObserver>
- (instancetype)initWithManager:(SJRotationManager *)manager;

@property (nonatomic, copy, nullable) void(^onRotatingChanged)(id<SJRotationManager> mgr, BOOL isRotating);
@property (nonatomic, copy, nullable) void(^onTransitioningChanged)(id<SJRotationManager> mgr, BOOL isTransitioning);
@end
NS_ASSUME_NONNULL_END
