//
//  SJViewControllerManager.h
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2019/11/23.
//

#import "SJViewControllerManagerDefines.h"
#import "SJFitOnScreenManagerDefines.h"
#import "SJRotationManagerDefines.h"
#import "SJControlLayerAppearManagerDefines.h"
#import "SJVideoPlayerPresentViewDefines.h"
#import "SJRotationManager.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJViewControllerManager : NSObject<SJViewControllerManager, SJRotationManagerDelegate>
@property (nonatomic, weak, nullable) id<SJFitOnScreenManager> fitOnScreenManager;
@property (nonatomic, weak, nullable) id<SJRotationManager> rotationManager;
@property (nonatomic, weak, nullable) id<SJControlLayerAppearManager> controlLayerAppearManager;
@property (nonatomic, weak, nullable) UIView<SJVideoPlayerPresentView> *presentView;
@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;
@end
NS_ASSUME_NONNULL_END
