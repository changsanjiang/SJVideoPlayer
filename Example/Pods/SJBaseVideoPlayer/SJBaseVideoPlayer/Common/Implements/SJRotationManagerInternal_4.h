//
//  SJRotationManagerInternal_4.h
//  SJVideoPlayer
//
//  Created by 蓝舞者 on 2022/7/7.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJRotationManager_4.h"
@protocol SJRotationManager_4Delegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJRotationManager_4 (Internal)
@property (nonatomic, weak, nullable) id<SJRotationManager_4Delegate> delegate;

- (void)setNeedsStatusBarAppearanceUpdate;
@end

@protocol SJRotationManager_4Delegate <NSObject>
- (BOOL)prefersStatusBarHidden;
- (UIStatusBarStyle)preferredStatusBarStyle;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end


@interface SJRotationManager_4 (Subclass)
- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(id<SJRotationManager> mgr))completionHandler;

- (void)onDeviceOrientationChanged;
@end
NS_ASSUME_NONNULL_END

