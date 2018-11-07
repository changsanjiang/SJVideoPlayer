//
//  SJFilmEditingControlLayer.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJFilmEditingControlLayer.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#if __has_include(<SJUIFactory/SJUIFactory.h>)
#import <SJUIFactory/SJUIFactory.h>
#else
#import "SJUIFactory.h"
#endif
#import "SJFilmEditingResultPresentView.h"
#import "SJFilmEditingResultShareItem.h"
#import "SJFilmEditingRecordingView.h"
#import "SJFilmEditingGenerateGIFView.h"
#if __has_include(<SJBaseVideoPlayer/SJPrompt.h>)
#import <SJBaseVideoPlayer/SJPrompt.h>
#else
#import "SJPrompt.h"
#endif
#import "UIView+SJFilmEditingAdd.h"
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer+PlayStatus.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer+PlayStatus.h>
#else
#import "SJBaseVideoPlayer+PlayStatus.h"
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJVideoPlayerFilmEditingResultUploadState) {
    SJVideoPlayerFilmEditingResultUploadStateUnknown,
    SJVideoPlayerFilmEditingResultUploadStateUploading,
    SJVideoPlayerFilmEditingResultUploadStateFailed,
    SJVideoPlayerFilmEditingResultUploadStateSuccessful,
    SJVideoPlayerFilmEditingResultUploadStateCancelled,
};

typedef SJVideoPlayerFilmEditingResultUploadState SJVideoPlayerFilmEditingResultExportState;


/// Initial value
@interface SJFilmEditingVideoPlayerPropertyRecroder: NSObject
@property (nonatomic) BOOL enableControlLayerDisplayController;
@property (nonatomic) BOOL disableRotation;
@end



@interface SJVideoPlayerFilmEditingResult : NSObject <SJVideoPlayerFilmEditingResult>
@property (nonatomic) SJVideoPlayerFilmEditingOperation operation;
@property (nonatomic, strong, nullable) UIImage *thumbnailImage;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) NSURL *fileURL;
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *currentPlayAsset;
@property (nonatomic) SJVideoPlayerFilmEditingResultUploadState uploadState;
@property (nonatomic) SJVideoPlayerFilmEditingResultExportState exportState;


- (NSData * __nullable)data;
@end

@interface SJFilmEditingControlLayer ()

@property (nonatomic, strong, readonly) UIView *btnContainerView;
@property (nonatomic, strong, readonly) UIButton *screenshotBtn;
@property (nonatomic, strong, readonly) UIButton *exportBtn;
@property (nonatomic, strong, readonly) UIButton *GIFBtn;
@property (nonatomic, strong, nullable) SJFilmEditingResultPresentView *resultPresentView;
@property (nonatomic, strong, readonly) SJFilmEditingRecordingView *recordView;
@property (nonatomic, strong, readonly) SJFilmEditingGenerateGIFView *generateGIFView;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGR;
@property (nonatomic, readwrite) SJFilmEditingStatus status;
@property (nonatomic, strong, nullable) SJVideoPlayerFilmEditingResult *result;
@property (nonatomic, strong, readonly) SJPrompt *promptView;
@property (nonatomic, readonly) NSTimeInterval promptDuration;
@property (nonatomic) BOOL itemClickedInterval;

#pragma mark
@property (nonatomic, strong, nullable) SJFilmEditingVideoPlayerPropertyRecroder *propertyRecorder;
@property (nonatomic, strong, nullable) SJFilmEditingSettings *settings;
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *videoPlayer;
@end
NS_ASSUME_NONNULL_END

@implementation SJFilmEditingControlLayer {
    id _notifyToken;
}

@synthesize btnContainerView = _btnContainerView;
@synthesize screenshotBtn = _screenshotBtn;
@synthesize exportBtn = _exportBtn;
@synthesize GIFBtn = _GIFBtn;
@synthesize resultPresentView = _resultPresentView;
@synthesize recordView = _recordView;
@synthesize generateGIFView = _generateGIFView;
@synthesize tapGR = _tapGR;
@synthesize promptView = _promptView;
@synthesize restarted = _restarted;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    SJFilmEditingControlLayer.update(^(SJFilmEditingSettings * _Nonnull settings) {});
    __weak typeof(self) _self = self;
    _notifyToken = [NSNotificationCenter.defaultCenter addObserverForName:SJFilmEditingSettingsUpdateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self settingsUpdateNotification:note];
    }];
    return self;
}

- (void)dealloc {
    if ( _notifyToken ) [[NSNotificationCenter defaultCenter] removeObserver:_notifyToken];

#ifdef SJ_MAC
    NSLog(@"SJVideoPlayerLog: %d - %s", (int)__LINE__, __func__);
#endif
}

- (void)settingsUpdateNotification:(NSNotification *)notifi {
    SJFilmEditingSettings *settings = notifi.object;
    self.settings = settings;
    [self.GIFBtn setImage:settings.gifBtnImage forState:UIControlStateNormal];
    [self.exportBtn setImage:settings.exportBtnImage forState:UIControlStateNormal];
    [self.screenshotBtn setImage:settings.screenshotBtnImage forState:UIControlStateNormal];
}

- (void)exitControlLayer {
    _restarted = NO;
    if ( _propertyRecorder ) {
        _videoPlayer.disableAutoRotation = self.propertyRecorder.disableRotation;
        _videoPlayer.enableControlLayerDisplayController = self.propertyRecorder.enableControlLayerDisplayController;
        _propertyRecorder = nil;
    }
    _videoPlayer.controlLayerDataSource = nil;
    _videoPlayer.controlLayerDelegate = nil;
    [UIView animateWithDuration:0.4 animations:^{
        [self sj_disappear];
        [self.btnContainerView sj_disappear];
        [self cancel];
    } completion:^(BOOL finished) {
        [self->_generateGIFView removeFromSuperview]; self->_generateGIFView = nil;
        [self->_recordView removeFromSuperview]; self->_recordView = nil;
        [self->_resultPresentView removeFromSuperview]; self->_resultPresentView = nil;
        if ( !self->_restarted ) [self removeFromSuperview];
    }];
}

- (void)restartControlLayer {
    _restarted = YES;
    [self changedStatus:SJFilmEditingStatus_Unknown];
    self.currentOperation = SJVideoPlayerFilmEditingOperation_Unknown;
    [self.btnContainerView sj_disappear];
    [UIView animateWithDuration:0.4 animations:^{
        [self sj_appear];
        [self.btnContainerView sj_appear];
    }];
}

#pragma mark
- (void)setConfig:(SJVideoPlayerFilmEditingConfig *)config {
    _config = config;
    
    if ( config.disableScreenshot == NO && config.disableRecord == NO && config.disableGIF == NO ) return;
    [self _updateLayout];
}

+ (void (^)(void (^ _Nonnull)(SJFilmEditingSettings * _Nonnull)))update {
    return ^(void(^block)(SJFilmEditingSettings *settings)) {
        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block([SJFilmEditingSettings commonSettings]);
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                SJFilmEditingSettings *settings = [SJFilmEditingSettings commonSettings];
                [[NSNotificationCenter defaultCenter] postNotificationName:SJFilmEditingSettingsUpdateNotification object:settings];
            });
        });
    };
}

- (void)Extension_pauseAndDeterAppear {
    BOOL old = _videoPlayer.pausedToKeepAppearState;
    _videoPlayer.pausedToKeepAppearState = NO;              // Deter Appear
    [_videoPlayer pause];
    _videoPlayer.pausedToKeepAppearState = old;             // resume
}

- (UIView *)controlView {
    return self;
}

- (BOOL)controlLayerDisappearCondition {
    return NO;
}

- (BOOL)triggerGesturesCondition:(CGPoint)location {
    return NO;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _videoPlayer = videoPlayer;
    self.propertyRecorder = [SJFilmEditingVideoPlayerPropertyRecroder new];
    self.propertyRecorder.disableRotation = videoPlayer.disableAutoRotation;
    self.propertyRecorder.enableControlLayerDisplayController = videoPlayer.enableControlLayerDisplayController;
    
    videoPlayer.disableAutoRotation = YES;
    videoPlayer.enableControlLayerDisplayController = NO;
    [videoPlayer setControlLayerAppeared:NO];
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer statusDidChanged:(SJVideoPlayerPlayStatus)status {
    if ( self.currentOperation == SJVideoPlayerFilmEditingOperation_Unknown ) return;
    switch ( status ) {
        case SJVideoPlayerPlayStatusUnknown:
        case SJVideoPlayerPlayStatusPrepare:
        case SJVideoPlayerPlayStatusReadyToPlay: break;
        case SJVideoPlayerPlayStatusPlaying: {
            [self resume];
        }
            break;
        case SJVideoPlayerPlayStatusPaused: {
            if ( [videoPlayer playStatus_isPaused_ReasonPause] || [videoPlayer playStatus_isPaused_ReasonBuffering] ) {
                if ( self.status == SJFilmEditingStatus_Recording ) [self pause];
            }
        }
            break;
        case SJVideoPlayerPlayStatusInactivity: {
            if ( [videoPlayer playStatus_isInactivity_ReasonPlayEnd] ) {
                [self finalize];
                [self.promptView showTitle:self.settings.videoPlayDidToEndText duration:self.promptDuration];
            }
            else if ( [videoPlayer playStatus_isInactivity_ReasonPlayFailed] ) {
                [self pause];
                [self.promptView showTitle:self.settings.operationFailedPrompt duration:self.promptDuration];
            }
        }
            break;
    }
}

- (void)appWillEnterForeground:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( self.currentOperation == SJVideoPlayerFilmEditingOperation_Unknown ) return;
    if ( self.currentOperation == SJVideoPlayerFilmEditingOperation_Screenshot ) return;
    
    if ( self.status == SJFilmEditingStatus_Paused ) {
        [videoPlayer play];
        [self resume];
    }
}

- (void)appDidEnterBackground:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( self.currentOperation == SJVideoPlayerFilmEditingOperation_Unknown ) return;
    if ( self.currentOperation == SJVideoPlayerFilmEditingOperation_Screenshot ) return;
    
    if ( self.status == SJFilmEditingStatus_Recording ) {
        [self pause];
    }
}



#pragma mark
- (void)clickedBtn:(UIButton *)btn {
    if ( self.config.shouldStartWhenUserSelectedAnOperation ) {
        if ( !self.config.shouldStartWhenUserSelectedAnOperation(self.videoPlayer, btn.tag) ) return;
    }
    
    self.currentOperation = btn.tag;
    switch ( (SJVideoPlayerFilmEditingOperation)btn.tag ) {
        case SJVideoPlayerFilmEditingOperation_Unknown: break;
        case SJVideoPlayerFilmEditingOperation_Screenshot: {
            [self finalize];
        }
            break;
            // export
        case SJVideoPlayerFilmEditingOperation_Export:
        case SJVideoPlayerFilmEditingOperation_GIF: {
            [self start];
        }
            break;
    }

    [_btnContainerView sj_disappear];
}

- (void)setCurrentOperation:(SJVideoPlayerFilmEditingOperation)currentOperation {
    _currentOperation = currentOperation;
   
    _videoPlayer.videoGravity = AVLayerVideoGravityResizeAspect;
    switch ( currentOperation ) {
        case SJVideoPlayerFilmEditingOperation_Unknown: break;
        case SJVideoPlayerFilmEditingOperation_Screenshot: {
            [self Extension_pauseAndDeterAppear];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_GIF:
        case SJVideoPlayerFilmEditingOperation_Export: break;
    }
    
    
#ifdef SJ_MAC
    switch ( currentOperation ) {
        case SJVideoPlayerFilmEditingOperation_Unknown: break;
        case SJVideoPlayerFilmEditingOperation_GIF: {
            NSLog(@"User selected Operation: GIF ");
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            NSLog(@"User selected Operation: Export ");
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Screenshot: {
            NSLog(@"User selected Operation: Screenshot ");
        }
            break;
    }
#endif
}

- (void)start {
    switch ( self.currentOperation ) {
        case SJVideoPlayerFilmEditingOperation_Unknown: break;
        case SJVideoPlayerFilmEditingOperation_GIF: {
            self.generateGIFView.finishRecordingPromptText = self.settings.finishRecordingPromptText;
            _generateGIFView.waitingForRecordingPromptText = self.settings.waitingForRecordingPromptText;
            _generateGIFView.cancelBtnTitle = self.settings.cancelBtnTitle;
            _generateGIFView.finishRecordingBtnImage = self.settings.finishRecordingBtnImage;
            _generateGIFView.alpha = 0.001;
            [self addSubview:_generateGIFView];
            [UIView animateWithDuration:0.25 animations:^{
                self->_generateGIFView.alpha = 1;
            } completion:^(BOOL finished) {
                [self->_generateGIFView start];
            }];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            self.recordView.finishRecordingPromptText = self.settings.finishRecordingPromptText;
            _recordView.waitingForRecordingPromptText = self.settings.waitingForRecordingPromptText;
            _recordView.cancelBtnTitle = self.settings.cancelBtnTitle;
            _recordView.finishRecordingBtnImage = self.settings.finishRecordingBtnImage;
            _recordView.alpha = 0.001;
            [self addSubview:_recordView];
            [UIView animateWithDuration:0.25 animations:^{
                self->_recordView.alpha = 1;
            } completion:^(BOOL finished) {
                [self->_recordView start];
            }];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Screenshot: break;
    }
}

- (void)pause {
    if ( self.status == SJFilmEditingStatus_Paused ) return;
    switch ( self.currentOperation ) {
        case SJVideoPlayerFilmEditingOperation_Unknown: break;
        case SJVideoPlayerFilmEditingOperation_GIF: {
            [_generateGIFView pause];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            [_recordView pause];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Screenshot: break;
    }
}

- (void)resume {
    if ( self.status == SJFilmEditingStatus_Recording ) return;
    switch ( self.currentOperation ) {
        case SJVideoPlayerFilmEditingOperation_Unknown: break;
        case SJVideoPlayerFilmEditingOperation_GIF: {
            [_generateGIFView resume];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            [_recordView resume];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Screenshot:  break;
    }
}

- (void)setStatus:(SJFilmEditingStatus)status {
    _status = status;
}

- (void)cancel {
    if ( self.status == SJFilmEditingStatus_Cancelled ) return;
    switch ( self.currentOperation ) {
        case SJVideoPlayerFilmEditingOperation_GIF: {
            [_videoPlayer cancelGenerateGIFOperation];
            [_generateGIFView cancel];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            [_videoPlayer cancelExportOperation];
            [_recordView cancel];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Screenshot:
        case SJVideoPlayerFilmEditingOperation_Unknown: {
            [self changedStatus:SJFilmEditingStatus_Cancelled];
        }
            break;
    }
    
    self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateCancelled;
    
    if ( self.result.uploadState == SJVideoPlayerFilmEditingResultUploadStateUploading ) {
        [self.config.resultUploader cancelUpload:self.result];
        self.result.uploadState = SJFilmEditingStatus_Cancelled;
    }
}

- (void)finalize {
    
    SJFilmEditingResultPresentView *resultView = nil;
    self.result = [SJVideoPlayerFilmEditingResult new];
    self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateUploading;
    self.result.operation = self.currentOperation;
    void(^completion)(void);
    __weak typeof(self) _self = self;
    switch ( self.currentOperation ) {
        case SJVideoPlayerFilmEditingOperation_Unknown: break;
        case SJVideoPlayerFilmEditingOperation_GIF: {
            [_generateGIFView finished];
            
            resultView = [self _presentResultViewWithType:SJFilmEditingResultPresentViewType_GIF];
            
            completion = ^ {
                NSTimeInterval currentTime = self.videoPlayer.currentTime;
                NSTimeInterval duration = self.generateGIFView.duration;
                [self.videoPlayer generateGIFWithBeginTime:currentTime - duration duration:duration progress:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, float progress) {
                    resultView.exportProgress = progress;
                } completion:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, UIImage * _Nonnull imageGIF, UIImage * _Nonnull thumbnailImage, NSURL * _Nonnull filePath) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    resultView.image = imageGIF;
                    
                    self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateSuccessful;
                    self.result.thumbnailImage = thumbnailImage;
                    self.result.image = imageGIF;
                    self.result.fileURL = filePath;
                    self.result.currentPlayAsset = self.videoPlayer.URLAsset;
                    [resultView exportEndedWithStatus:YES];
                    [self upload:self.result resultView:resultView];
                } failure:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, NSError * _Nonnull error) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return ;
                    [resultView exportEndedWithStatus:NO];
                    self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateFailed;
                }];
            };
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            [_recordView finished];

            resultView = [self _presentResultViewWithType:SJFilmEditingResultPresentViewType_Video];
            
            completion = ^ {
                NSTimeInterval currentTime = self.videoPlayer.currentTime;
                [self.videoPlayer exportWithBeginTime:currentTime - self.recordView.duration endTime:currentTime presetName:nil progress:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, float progress) {
                    resultView.exportProgress = progress;
                } completion:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, NSURL * _Nonnull fileURL, UIImage * _Nonnull thumbnailImage) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    resultView.videoURL = fileURL;
                    
                    self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateSuccessful;
                    self.result.thumbnailImage = thumbnailImage;
                    self.result.fileURL = fileURL;
                    self.result.currentPlayAsset = self.videoPlayer.URLAsset;
                    [resultView exportEndedWithStatus:YES];
                    [self upload:self.result resultView:resultView];

                } failure:^(__kindof SJBaseVideoPlayer * _Nonnull videoPlayer, NSError * _Nonnull error) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return ;

                    [resultView exportEndedWithStatus:NO];
                    self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateFailed;
                }];
            };
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Screenshot: {
            [self changedStatus:SJFilmEditingStatus_Finished];
            
            resultView = [self _presentResultViewWithType:SJFilmEditingResultPresentViewType_Screenshot];
            
            completion = ^ {
                self.result.image = self.result.thumbnailImage = resultView.image;
                self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateSuccessful;
                [resultView exportEndedWithStatus:YES];
                [self upload:self.result resultView:resultView];
            };
        }
            break;
    }
    
    resultView.image = self.videoPlayer.screenshot;
    
    // flash
    resultView.alpha = 0.001;
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundColor = [UIColor clearColor];
            resultView.alpha = 1;
        } completion:^(BOOL finished) {
            [resultView presentResultViewWithCompletion:completion];
        }];
    }];
}

- (void)upload:(SJVideoPlayerFilmEditingResult *)result  resultView:(SJFilmEditingResultPresentView *)resultView {
    if ( !self.config.resultNeedUpload ) return;
    result.uploadState = SJVideoPlayerFilmEditingResultUploadStateUploading;
    __weak typeof(self) _self = self;
    [self.config.resultUploader upload:result progress:^(float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        resultView.uploadProgress = progress;
    } success:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        result.uploadState = SJVideoPlayerFilmEditingResultUploadStateSuccessful;
        [resultView uploadEndedWithStatus:YES];
    } failure:^(NSError * _Nonnull error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        result.uploadState = SJVideoPlayerFilmEditingResultUploadStateFailed;
        [resultView uploadEndedWithStatus:NO];
    }];
}

- (SJFilmEditingResultPresentView *)_presentResultViewWithType:(SJFilmEditingResultPresentViewType)type {

    [_recordView removeFromSuperview];
    [_generateGIFView removeFromSuperview];
    
    _resultPresentView = [[SJFilmEditingResultPresentView alloc] initWithType:type];
    _resultPresentView.frame = self.bounds;
    _resultPresentView.shareItems = self.config.resultShareItems;
    _resultPresentView.cancelBtnTitle = self.settings.cancelBtnTitle;
    _resultPresentView.uploadingPrompt = self.settings.uploadingPrompt;
    _resultPresentView.uploadSuccessfullyPrompt = self.settings.uploadSuccessfullyPrompt;
    _resultPresentView.exportingPrompt = self.settings.exportingPrompt;
    _resultPresentView.exportSuccessfullyPrompt = self.settings.exportSuccessfullyPrompt;
    _resultPresentView.operationFailedPrompt = self.settings.operationFailedPrompt;

    __weak typeof(self) _self = self;
    _resultPresentView.clickedCancelBtnExeBlock = ^(SJFilmEditingResultPresentView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _userClickedCancellBtn];
    };
    
    
    NSTimeInterval promptDuration = self.promptDuration;
    _resultPresentView.clickedItemExeBlock = ^(SJFilmEditingResultPresentView * _Nonnull view, SJFilmEditingResultShareItem *  _Nonnull item) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.itemClickedInterval ) return;
        // click interval 1s.
        self.itemClickedInterval = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(promptDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.itemClickedInterval = NO;
        });
        
        if ( !self.config.clickedResultShareItemExeBlock ) return;
        
        
        // export state
        switch ( self.result.exportState ) {
            case SJVideoPlayerFilmEditingResultUploadStateSuccessful: break;

            case SJVideoPlayerFilmEditingResultUploadStateUnknown:
            case SJVideoPlayerFilmEditingResultUploadStateCancelled: return;
            case SJVideoPlayerFilmEditingResultUploadStateFailed: {
                [self.promptView showTitle:self.settings.operationFailedPrompt duration:promptDuration];
            }
                return;
                
            case SJVideoPlayerFilmEditingResultUploadStateUploading: {
                [self.promptView showTitle:self.settings.exportingPrompt duration:promptDuration];
            }
                return;
        }
        
        
        if ( !self.config.resultNeedUpload || item.canAlsoClickedWhenUploading ) {
            self.config.clickedResultShareItemExeBlock(self.videoPlayer, item, self.result);
            return;
        }
        
        
        // upload sate
        switch ( self.result.uploadState ) {
            case SJVideoPlayerFilmEditingResultUploadStateUnknown: break;
            case SJVideoPlayerFilmEditingResultUploadStateCancelled: break;
            case SJVideoPlayerFilmEditingResultUploadStateFailed: {
                [self.promptView showTitle:self.settings.operationFailedPrompt duration:promptDuration];
            }
                break;
            case SJVideoPlayerFilmEditingResultUploadStateSuccessful: {
                self.config.clickedResultShareItemExeBlock(self.videoPlayer, item, self.result);
            }
                break;
            case SJVideoPlayerFilmEditingResultUploadStateUploading: {
                [self.promptView showTitle:self.settings.uploadingPrompt duration:promptDuration];
            }
                break;
        }
    };
    [self addSubview:_resultPresentView];
    return _resultPresentView;
}

#pragma mark -
- (UITapGestureRecognizer *)tapGR {
    if ( _tapGR ) return _tapGR;
    _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGR)];
    return _tapGR;
}

- (void)handleTapGR {
    CGPoint location = [_tapGR locationInView:self];
    if ( !CGRectContainsPoint(_resultPresentView.frame, location) &&
         !CGRectContainsPoint(_generateGIFView.frame, location) &&
         !CGRectContainsPoint(_recordView.frame, location)) {
        if ( [self.delegate respondsToSelector:@selector(userTappedBlankAreaOnControlLayer:)] ) {
            [self.delegate userTappedBlankAreaOnControlLayer:self];
        }
    }
}

- (void)changedStatus:(SJFilmEditingStatus)status {
    self.status = status;
    switch ( status ) {
        case SJFilmEditingStatus_Unknown: break;
        case SJFilmEditingStatus_Recording: {
            [self.videoPlayer play];
        }
            break;
        case SJFilmEditingStatus_Cancelled: { } break;
        case SJFilmEditingStatus_Paused: {
            [self Extension_pauseAndDeterAppear];
        }
            break;
        case SJFilmEditingStatus_Finished: {
            [self Extension_pauseAndDeterAppear];
        }
            break;
    }
    
    if ( [self.delegate respondsToSelector:@selector(filmEditingControlLayer:statusChanged:)] ) {
        [self.delegate filmEditingControlLayer:self statusChanged:status];
    }
    
#ifdef SJ_MAC
    switch ( status ) {
        case SJFilmEditingStatus_Unknown: break;
        case SJFilmEditingStatus_Recording: {
            NSLog(@"Recording");
        }
            break;
        case SJFilmEditingStatus_Cancelled: {
            NSLog(@"Cancelled");
        }
            break;
        case SJFilmEditingStatus_Paused: {
            NSLog(@"Paused");
        }
            break;
        case SJFilmEditingStatus_Finished: {
            NSLog(@"Finished");
        }
            break;
    }
#endif
}

#pragma mark -
- (void)_setupViews {
    [self addSubview:self.btnContainerView];
    [self addGestureRecognizer:self.tapGR]; // gesture
    
    [_btnContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.trailing.offset(SJ_is_iPhoneX() ? -(SJScreen_Max() - 375*16/9.0) *0.5 :0);
    }];
    
    [self _updateLayout];
    
    self.sj_disappearType = SJViewDisappearType_Alpha;
    _btnContainerView.sj_disappearType = SJViewDisappearType_All;
    _btnContainerView.sj_disappearTransform = CGAffineTransformMakeTranslation(49, 0);
    _resultPresentView.sj_disappearType = SJViewDisappearType_Alpha;

    [_btnContainerView sj_disappear];
}

- (void)_updateLayout {
    if ( self.config.disableScreenshot ) {
        [_screenshotBtn removeFromSuperview];
    }
    else {
        [self.btnContainerView addSubview:self.screenshotBtn];
    }
    
    if ( self.config.disableRecord ) {
        [_exportBtn removeFromSuperview];
    }
    else {
        [self.btnContainerView addSubview:self.exportBtn];
    }
    
    if ( self.config.disableGIF ) {
        [_GIFBtn removeFromSuperview];
    }
    else {
        [self.btnContainerView addSubview:self.GIFBtn];
    }
    
    NSArray<UIView *> *subviews = self.btnContainerView.subviews;
    NSInteger count = subviews.count;
    if ( count == 0 ) return;
    [subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
            if ( idx == 0 ) make.top.leading.trailing.offset(0);
            else {make.top.equalTo(subviews[idx -1].mas_bottom); make.leading.trailing.offset(0);}
            make.size.offset(49);
            if ( idx == count - 1 ) make.bottom.offset(0);
        }];
    }];
}

- (UIView *)btnContainerView {
    if ( _btnContainerView ) return _btnContainerView;
    _btnContainerView = [UIView new];
    return _btnContainerView;
}

#pragma mark -
- (UIButton *)screenshotBtn {
    if ( _screenshotBtn ) return _screenshotBtn;
    _screenshotBtn = [SJUIButtonFactory buttonWithTarget:self sel:@selector(clickedBtn:) tag:SJVideoPlayerFilmEditingOperation_Screenshot];
    return _screenshotBtn;
}

#pragma mark -
- (UIButton *)exportBtn {
    if ( _exportBtn ) return _exportBtn;
    _exportBtn = [SJUIButtonFactory buttonWithTarget:self sel:@selector(clickedBtn:) tag:SJVideoPlayerFilmEditingOperation_Export];
    return _exportBtn;
}

- (SJFilmEditingRecordingView *)recordView {
    if ( _recordView ) return _recordView;
    _recordView = [[SJFilmEditingRecordingView alloc] initWithFrame:self.bounds];
    _recordView.backgroundColor = [UIColor clearColor];
    __weak typeof(self) _self = self;
    _recordView.clickedCancleBtnExeBlock = ^(SJFilmEditingRecordingView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _userClickedCancellBtn];
    };
    
    _recordView.statusChangedExeBlock = ^(__kindof UIView * _Nonnull view, SJFilmEditingStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self changedStatus:status];
    };
    
    _recordView.clickedCompleteBtnExeBlock = ^(SJFilmEditingRecordingView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self finalize];
    };
    
    return _recordView;
}
#pragma mark -
- (UIButton *)GIFBtn {
    if ( _GIFBtn ) return _GIFBtn;
    _GIFBtn = [SJUIButtonFactory buttonWithTarget:self sel:@selector(clickedBtn:) tag:SJVideoPlayerFilmEditingOperation_GIF];
    return _GIFBtn;
}

- (SJFilmEditingGenerateGIFView *)generateGIFView {
    if ( _generateGIFView ) return _generateGIFView;
    _generateGIFView = [[SJFilmEditingGenerateGIFView alloc] initWithFrame:self.bounds];
    _generateGIFView.backgroundColor = [UIColor clearColor];
    __weak typeof(self) _self = self;
    _generateGIFView.clickedCancleBtnExeBlock = ^(SJFilmEditingGenerateGIFView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _userClickedCancellBtn];
    };
    
    _generateGIFView.clickedCompleteBtnExeBlock = ^(SJFilmEditingGenerateGIFView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self finalize];
    };
    
    _generateGIFView.statusChangedExeBlock = ^(__kindof UIView * _Nonnull view, SJFilmEditingStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self changedStatus:status];
    };
    return _generateGIFView;
}

#pragma mark -

- (SJPrompt *)promptView {
    if ( _promptView ) return _promptView;
    _promptView = [SJPrompt promptWithPresentView:self];
    return _promptView;
}

- (NSTimeInterval)promptDuration {
    return 2;
}

- (void)_userClickedCancellBtn {
    if ( [self.delegate respondsToSelector:@selector(userClickedCancelBtnOnControlLayer:)] ) {
        [self.delegate userClickedCancelBtnOnControlLayer:self];
    }
}
@end



@implementation SJVideoPlayerFilmEditingResult
- (NSData * __nullable)data {
    if ( self.fileURL ) return [NSData dataWithContentsOfURL:self.fileURL];
    else if ( self.image ) return UIImagePNGRepresentation(self.image);
    return nil;
}
@end


@implementation SJFilmEditingVideoPlayerPropertyRecroder
@end
