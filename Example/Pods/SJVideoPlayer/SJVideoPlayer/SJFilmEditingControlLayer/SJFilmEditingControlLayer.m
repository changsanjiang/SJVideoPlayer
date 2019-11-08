//
//  SJFilmEditingControlLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/19.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJFilmEditingControlLayer.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#else
#import "SJBaseVideoPlayer.h"  
#endif
#if __has_include(<SJUIKit/SJAttributesFactory.h>)
#import <SJUIKit/SJAttributesFactory.h>
#else
#import "SJAttributesFactory.h"
#endif

#import "UIView+SJAnimationAdded.h"
#import "SJVideoPlayerAnimationHeader.h"
#import "SJFilmEditingSettings.h"

// control layers
#import "SJFilmEditingInGIFRecordingsControlLayer.h"
#import "SJFilmEditingInVideoRecordingsControlLayer.h"
#import "SJFilmEditingGenerateResultControlLayer.h"

#import "SJControlLayerSwitcher.h"
#import "SJVideoPlayerFilmEditingParameters.h"

NS_ASSUME_NONNULL_BEGIN
// right items
static SJEdgeControlButtonItemTag SJFilmEditingControlLayerRightItem_Screenshot = 10000;
static SJEdgeControlButtonItemTag SJFilmEditingControlLayerRightItem_ExportVideo = 10001;
static SJEdgeControlButtonItemTag SJFilmEditingControlLayerRightItem_ExportGIF = 10002;

// control layer
static SJControlLayerIdentifier SJFilmEditingInGIFRecordingsControlLayerIdentifier = 1;
static SJControlLayerIdentifier SJFilmEditingInVideoRecordingsControlLayerIdentifier = 2;
static SJControlLayerIdentifier SJFilmEditingGenerateResultControlLayerIdentifier = 3;

@interface SJFilmEditingControlLayer ()
@property (nonatomic, strong, readonly) SJFilmEditingSettingsUpdatedObserver *settingsUpdatedObserver;
@property (nonatomic, strong, nullable) SJControlLayerSwitcher *switcher;
@property (nonatomic, weak, nullable) __kindof SJBaseVideoPlayer *player;
@end

@implementation SJFilmEditingControlLayer 
@synthesize restarted = _restarted;

- (void)restartControlLayer {
    _restarted = YES;
    
    sj_view_makeAppear(self.controlView, YES);
    sj_view_makeAppear(self.rightContainerView, YES);
}

- (void)exitControlLayer {
    _restarted = NO;
    
    sj_view_makeDisappear(self.controlView, YES);
    sj_view_makeDisappear(self.rightContainerView, YES, ^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupViews];
        [self _initializeObserver];
    }
    return self;
}

- (void)clickedScreenshotItem {
    if ( _player.assetStatus != SJAssetStatusReadyToPlay ) {
        [self.player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(@"开启失败");
            make.textColor(UIColor.whiteColor);
        }]];
        return;
    }
    
    if ( _config.shouldStartWhenUserSelectedAnOperation ) {
        if ( !_config.shouldStartWhenUserSelectedAnOperation(self.player, SJVideoPlayerFilmEditingOperation_Screenshot) ) {
            return;
        }
    }
    
//    [self exitControlLayer];
    
    [self _generateResultWithParameters:[self _createParametersWithOperation:SJVideoPlayerFilmEditingOperation_Screenshot range:kCMTimeRangeZero]];
}

- (void)clickedExportVideoItem {
    if ( _config.shouldStartWhenUserSelectedAnOperation ) {
        if ( !_config.shouldStartWhenUserSelectedAnOperation(self.player, SJVideoPlayerFilmEditingOperation_Screenshot) ) {
            return;
        }
    }
    
//    [self exitControlLayer];

    [self.switcher switchControlLayerForIdentitfier:SJFilmEditingInVideoRecordingsControlLayerIdentifier];
}

- (void)clickedExportGIFItem {
    if ( _config.shouldStartWhenUserSelectedAnOperation ) {
        if ( !_config.shouldStartWhenUserSelectedAnOperation(self.player, SJVideoPlayerFilmEditingOperation_Screenshot) ) {
            return;
        }
    }
    
//    [self exitControlLayer];
    
    [self.switcher switchControlLayerForIdentitfier:SJFilmEditingInGIFRecordingsControlLayerIdentifier];
}

- (void)cancel {
//    [[self.switcher controlLayerForIdentifier:self.switcher.currentIdentifier] exitControlLayer];
    _switcher = nil;
    if ( self.cancelledOperationExeBlock ) {
        self.cancelledOperationExeBlock(self);
    }
}

- (SJVideoPlayerFilmEditingParameters *)_createParametersWithOperation:(SJVideoPlayerFilmEditingOperation)operation range:(CMTimeRange)range {
    SJVideoPlayerFilmEditingParameters *parameters = [[SJVideoPlayerFilmEditingParameters alloc] initWithOperation:operation range:range];
    parameters.resultUploader = self.config.resultUploader;
    parameters.resultNeedUpload = self.config.resultNeedUpload;
    parameters.saveResultToAlbumWhenExportSuccess = self.config.saveResultToAlbumWhenExportSuccess;
    return parameters;
}

- (void)_generateResultWithParameters:(id<SJVideoPlayerFilmEditingParameters>)parameters {
    [_player pause];
    
    [self.switcher switchControlLayerForIdentitfier:SJFilmEditingGenerateResultControlLayerIdentifier];
    SJFilmEditingGenerateResultControlLayer *control = (id)[self.switcher controlLayerForIdentifier:SJFilmEditingGenerateResultControlLayerIdentifier];
    control.parameters = parameters;
    control.shareItems = self.config.resultShareItems;
    control.clickedResultShareItemExeBlock = self.config.clickedResultShareItemExeBlock;
}
#pragma mark -

- (void)_setupViews {
    self.rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
    sj_view_initializes(@[self.rightContainerView]);
    
    [self _addItemToRightAdapter];
    [self _updateRightItemSettings];
}

- (void)_addItemToRightAdapter {
    SJEdgeControlButtonItem *screenshotItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJFilmEditingControlLayerRightItem_Screenshot];
    [screenshotItem addTarget:self action:@selector(clickedScreenshotItem)];
    [self.rightAdapter addItem:screenshotItem];
    
    SJEdgeControlButtonItem *exportVideoItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJFilmEditingControlLayerRightItem_ExportVideo];
    [exportVideoItem addTarget:self action:@selector(clickedExportVideoItem)];
    [self.rightAdapter addItem:exportVideoItem];
    
    SJEdgeControlButtonItem *exportGIFItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJFilmEditingControlLayerRightItem_ExportGIF];
    [exportGIFItem addTarget:self action:@selector(clickedExportGIFItem)];
    [self.rightAdapter addItem:exportGIFItem];
}

- (void)_updateRightItemSettings {
    SJFilmEditingSettings * _Nonnull setting = [SJFilmEditingSettings commonSettings];
    SJEdgeControlButtonItem *screenshotItem = [self.rightAdapter itemForTag:SJFilmEditingControlLayerRightItem_Screenshot];
    screenshotItem.image = setting.screenshotBtnImage;
    screenshotItem.hidden = _config.disableScreenshot;
    
    SJEdgeControlButtonItem *exportVideoItem = [self.rightAdapter itemForTag:SJFilmEditingControlLayerRightItem_ExportVideo];
    exportVideoItem.image = setting.exportBtnImage;
    exportVideoItem.hidden = _config.disableRecord;
    
    SJEdgeControlButtonItem *exportGIFItem = [self.rightAdapter itemForTag:SJFilmEditingControlLayerRightItem_ExportGIF];
    exportGIFItem.image = setting.gifBtnImage;
    exportGIFItem.hidden = _config.disableGIF;
    
    [self.rightAdapter reload];
}

- (void)_initializeObserver {
    _settingsUpdatedObserver = [[SJFilmEditingSettingsUpdatedObserver alloc] init];
    __weak typeof(self) _self = self;
    _settingsUpdatedObserver.updatedExeBlock = ^(SJFilmEditingSettings *settings) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _updateRightItemSettings];
    };
}

- (void)_initializeSwitcher:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _switcher = [[SJControlLayerSwitcher alloc] initWithPlayer:videoPlayer];
    __weak typeof(self) _self = self;
    _switcher.resolveControlLayer = ^id<SJControlLayer> _Nullable(SJControlLayerIdentifier identifier) {
        __strong typeof(_self) self = _self;
        if ( !self ) return nil;
        if ( identifier == SJFilmEditingInGIFRecordingsControlLayerIdentifier ) {
            SJFilmEditingInGIFRecordingsControlLayer *controlLayer = [SJFilmEditingInGIFRecordingsControlLayer new];
            controlLayer.statusDidChangeExeBlock = ^(SJFilmEditingInGIFRecordingsControlLayer * _Nonnull control) {
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                switch ( control.status ) {
                    case SJFilmEditingStatus_Unknown:
                    case SJFilmEditingStatus_Recording:
                    case SJFilmEditingStatus_Paused:
                        break;
                    case SJFilmEditingStatus_Cancelled: {
                        [self cancel];
                    }
                        break;
                    case SJFilmEditingStatus_Finished: {
                        [self _generateResultWithParameters:[self _createParametersWithOperation:SJVideoPlayerFilmEditingOperation_GIF range:control.range]];
                    }
                        break;
                }
            };
            return controlLayer;
        }
        else if ( identifier == SJFilmEditingInVideoRecordingsControlLayerIdentifier ) {
            SJFilmEditingInVideoRecordingsControlLayer *controlLayer = [SJFilmEditingInVideoRecordingsControlLayer new];
            controlLayer.statusDidChangeExeBlock = ^(SJFilmEditingInVideoRecordingsControlLayer * _Nonnull control) {
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                switch ( control.status ) {
                    case SJFilmEditingStatus_Unknown:
                    case SJFilmEditingStatus_Recording:
                    case SJFilmEditingStatus_Paused:
                        break;
                    case SJFilmEditingStatus_Cancelled: {
                        [self cancel];
                    }
                        break;
                    case SJFilmEditingStatus_Finished: {
                        [self _generateResultWithParameters:[self _createParametersWithOperation:SJVideoPlayerFilmEditingOperation_Export range:control.range]];
                    }
                        break;
                }
            };
            return controlLayer;
        }
        else if ( identifier == SJFilmEditingGenerateResultControlLayerIdentifier ) {
            SJFilmEditingGenerateResultControlLayer *controlLayer = [SJFilmEditingGenerateResultControlLayer new];
            controlLayer.cancelledOperationExeBlock = ^(SJFilmEditingGenerateResultControlLayer * _Nonnull control) {
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                [self cancel];
            };
            return controlLayer;
        }

        return nil;
    };
}

- (void)setConfig:(nullable SJVideoPlayerFilmEditingConfig *)config {
    _config = config;
    [self _updateRightItemSettings];
}

#pragma mark -

- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _player = videoPlayer;
    [videoPlayer needHiddenStatusBar];
    [self _initializeSwitcher:videoPlayer];
    sj_view_makeDisappear(self.rightContainerView, NO);
}

- (BOOL)canTriggerRotationOfVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    return NO;
}

- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    if ( type == SJPlayerGestureType_SingleTap ) {
        if ( ![self.rightAdapter itemContainsPoint:location] ) {
            if ( _cancelledOperationExeBlock )
                _cancelledOperationExeBlock(self);
        }
    }
    return NO;
}
- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer { }
- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer { }
@end
NS_ASSUME_NONNULL_END
