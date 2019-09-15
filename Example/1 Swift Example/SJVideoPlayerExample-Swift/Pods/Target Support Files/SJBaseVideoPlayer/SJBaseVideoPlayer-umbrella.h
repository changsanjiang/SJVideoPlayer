#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SJBaseVideoPlayer+TestLog.h"
#import "SJBaseVideoPlayer.h"
#import "SJVideoPlayerURLAssetPrefetcher.h"
#import "UIScrollView+ListViewAutoplaySJAdd.h"
#import "UIViewController+SJRotationPrivate_FixSafeArea.h"
#import "SJBaseVideoPlayerConst.h"
#import "SJControlLayerAppearManagerDefines.h"
#import "SJDeviceVolumeAndBrightnessManagerDefines.h"
#import "SJEdgeFastForwardViewControllerDefines.h"
#import "SJFitOnScreenManagerDefines.h"
#import "SJFlipTransitionManagerDefines.h"
#import "SJFloatSmallViewControllerDefines.h"
#import "SJPlayerGestureControlDefines.h"
#import "SJPopPromptControllerProtocol.h"
#import "SJPromptDefines.h"
#import "SJReachabilityDefines.h"
#import "SJRotationManagerDefines.h"
#import "SJVideoPlayerControlLayerProtocol.h"
#import "SJVideoPlayerPlaybackControllerDefines.h"
#import "SJVideoPlayerPlayStatusDefines.h"
#import "SJVideoPlayerPresentViewDefines.h"
#import "SJPlayerAutoplayConfig.h"
#import "SJPlayModel.h"
#import "SJVideoPlayerURLAsset+SJAVMediaPlaybackAdd.h"
#import "SJVideoPlayerURLAsset.h"
#import "SJAVMediaPlaybackController.h"
#import "AVAsset+SJAVMediaExport.h"
#import "SJAVBasePlayer.h"
#import "SJAVMediaDefinitionLoader.h"
#import "SJAVMediaMainPresenter.h"
#import "SJAVMediaPlayer.h"
#import "SJAVMediaPlayerLoader.h"
#import "SJDeviceVolumeAndBrightnessManager.h"
#import "SJDeviceOutputPromptView.h"
#import "SJDeviceVolumeAndBrightnessManagerResourceLoader.h"
#import "NSTimer+SJAssetAdd.h"
#import "SJBaseVideoPlayerObservation.h"
#import "SJControlLayerAppearStateManager.h"
#import "SJEdgeFastForwardViewController.h"
#import "SJFitOnScreenManager.h"
#import "SJFlipTransitionManager.h"
#import "SJFloatSmallViewController.h"
#import "SJIsAppeared.h"
#import "SJPlayerView.h"
#import "SJPlayModelPropertiesObserver.h"
#import "SJPopPromptController.h"
#import "SJPrompt.h"
#import "SJReachability.h"
#import "SJRotationManager.h"
#import "SJTimerControl.h"
#import "SJVideoDefinitionSwitchingInfo+Private.h"
#import "SJVideoDefinitionSwitchingInfo.h"
#import "SJVideoPlayerPresentView.h"
#import "SJVideoPlayerRegistrar.h"
#import "UIView+SJVideoPlayerAdd.h"

FOUNDATION_EXPORT double SJBaseVideoPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char SJBaseVideoPlayerVersionString[];

