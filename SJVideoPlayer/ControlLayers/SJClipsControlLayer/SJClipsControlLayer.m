//
//  SJClipsControlLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/19.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJClipsControlLayer.h"
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

// control layers
#import "SJClipsGIFRecordsControlLayer.h"
#import "SJClipsVideoRecordsControlLayer.h"
#import "SJClipsResultsControlLayer.h"

#import "SJVideoPlayerClipsParameters.h"
#import "SJControlLayerSwitcher.h"
#import "SJVideoPlayerConfigurations.h"

NS_ASSUME_NONNULL_BEGIN
// right items
static SJEdgeControlButtonItemTag SJClipsControlLayerRightItem_Screenshot = 10000;
static SJEdgeControlButtonItemTag SJClipsControlLayerRightItem_ExportVideo = 10001;
static SJEdgeControlButtonItemTag SJClipsControlLayerRightItem_ExportGIF = 10002;

// control layer
static SJControlLayerIdentifier SJClipsGIFRecordsControlLayerIdentifier = 1;
static SJControlLayerIdentifier SJClipsVideoRecordsControlLayerIdentifier = 2;
static SJControlLayerIdentifier SJClipsResultsControlLayerIdentifier = 3;

@interface SJClipsControlLayer ()
@property (nonatomic, strong, nullable) SJControlLayerSwitcher *switcher;
@property (nonatomic, weak, nullable) __kindof SJBaseVideoPlayer *player;
@end

@implementation SJClipsControlLayer 
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
    }
    return self;
}

- (void)screenshotItemWasTapped {
    [self _start:SJVideoPlayerClipsOperation_Screenshot];
}

- (void)exportVideoItemWasTapped {
    [self _start:SJVideoPlayerClipsOperation_Export];
}

- (void)exportGIFItemWasTapped {
    [self _start:SJVideoPlayerClipsOperation_GIF];
}

- (void)_start:(SJVideoPlayerClipsOperation)operation {
    if ( _player.assetStatus != SJAssetStatusReadyToPlay ) {
        [self.player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(SJVideoPlayerConfigurations.shared.localizedStrings.operationFailedPrompt);
            make.textColor(UIColor.whiteColor);
        }]];
        return;
    }
    
    if ( ![self _shouldStart:operation] ) {
        return;
    }

    switch ( operation ) {
        case SJVideoPlayerClipsOperation_Unknown:
            break;
        case SJVideoPlayerClipsOperation_Screenshot:
            [self _showResultsWithParameters:[self _parametersWithOperation:SJVideoPlayerClipsOperation_Screenshot range:kCMTimeRangeZero]];
            break;
        case SJVideoPlayerClipsOperation_Export:
            [self.switcher switchControlLayerForIdentifier:SJClipsVideoRecordsControlLayerIdentifier];
            break;
        case SJVideoPlayerClipsOperation_GIF:
            [self.switcher switchControlLayerForIdentifier:SJClipsGIFRecordsControlLayerIdentifier];
            break;
    }
}

- (void)cancel {
//    [[self.switcher controlLayerForIdentifier:self.switcher.currentIdentifier] exitControlLayer];
    _switcher = nil;
    if ( self.cancelledOperationExeBlock ) {
        self.cancelledOperationExeBlock(self);
    }
}

- (SJVideoPlayerClipsParameters *)_parametersWithOperation:(SJVideoPlayerClipsOperation)operation range:(CMTimeRange)range {
    SJVideoPlayerClipsParameters *parameters = [[SJVideoPlayerClipsParameters alloc] initWithOperation:operation range:range];
    parameters.resultUploader = self.config.resultUploader;
    parameters.resultNeedUpload = self.config.resultNeedUpload;
    parameters.saveResultToAlbum = self.config.saveResultToAlbum;
    return parameters;
}

- (void)_showResultsWithParameters:(id<SJVideoPlayerClipsParameters>)parameters {
    [_player pause];
    
    [self.switcher switchControlLayerForIdentifier:SJClipsResultsControlLayerIdentifier];
    SJClipsResultsControlLayer *control = (id)[self.switcher controlLayerForIdentifier:SJClipsResultsControlLayerIdentifier];
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
    SJEdgeControlButtonItem *screenshotItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJClipsControlLayerRightItem_Screenshot];
    [screenshotItem addTarget:self action:@selector(screenshotItemWasTapped)];
    [self.rightAdapter addItem:screenshotItem];
    
    SJEdgeControlButtonItem *exportVideoItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJClipsControlLayerRightItem_ExportVideo];
    [exportVideoItem addTarget:self action:@selector(exportVideoItemWasTapped)];
    [self.rightAdapter addItem:exportVideoItem];
    
    SJEdgeControlButtonItem *exportGIFItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJClipsControlLayerRightItem_ExportGIF];
    [exportGIFItem addTarget:self action:@selector(exportGIFItemWasTapped)];
    [self.rightAdapter addItem:exportGIFItem];
}

- (void)_updateRightItemSettings {
    id<SJVideoPlayerControlLayerResources> sources = SJVideoPlayerConfigurations.shared.resources;
    SJEdgeControlButtonItem *screenshotItem = [self.rightAdapter itemForTag:SJClipsControlLayerRightItem_Screenshot];
    screenshotItem.image = sources.screenshotImage;
    screenshotItem.hidden = _config.disableScreenshot;
    
    SJEdgeControlButtonItem *exportVideoItem = [self.rightAdapter itemForTag:SJClipsControlLayerRightItem_ExportVideo];
    exportVideoItem.image = sources.videoClipImage;
    exportVideoItem.hidden = _config.disableRecord;
    
    SJEdgeControlButtonItem *exportGIFItem = [self.rightAdapter itemForTag:SJClipsControlLayerRightItem_ExportGIF];
    exportGIFItem.image = sources.GIFClipImage;
    exportGIFItem.hidden = _config.disableGIF;
    
    [self.rightAdapter reload];
}

- (void)_initializeSwitcher:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _switcher = [[SJControlLayerSwitcher alloc] initWithPlayer:videoPlayer];
    __weak typeof(self) _self = self;
    _switcher.resolveControlLayer = ^id<SJControlLayer> _Nullable(SJControlLayerIdentifier identifier) {
        __strong typeof(_self) self = _self;
        if ( !self ) return nil;
        if ( identifier == SJClipsGIFRecordsControlLayerIdentifier ) {
            SJClipsGIFRecordsControlLayer *controlLayer = [SJClipsGIFRecordsControlLayer new];
            controlLayer.statusDidChangeExeBlock = ^(SJClipsGIFRecordsControlLayer * _Nonnull control) {
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                switch ( control.status ) {
                    case SJClipsStatus_Unknown:
                    case SJClipsStatus_Recording:
                    case SJClipsStatus_Paused:
                        break;
                    case SJClipsStatus_Cancelled: {
                        [self cancel];
                    }
                        break;
                    case SJClipsStatus_Finished: {
                        [self _showResultsWithParameters:[self _parametersWithOperation:SJVideoPlayerClipsOperation_GIF range:control.range]];
                    }
                        break;
                }
            };
            return controlLayer;
        }
        else if ( identifier == SJClipsVideoRecordsControlLayerIdentifier ) {
            SJClipsVideoRecordsControlLayer *controlLayer = [SJClipsVideoRecordsControlLayer new];
            controlLayer.statusDidChangeExeBlock = ^(SJClipsVideoRecordsControlLayer * _Nonnull control) {
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                switch ( control.status ) {
                    case SJClipsStatus_Unknown:
                    case SJClipsStatus_Recording:
                    case SJClipsStatus_Paused:
                        break;
                    case SJClipsStatus_Cancelled: {
                        [self cancel];
                    }
                        break;
                    case SJClipsStatus_Finished: {
                        [self _showResultsWithParameters:[self _parametersWithOperation:SJVideoPlayerClipsOperation_Export range:control.range]];
                    }
                        break;
                }
            };
            return controlLayer;
        }
        else if ( identifier == SJClipsResultsControlLayerIdentifier ) {
            SJClipsResultsControlLayer *controlLayer = [SJClipsResultsControlLayer new];
            controlLayer.cancelledOperationExeBlock = ^(SJClipsResultsControlLayer * _Nonnull control) {
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                [self cancel];
            };
            return controlLayer;
        }

        return nil;
    };
}

- (void)setConfig:(nullable SJVideoPlayerClipsConfig *)config {
    _config = config;
    [self _updateRightItemSettings];
}

#pragma mark -

- (BOOL)_shouldStart:(SJVideoPlayerClipsOperation)operation {
    if ( _config.shouldStart != nil ) {
        return _config.shouldStart(self.player, operation);
    }
    return YES;
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
