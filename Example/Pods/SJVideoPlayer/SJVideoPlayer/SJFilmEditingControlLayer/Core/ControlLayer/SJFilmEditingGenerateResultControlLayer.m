//
//  SJFilmEditingGenerateResultControlLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJFilmEditingGenerateResultControlLayer.h"
#import "UIView+SJAnimationAdded.h"
#import "SJVideoPlayerAnimationHeader.h"
#import "SJFilmEditingSettings.h"
#import "SJFilmEditingBackButton.h"
#import "SJFilmEditingButtonContainerView.h"
#import "SJFilmEditingResultShareItem.h"
#import "SJFilmEditingResultShareItemsContainerView.h"
#import "SJVideoPlayerFilmEditingGeneratedResult.h"
#import "SJFilmEditingSaveResultToAlbumHandler.h"

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

NS_ASSUME_NONNULL_BEGIN
static SJEdgeControlButtonItemTag SJTopItem_Back = 1;

@interface SJFilmEditingGenerateResultControlLayer ()
@property (nonatomic, weak, nullable) __kindof SJBaseVideoPlayer *player;
@property (nonatomic, strong, readonly) SJFilmEditingSaveResultToAlbumHandler *saveHandler;
@property (nonatomic, strong, readonly) SJFilmEditingSettingsUpdatedObserver *settingsUpdatedObserver;
@property (nonatomic, strong, readonly) SJFilmEditingButtonContainerView *backButtonContainerView;
@property (nonatomic, strong, readonly) SJFilmEditingResultShareItemsContainerView *itemsContainerView;

@property (nonatomic, strong, readonly) UILabel *promptLabel;
@property (nonatomic, strong, readonly) UIImageView *coverImageView;

@property (nonatomic, strong, nullable) SJVideoPlayerFilmEditingGeneratedResult *result;
@property (nonatomic, strong, readonly) SJBaseVideoPlayer *exportedVideoPlayer;
@property (nonatomic, strong, readonly) UIView *flashingView;
@end

@implementation SJFilmEditingGenerateResultControlLayer {
    BOOL _needDelay;
}
@synthesize restarted = _restarted;

- (void)restartControlLayer {
    _restarted = YES;
    self.flashingView.alpha = 0.001;
    self.itemsContainerView.alpha = 0.001;
    self.flashingView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    self.coverImageView.alpha = 0.001;
    sj_view_makeAppear(self.controlView, YES);
    __weak typeof(self) _self = self;
    [self _getScreenshot:^(UIImage * _Nullable img) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.coverImageView.image = img;
        [UIView animateWithDuration:0 animations:^{} completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.flashingView.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.flashingView.alpha = 0.001;
                    self.coverImageView.alpha = 1;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3 animations:^{
                        self.itemsContainerView.alpha = 1;
                    }];
                    
                    sj_view_makeAppear(self.topContainerView, YES);
                    [self.flashingView removeFromSuperview];
                    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
                    CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
                    CGFloat min = MIN(screenWidth, screenHeight);
                    CGFloat max = MAX(screenWidth, screenHeight);
                    
                    [self.coverImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.offset(0);
                        make.centerY.equalTo(self.mas_centerY).multipliedBy(0.82);
                        make.width.equalTo(self).multipliedBy(0.4);
                        make.height.equalTo(self.coverImageView.mas_width).multipliedBy(min/max);
                    }];
                    
                    CGFloat scale = img?(self.coverImageView.image.size.width / self.coverImageView.image.size.height):0;
                    CGFloat maxW = self.bounds.size.width * 0.4;
                    CGFloat showH = maxW * min / max;
                    CGFloat showW = showH * scale;
                    CGFloat rightMargin = floor((maxW - showW) * 0.5);
                    [self.promptLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.offset(-8);
                        make.right.offset(-(rightMargin + 8));
                    }];
                    
                    [UIView animateWithDuration:0.6 animations:^{
                        [self layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        [self _generateResult];
                    }];
                }];
            }];
        }];
    }];
}

- (void)_getScreenshot:(void(^)(UIImage *_Nullable img))block {
    if ( [self.player.assetURL isFileURL] ) {
        if ( block ) block(self.player.screenshot);
    }
    else {
        [self.player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(@"处理中");
            make.textColor(UIColor.whiteColor);
        }] duration:-1];
        __weak typeof(self) _self = self;
        [self.player screenshotWithTime:self.player.currentTime completion:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, UIImage * _Nullable image, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [videoPlayer.prompt hidden];
            if ( block ) block(image);
        }];
    }
}

- (void)exitControlLayer {
    _restarted = NO;
    sj_view_makeDisappear(self.topContainerView, YES);
    sj_view_makeDisappear(self.controlView, YES, ^{
        if ( !self->_restarted ) {
            [self.controlView removeFromSuperview];
            [self.coverImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.offset(0);
            }];
        }
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

- (void)setShareItems:(nullable NSArray<SJFilmEditingResultShareItem *> *)shareItems {
    _itemsContainerView.shareItems = shareItems;
}

- (nullable NSArray<SJFilmEditingResultShareItem *> *)shareItems {
    return _itemsContainerView.shareItems;
}

- (void)_generateResult {
    _result = [[SJVideoPlayerFilmEditingGeneratedResult alloc] init];
    
    __weak typeof(self) _self = self;
    _result.exportProgressDidChangeExeBlock = ^(SJVideoPlayerFilmEditingGeneratedResult * _Nonnull result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _updatePromptLabelText:[NSString stringWithFormat:@"%@ %.0f%%", SJFilmEditingSettings.commonSettings.exportingText, result.exportProgress * 100]];
    };
    
    _result.exportStateDidChangeExeBlock = ^(SJVideoPlayerFilmEditingGeneratedResult * _Nonnull result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _updateTopItemSettings];
        SJFilmEditingSettings *settings = [SJFilmEditingSettings commonSettings];
        switch ( result.exportState ) {
            case SJFilmEditingExportStateUnknown:
            case SJFilmEditingExportStateCancelled:
            case SJFilmEditingExportStateExporting:
                break;
            case SJFilmEditingExportStateFailed: {
                [self _updatePromptLabelText:settings.exportFailedText];
            }
                break;
            case SJFilmEditingExportStateSuccess: {
                if ( result.operation == SJVideoPlayerFilmEditingOperation_Screenshot ) {
                    [self _updatePromptLabelText:settings.screenshotSuccessText];
                }
                else {
                    [self _updatePromptLabelText:settings.exportSuccessText];
                }
                
                switch ( result.operation ) {
                    case SJVideoPlayerFilmEditingOperation_Unknown:
                    case SJVideoPlayerFilmEditingOperation_Screenshot:
                        break;
                    case SJVideoPlayerFilmEditingOperation_Export: {
                        self.exportedVideoPlayer.assetURL = self.result.fileURL;
                        [self.coverImageView insertSubview:self.exportedVideoPlayer.view belowSubview:self.promptLabel];
                        self.exportedVideoPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                        self.exportedVideoPlayer.view.frame = self.coverImageView.bounds;
                    }
                        break;
                    case SJVideoPlayerFilmEditingOperation_GIF: {
                        self.coverImageView.image = self.result.image;
                    }
                        break;
                }
                
                 [self _uploadResultIfNeeded];
                
                if ( self.parameters.saveResultToAlbumWhenExportSuccess ) {
                    [self.player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                        make.append(settings.savingToAlbumText);
                        make.textColor(UIColor.whiteColor);
                    }] duration:-1];
                    [self.saveHandler saveResult:result completionHandler:^(BOOL r, id<SJFilmEditingSaveResultFailed>  _Nonnull failed) {
                        __strong typeof(_self) self = _self;
                        if ( !self ) return ;
                        if ( r ) {
                            [self.player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                                make.append(settings.saveToAlbumSuccessText);
                                make.textColor(UIColor.whiteColor);
                            }]];
                            if ( !self.parameters.resultNeedUpload ) {
                                [self _updatePromptLabelText:settings.saveToAlbumSuccessText];
                            }
                        }
                        else {
                            [self.player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                                make.append(failed.toString);
                                make.textColor(UIColor.whiteColor);
                            }]];
                            if ( !self.parameters.resultNeedUpload ) {
                                [self _updatePromptLabelText:settings.albumAuthDeniedText];
                            }
                        }
                        
                    }];
                }
            }
                break;
        }
    };
    
    _result.uploadProgressDidChangeExeBlock = ^(SJVideoPlayerFilmEditingGeneratedResult * _Nonnull result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _updatePromptLabelText:[NSString stringWithFormat:@"%@ %.0f%%", SJFilmEditingSettings.commonSettings.uploadingText, result.uploadProgress * 100]];
    };
    
    _result.uploadStateDidChangeExeBlock = ^(SJVideoPlayerFilmEditingGeneratedResult * _Nonnull result) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        SJFilmEditingSettings *settings = [SJFilmEditingSettings commonSettings];
        switch ( result.uploadState ) {
            case SJFilmEditingResultUploadStateUnknown:
            case SJFilmEditingResultUploadStateUploading:
            case SJFilmEditingResultUploadStateCancelled:
                break;
            case SJFilmEditingResultUploadStateFailed: {
                [self _updatePromptLabelText:settings.uploadFailedText];
            }
                break;
            case SJFilmEditingResultUploadStateSuccessful: {
                [self _updatePromptLabelText:settings.uploadSuccessText];
            }
                break;
        }
    };
    
    switch ( _parameters.operation ) {
        case SJVideoPlayerFilmEditingOperation_Unknown:
            return;
        case SJVideoPlayerFilmEditingOperation_Screenshot: {
            [self _generateScreenshot];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            [self _generateVideo];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_GIF: {
            [self _generateGIF];
        }
            break;
    }
}

- (void)_generateScreenshot {
    _result.operation = SJVideoPlayerFilmEditingOperation_Screenshot;
    _result.thumbnailImage = _result.image = _coverImageView.image;
    _result.exportState = _coverImageView.image?SJFilmEditingExportStateSuccess:SJFilmEditingExportStateFailed;
}

- (void)_generateVideo {
    _result.operation = SJVideoPlayerFilmEditingOperation_Export;
    _result.exportState = SJFilmEditingExportStateExporting;
    _result.exportProgress = 0.001;
    
    NSTimeInterval begin = CMTimeGetSeconds(_parameters.range.start);
    NSTimeInterval duration = CMTimeGetSeconds(_parameters.range.duration);
    __weak typeof(self) _self = self;
    [_player exportWithBeginTime:begin duration:duration presetName:nil progress:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.result.exportProgress = progress;
    } completion:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, NSURL * _Nonnull fileURL, UIImage * _Nonnull thumbnailImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.result.thumbnailImage = thumbnailImage;
        self.result.fileURL = fileURL;
        self.result.exportProgress = 1;
        self.result.exportState = SJFilmEditingExportStateSuccess;
    } failure:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, NSError * _Nonnull error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.result.exportState = SJFilmEditingExportStateFailed;
    }];
}

- (void)_generateGIF {
    _result.operation = SJVideoPlayerFilmEditingOperation_GIF;
    _result.exportState = SJFilmEditingExportStateExporting;
    _result.exportProgress = 0.001;
    
    NSTimeInterval begin = CMTimeGetSeconds(_parameters.range.start);
    NSTimeInterval duration = CMTimeGetSeconds(_parameters.range.duration);
    __weak typeof(self) _self = self;
    [_player generateGIFWithBeginTime:begin duration:duration progress:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.result.exportProgress = progress;
    } completion:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, UIImage * _Nonnull imageGIF, UIImage * _Nonnull thumbnailImage, NSURL * _Nonnull filePath) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.result.image = imageGIF;
        self.result.thumbnailImage = thumbnailImage;
        self.result.fileURL = filePath;
        self.result.exportProgress = 1;
        self.result.exportState = SJFilmEditingExportStateSuccess;
    } failure:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, NSError * _Nonnull error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.result.exportState = SJFilmEditingExportStateFailed;
    }];
}

- (void)_uploadResultIfNeeded {
    if ( !_parameters.resultNeedUpload ) {
        return;
    }
    
    if ( !_parameters.resultUploader ) {
        return;
    }
    
    self.result.uploadState = SJFilmEditingResultUploadStateUploading;
    
    __weak typeof(self) _self = self;
    [_parameters.resultUploader upload:_result progress:^(float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.result.uploadProgress = progress;
    } success:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.result.uploadState = SJFilmEditingResultUploadStateSuccessful;
    } failure:^(NSError * _Nonnull error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.result.uploadState = SJFilmEditingResultUploadStateFailed;
    }];
}

- (void)_updatePromptLabelText:(NSString *)text {
    _promptLabel.attributedText = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.font([UIFont systemFontOfSize:12]).textColor([UIColor whiteColor]);
        make.append(text);
        make.shadow(^(NSShadow * _Nonnull make) {
            make.shadowColor = UIColor.blackColor;
            make.shadowOffset = CGSizeMake(0, 0.5);
        });
    }];
}

- (void)_cancel {
    if ( self.result.exportState == SJFilmEditingExportStateExporting ) {
        [_player cancelExportOperation];
        [_player cancelGenerateGIFOperation];
    }
    
    if ( self.result.uploadState == SJFilmEditingResultUploadStateUploading ) {
        [self.parameters.resultUploader cancelUpload:self.result];
    }
    
    if ( self.cancelledOperationExeBlock )
        self.cancelledOperationExeBlock(self);
}

- (void)_handleClickedShareItemEvent:(SJFilmEditingResultShareItem *)item {
    if ( _needDelay )
        return;
    _needDelay = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_needDelay = NO;
    });
    
    if ( !self.clickedResultShareItemExeBlock ) {
        return;
    }
    
    SJFilmEditingSettings *settings = [SJFilmEditingSettings commonSettings];
    
    // export
    switch ( self.result.exportState ) {
        case SJFilmEditingExportStateSuccess: break;
            
        case SJFilmEditingExportStateUnknown:
        case SJFilmEditingExportStateCancelled: return;
        case SJFilmEditingExportStateFailed: {
            [_player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(settings.exportFailedText);
                make.textColor(UIColor.whiteColor);
            }]];
        }
            return;
            
        case SJFilmEditingExportStateExporting: {
            [_player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(settings.exportingText);
                make.textColor(UIColor.whiteColor);
            }]];
        }
            return;
    }
    
    if ( !self.parameters.resultNeedUpload || item.canAlsoClickedWhenUploading ) {
        self.clickedResultShareItemExeBlock(self.player, item, self.result);
        return;
    }
    
    // upload
    switch ( self.result.uploadState ) {
        case SJFilmEditingResultUploadStateUnknown: break;
        case SJFilmEditingResultUploadStateCancelled: break;
        case SJFilmEditingResultUploadStateFailed: {
            [_player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(settings.uploadFailedText);
                make.textColor(UIColor.whiteColor);
            }]];
        }
            break;
        case SJFilmEditingResultUploadStateSuccessful: {
            self.clickedResultShareItemExeBlock(self.player, item, self.result);
        }
            break;
        case SJFilmEditingResultUploadStateUploading: {
            [_player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(settings.uploadingText);
                make.textColor(UIColor.whiteColor);
            }]];
        }
            break;
    }
}

#pragma mark -

- (void)_setupViews {
    self.autoAdjustTopSpacing = NO;
    self.topMargin = 20;
    self.topHeight = 35;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    [self _addItemToTopAdapter];
    [self _updateTopItemSettings];
        
    _coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self insertSubview:_coverImageView atIndex:0];
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    _itemsContainerView = [[SJFilmEditingResultShareItemsContainerView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) _self = self;
    _itemsContainerView.clickedShareItemExeBlock = ^(SJFilmEditingResultShareItemsContainerView * _Nonnull view, SJFilmEditingResultShareItem * _Nonnull item) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _handleClickedShareItemEvent:item];
    };
    [self addSubview:_itemsContainerView];
    [_itemsContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(self.coverImageView.mas_bottom);
        make.bottom.equalTo(self);
    }];
    
    _promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_coverImageView addSubview:_promptLabel];
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.offset(-8);
    }];
    
    _flashingView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_flashingView];
    [_flashingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (void)_addItemToTopAdapter {
    self.topContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Top;
    [self.topContainerView cleanColors];
    sj_view_initializes(self.topContainerView);
    CGFloat buttonH = self.topHeight;
    CGFloat buttonW = ceil(buttonH * 2.8);
    _backButtonContainerView = [[SJFilmEditingButtonContainerView alloc] initWithFrame:CGRectZero buttonSize:CGSizeMake(buttonW, buttonH)];
    _backButtonContainerView.frame = CGRectMake(0, 0, buttonW, buttonH);
    __weak typeof(self) _self = self;
    _backButtonContainerView.clickedBackButtonExeBlock = ^(SJFilmEditingButtonContainerView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _cancel];
    };
    
    SJEdgeControlButtonItem *backItem = [[SJEdgeControlButtonItem alloc] initWithTag:SJTopItem_Back];
    backItem.insets = SJEdgeInsetsMake(self.topMargin, 0);
    backItem.customView = _backButtonContainerView;
    [self.topAdapter addItem:backItem];
}

- (void)_updateTopItemSettings {
    SJFilmEditingSettings * _Nonnull setting = [SJFilmEditingSettings commonSettings];
    SJFilmEditingBackButton *backButton = _backButtonContainerView.button;
    if ( _result.exportState != SJFilmEditingExportStateSuccess ) {
        [backButton setTitle:setting.cancelText forState:UIControlStateNormal];
    }
    else {
        [backButton setTitle:setting.doneText forState:UIControlStateNormal];
    }
    [self.topAdapter reload];
}

#pragma mark -

- (void)_initializeObserver {
    _settingsUpdatedObserver = [[SJFilmEditingSettingsUpdatedObserver alloc] init];
    __weak typeof(self) _self = self;
    _settingsUpdatedObserver.updatedExeBlock = ^(SJFilmEditingSettings *settings) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _updateTopItemSettings];
    };
}

@synthesize exportedVideoPlayer = _exportedVideoPlayer;
- (SJBaseVideoPlayer *)exportedVideoPlayer {
    if ( _exportedVideoPlayer ) return _exportedVideoPlayer;
    _exportedVideoPlayer = [SJBaseVideoPlayer player];
    _exportedVideoPlayer.pauseWhenAppDidEnterBackground = YES;
    _exportedVideoPlayer.resumePlaybackWhenAppDidEnterForeground = YES;
    _exportedVideoPlayer.view.backgroundColor = [UIColor clearColor];
    for ( UIView *view in _exportedVideoPlayer.view.subviews ) {
        view.backgroundColor = [UIColor clearColor];
    }
    _exportedVideoPlayer.gestureControl.supportedGestureTypes = SJPlayerGestureTypeMask_None;
    _exportedVideoPlayer.rotationManager.disabledAutorotation = YES;
    _exportedVideoPlayer.playbackObserver.didPlayToEndTimeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        [player replay];
    };
    return _exportedVideoPlayer;
}

@synthesize saveHandler = _saveHandler;
- (SJFilmEditingSaveResultToAlbumHandler *)saveHandler {
    if ( _saveHandler ) return _saveHandler;
    return _saveHandler = [SJFilmEditingSaveResultToAlbumHandler new];
}
#pragma mark -

- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _player = videoPlayer;
    [videoPlayer needHiddenStatusBar];
    sj_view_makeDisappear(self.topContainerView, NO);
}

- (BOOL)canTriggerRotationOfVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    return NO;
}

- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    return NO;
}

- (BOOL)canPerformPlayForVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    return NO;
}
- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer { }
- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer { }
@end
NS_ASSUME_NONNULL_END
