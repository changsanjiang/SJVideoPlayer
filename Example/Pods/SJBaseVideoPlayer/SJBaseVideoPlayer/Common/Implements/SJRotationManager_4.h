//
//  SJRotationManager_4.h
//  version_4
//
//  Created by 畅三江 on 2022/7/6.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJRotationManagerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJRotationManager_4 : NSObject<SJRotationManager>
+ (instancetype)rotationManager;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

@interface UIWindow (SJRotationControls)
@property (nonatomic, readonly) UIInterfaceOrientationMask sj_4_supportedInterfaceOrientations;
@end
NS_ASSUME_NONNULL_END
 


#pragma mark - fix safe area

NS_ASSUME_NONNULL_BEGIN
typedef NS_OPTIONS(NSUInteger, SJSafeAreaInsetsMask) {
    SJSafeAreaInsetsMaskNone = 0,
    SJSafeAreaInsetsMaskTop = 1 << 0,
    SJSafeAreaInsetsMaskLeft = 1 << 1,
    SJSafeAreaInsetsMaskBottom = 1 << 2,
    SJSafeAreaInsetsMaskRight = 1 << 3,
    
    SJSafeAreaInsetsMaskHorizontal = SJSafeAreaInsetsMaskLeft | SJSafeAreaInsetsMaskRight,
    SJSafeAreaInsetsMaskVertical = SJSafeAreaInsetsMaskTop | SJSafeAreaInsetsMaskRight,
    SJSafeAreaInsetsMaskAll = SJSafeAreaInsetsMaskHorizontal | SJSafeAreaInsetsMaskVertical
} NS_AVAILABLE_IOS(13.0);


API_AVAILABLE(ios(13.0)) @interface UIViewController (SJRotationSafeAreaFixing)

/// 禁止调整哪些方向的安全区
@property (nonatomic) SJSafeAreaInsetsMask disabledAdjustSafeAreaInsetsMask;

@end
NS_ASSUME_NONNULL_END
