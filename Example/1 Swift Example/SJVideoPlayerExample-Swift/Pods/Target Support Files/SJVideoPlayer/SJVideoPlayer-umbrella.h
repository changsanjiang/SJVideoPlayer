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

#import "SJVideoPlayer.h"
#import "SJFilmEditingStatus.h"
#import "SJVideoPlayerConst.h"
#import "SJDraggingObservation.h"
#import "SJDraggingProgressPopView.h"
#import "SJFastForwardView.h"
#import "SJFullscreenCustomStatusBar.h"
#import "SJLoadingView.h"
#import "SJScrollingTextMarqueeView.h"
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import "SJControlLayerDefines.h"
#import "SJDraggingObservationDefines.h"
#import "SJDraggingProgressPopViewDefines.h"
#import "SJFastForwardViewDefines.h"
#import "SJFullscreenCustomStatusBarDefines.h"
#import "SJLoadingViewDefinies.h"
#import "SJScrollingTextMarqueeViewDefines.h"
#import "SJVideoPlayerFilmEditingDefines.h"
#import "SJVideoPlayerSettings.h"
#import "UIView+SJAnimationAdded.h"
#import "SJEdgeControlButtonItem.h"
#import "SJEdgeControlButtonItemAdapter.h"
#import "SJEdgeControlButtonItemAdapterLayout.h"
#import "SJEdgeControlButtonItemView.h"
#import "SJEdgeControlLayerAdapters.h"
#import "SJButtonProgressSlider.h"
#import "SJCommonProgressSlider.h"
#import "SJProgressSlider.h"
#import "SJVideoPlayerControlMaskView.h"
#import "SJControlLayerSwitcher.h"
#import "SJEdgeControlLayer.h"
#import "SJFilmEditingGenerateResultControlLayer.h"
#import "SJFilmEditingInGIFRecordingsControlLayer.h"
#import "SJFilmEditingInVideoRecordingsControlLayer.h"
#import "SJFilmEditingResultShareItem.h"
#import "SJFilmEditingSaveResultToAlbumHandler.h"
#import "SJVideoPlayerFilmEditingConfig.h"
#import "SJVideoPlayerFilmEditingGeneratedResult.h"
#import "SJVideoPlayerFilmEditingParameters.h"
#import "SJFilmEditingBackButton.h"
#import "SJFilmEditingButtonContainerView.h"
#import "SJFilmEditingCommonViewLayer.h"
#import "SJFilmEditingGIFCountDownView.h"
#import "SJFilmEditingResultShareItemsContainerView.h"
#import "SJFilmEditingVideoCountDownView.h"
#import "SJFilmEditingControlLayer.h"
#import "SJFloatSmallViewControlLayer.h"
#import "SJLoadFailedControlLayer.h"
#import "SJMoreSettingControlLayer.h"
#import "SJNotReachableControlLayer.h"
#import "SJSwitchVideoDefinitionControlLayer.h"
#import "SJVideoPlayerURLAsset+SJExtendedDefinition.h"
#import "SJVideoPlayerResourceLoader.h"

FOUNDATION_EXPORT double SJVideoPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char SJVideoPlayerVersionString[];

