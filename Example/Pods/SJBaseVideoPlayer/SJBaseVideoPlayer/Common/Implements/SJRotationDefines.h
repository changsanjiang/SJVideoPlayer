//
//  SJRotationDefines.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJRotationManagerDefines.h"

NS_ASSUME_NONNULL_BEGIN
 
FOUNDATION_EXPORT NSNotificationName const SJRotationManagerRotationNotification;
FOUNDATION_EXPORT NSNotificationName const SJRotationManagerTransitionNotification;

FOUNDATION_EXPORT BOOL SJRotationIsFullscreenOrientation(SJOrientation orientation);
FOUNDATION_EXPORT BOOL SJRotationIsSupportedOrientation(SJOrientation orientation, SJOrientationMask supportedOrientations);

NS_ASSUME_NONNULL_END
