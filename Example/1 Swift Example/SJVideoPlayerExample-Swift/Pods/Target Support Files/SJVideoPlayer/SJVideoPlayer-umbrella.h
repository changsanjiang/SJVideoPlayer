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
#import "SJEdgeControlButtonItem.h"
#import "SJEdgeControlButtonItemCell.h"
#import "SJEdgeControlLayerItemAdapter.h"
#import "SJEdgeControlLayerAdapters.h"
#import "SJVideoPlayerAnimationHeader.h"
#import "SJVideoPlayerControlMaskView.h"
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import "UIView+SJAnimationAdded.h"
#import "UIView+SJControlAdd.h"
#import "SJEdgeControlLayer.h"
#import "SJEdgeControlLayerLoadingViewDefines.h"
#import "SJEdgeControlLayerLoader.h"
#import "SJEdgeControlLayerSettings.h"
#import "UIView+SJVideoPlayerSetting.h"
#import "SJLoadingView.h"
#import "SJNetworkLoadingView.h"
#import "SJVideoPlayerDraggingProgressView.h"
#import "SJFilmEditingControlLayer.h"
#import "SJFilmEditingGenerateResultControlLayer.h"
#import "SJFilmEditingInGIFRecordingsControlLayer.h"
#import "SJFilmEditingInVideoRecordingsControlLayer.h"
#import "SJFilmEditingStatus.h"
#import "SJVideoPlayerFilmEditingCommonHeader.h"
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
#import "SJFilmEditingLoader.h"
#import "SJFilmEditingSettings.h"
#import "SJFloatSmallViewControlLayer.h"
#import "SJFloatSmallViewControlLayerResourceLoader.h"
#import "SJLoadFailedControlLayer.h"
#import "SJMoreSettingControlLayer.h"
#import "SJNotReachableControlLayer.h"
#import "SJButtonProgressSlider.h"
#import "SJCommonProgressSlider.h"
#import "SJProgressSlider.h"
#import "SJSwitchVideoDefinitionControlLayer.h"
#import "SJVideoPlayerURLAsset+SJExtendedDefinition.h"
#import "SJVideoPlayerSettings.h"
#import "SJControlLayerDefines.h"
#import "SJControlLayerSwitcher.h"

FOUNDATION_EXPORT double SJVideoPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char SJVideoPlayerVersionString[];

