//
//  SJViewControllerManager.h
//  SJBaseVideoPlayer
//
//  Created by BlueDancer on 2019/11/23.
//

#import "SJViewControllerManagerDefines.h"
#import "SJFitOnScreenManagerDefines.h"
#import "SJRotationManagerDefines.h"
#import "SJControlLayerAppearManagerDefines.h"
#import "SJVideoPlayerPresentViewDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJViewControllerManager : NSObject<SJViewControllerManager>
@property (nonatomic, weak, nullable) id<SJFitOnScreenManager> fitOnScreenManager;
@property (nonatomic, weak, nullable) id<SJRotationManager> rotationManager;
@property (nonatomic, weak, nullable) id<SJControlLayerAppearManager> controlLayerAppearManager;
@property (nonatomic, weak, nullable) UIView<SJVideoPlayerPresentView> *presentView;
@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;
@end
NS_ASSUME_NONNULL_END
