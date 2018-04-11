//
//  SJVideoPlayerFilmEditingControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerFilmEditingControlView.h"
#import <Masonry/Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import "UIView+SJVideoPlayerSetting.h"
#import "UIView+SJControlAdd.h"
#import "SJVideoPlayerFilmEditingResultView.h"
#import "SJFilmEditingResultShareItem.h"
#import "SJVideoPlayerFilmEditingRecordView.h"
#import "SJVideoPlayerFilmEditingGenerateGIFView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerFilmEditingControlView ()

@property (nonatomic, strong, readonly) UIView *btnContainerView;
@property (nonatomic, strong, readonly) UIButton *screenshotBtn;
@property (nonatomic, strong, readonly) UIButton *exportBtn;
@property (nonatomic, strong, readonly) UIButton *GIFBtn;
@property (nonatomic, strong, nullable) SJVideoPlayerFilmEditingResultView *showResultView;
@property (nonatomic, strong, readonly) SJVideoPlayerFilmEditingRecordView *recordView;
@property (nonatomic, strong, readonly) SJVideoPlayerFilmEditingGenerateGIFView *generateGIFView;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGR;
@property (nonatomic, weak, readwrite) SJFilmEditingResultUploader *uploader;
@property (nonatomic, readwrite) SJVideoPlayerFilmEditingStatus status;

@end
NS_ASSUME_NONNULL_END

@implementation SJVideoPlayerFilmEditingControlView

@synthesize btnContainerView = _btnContainerView;
@synthesize screenshotBtn = _screenshotBtn;
@synthesize exportBtn = _exportBtn;
@synthesize GIFBtn = _GIFBtn;
@synthesize showResultView = _showResultView;
@synthesize recordView = _recordView;
@synthesize generateGIFView = _generateGIFView;
@synthesize tapGR = _tapGR;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"SJVideoPlayerLog: %d - %s", (int)__LINE__, __func__);
#endif
}

- (void)clickedBtn:(UIButton *)btn {
    self.currentOperation = btn.tag;
    [self _prepareToExport];
    switch ( (SJVideoPlayerFilmEditingOperation)btn.tag ) {
            // screenshot
        case SJVideoPlayerFilmEditingOperation_Screenshot: {
            [self _showResultWithType:SJVideoPlayerFilmEditingResultViewType_Screenshot];
        }
            break;
            // export
        case SJVideoPlayerFilmEditingOperation_Export: {
            if ( _startRecordingExeBlock ) _startRecordingExeBlock(self);
            self.recordView.recordPromptText = self.resource.recordPromptText;
            _recordView.waitingForRecordingPromptText = self.resource.waitingForRecordingPromptText;
            _recordView.cancelBtnTitle = self.resource.cancelBtnTitle;
            _recordView.recordEndBtnImage = self.resource.recordEndBtnImage;
            _recordView.alpha = 0.001;
            [self addSubview:_recordView];
            [UIView animateWithDuration:0.25 animations:^{
                self->_recordView.alpha = 1;
            } completion:^(BOOL finished) {
                [self->_recordView start];
            }];
        }
            break;
            // generate gif
        case SJVideoPlayerFilmEditingOperation_GIF: {
            if ( _startRecordingExeBlock ) _startRecordingExeBlock(self);
            self.generateGIFView.recordPromptText = self.resource.recordPromptText;
            _generateGIFView.waitingForRecordingPromptText = self.resource.waitingForRecordingPromptText;
            _generateGIFView.cancelBtnTitle = self.resource.cancelBtnTitle;
            _generateGIFView.recordEndBtnImage = self.resource.recordEndBtnImage;
            _generateGIFView.alpha = 0.001;
            [self addSubview:_generateGIFView];
            [UIView animateWithDuration:0.25 animations:^{
                self->_generateGIFView.alpha = 1;
            } completion:^(BOOL finished) {
                [self->_generateGIFView start];
            }];
        }
            break;
    }

    [_btnContainerView disappear];
}


- (void)exportedVideo:(NSURL *)sandboxPath thumbnailImage:(UIImage *)thumbnailImage {
    
}

- (void)generatedGIF:(NSURL *)sandboxPath image_GIF:(UIImage *)image_GIF thumbnailImage:(UIImage *)thumbnailImage {
    
}

#pragma mark -
- (SJVideoPlayerFilmEditingStatus)status {
    if ( _showResultView ) return SJVideoPlayerFilmEditingStatus_PresentResults;
    
    switch ( self.currentOperation ) {
        case SJVideoPlayerFilmEditingOperation_GIF: {
            return _generateGIFView.status;
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            return _recordView.status;
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Screenshot: {
            return SJVideoPlayerFilmEditingStatus_Unknown;
        }
            break;
    }
}

- (void)pause {
    switch ( self.currentOperation ) {
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
    switch ( self.currentOperation ) {
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

- (void)finalize {
    switch ( self.currentOperation ) {
        case SJVideoPlayerFilmEditingOperation_GIF: {
            [_generateGIFView stop];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            [_recordView stop];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Screenshot: break;
    }
    [self _showResultWithType:SJVideoPlayerFilmEditingResultViewType_Video];
}

- (void)_prepareToExport {
    if ( [self.resultShare.delegate respondsToSelector:@selector(prepareToExport)] ) {
        self.uploader = [self.resultShare.delegate prepareToExport];
    }
}

- (void)_showResultWithType:(SJVideoPlayerFilmEditingResultViewType)type{
    [self statusChanged:SJVideoPlayerFilmEditingStatus_PresentResults];
    
    [_recordView removeFromSuperview];
    [_generateGIFView removeFromSuperview];
    
    _showResultView = [[SJVideoPlayerFilmEditingResultView alloc] initWithType:type];
    _showResultView.frame = self.bounds;
    _showResultView.cancelBtnTitle = self.resource.cancelBtnTitle;
    _showResultView.uploadingPrompt = self.resource.uploadingPrompt;
    _showResultView.exportingPrompt = self.resource.exportingPrompt;
    _showResultView.operationFailedPrompt = self.resource.operationFailedPrompt;
    _showResultView.alpha = 0.001;
    _showResultView.image = self.dataSource.playerScreenshot;
    _showResultView.items = self.resultShare.filmEditingResultShareItems;
    _showResultView.uploader = self.uploader;

    __weak typeof(self) _self = self;
    _showResultView.clickedCancelBtnExeBlock = ^(SJVideoPlayerFilmEditingResultView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.resultShare.delegate respondsToSelector:@selector(clickedCancelButton)] ) {
            [self.resultShare.delegate clickedCancelButton];
        }
    };
    _showResultView.clickedItemExeBlock = ^(SJVideoPlayerFilmEditingResultView * _Nonnull view, SJFilmEditingResultShareItem * _Nonnull item) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.resultShare.delegate respondsToSelector:@selector(clickedItem:)] ) {
            [self.resultShare.delegate clickedItem:item];
        }
    };
    [self addSubview:_showResultView];

    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundColor = [UIColor clearColor];
            self.showResultView.alpha = 1;
        } completion:^(BOOL finished) {
            [self.showResultView showResultWithCompletion:^{
                switch ( self.currentOperation ) {
                    case SJVideoPlayerFilmEditingOperation_Export: {
                        if ( self.recordCompleteExeBlock ) self.recordCompleteExeBlock(self, self.recordView.currentTime);
                    }
                        break;
                    case SJVideoPlayerFilmEditingOperation_Screenshot: {
                        if ( [self->_resultShare.delegate respondsToSelector:@selector(successfulScreenshot:)] ) {
                            [self.resultShare.delegate successfulScreenshot:self.showResultView.image];
                        }
                    }
                        break;
                    case SJVideoPlayerFilmEditingResultViewType_GIF: {
                        if ( self.recordCompleteExeBlock ) self.recordCompleteExeBlock(self, self.generateGIFView.maxDuration - self.generateGIFView.countDown);
                    }
                        break;
                    default:
                        break;
                }
            }];
        }];
    }];
}

#pragma mark -
- (void)setResource:(id<SJVideoPlayerFilmEditingControlViewResource>)resource {
    _resource = resource;
    [_GIFBtn setImage:self.resource.gifBtnImage forState:UIControlStateNormal];
    [_exportBtn setImage:self.resource.exportBtnImage forState:UIControlStateNormal];
    [_screenshotBtn setImage:self.resource.screenshotBtnImage forState:UIControlStateNormal];
}

- (void)setCurrentOperation:(SJVideoPlayerFilmEditingOperation)currentOperation {
    _currentOperation = currentOperation;
    if ( [self.delegate respondsToSelector:@selector(filmEditingControlView:userSelectedOperation:)] ) {
        [self.delegate filmEditingControlView:self userSelectedOperation:_currentOperation];
    }
}

- (void)setExportProgress:(float)exportProgress {
    _showResultView.exportProgress = exportProgress;
}

- (float)rexportProgress {
    return _showResultView.exportProgress;
}

- (void)setExportFailed:(BOOL)exportFailed {
    [_recordView stop];
    _showResultView.exportFailed = exportFailed;
    self.uploader.failed = exportFailed;
}

- (BOOL)exportFailed {
    return _showResultView.exportFailed;
}

- (void)setExportedFileURL:(NSURL *)exportedFileURL {
    _exportedFileURL = exportedFileURL;
    
    switch ( self.currentOperation ) {
        case SJVideoPlayerFilmEditingOperation_Screenshot: break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            _showResultView.videoURL = exportedFileURL;
            if ( [self.resultShare.delegate respondsToSelector:@selector(successfulExportedVideo:screenshot:)] ) {
                [self.resultShare.delegate successfulExportedVideo:exportedFileURL screenshot:self.showResultView.image];
            }
        }
            break;
        case SJVideoPlayerFilmEditingOperation_GIF: {
            if ( [self.resultShare.delegate respondsToSelector:@selector(successfulGenerateGIF:screenshot:)] ) {
                [self.resultShare.delegate successfulGenerateGIF:exportedFileURL screenshot:self.showResultView.image];
            }

        }
            break;
    }
}

- (UITapGestureRecognizer *)tapGR {
    if ( _tapGR ) return _tapGR;
    _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGR)];
    return _tapGR;
}

- (void)handleTapGR {
    CGPoint location = [_tapGR locationInView:self];
    if ( !CGRectContainsPoint(_showResultView.frame, location) &&
         !CGRectContainsPoint(_recordView.frame, location)) {
        if ( self.exit ) self.exit(self);
    }
}

- (void)setUploader:(SJFilmEditingResultUploader *)uploader {
    _uploader = uploader;
    _showResultView.uploader = uploader;
}

#pragma mark -

- (void)statusChanged:(SJVideoPlayerFilmEditingStatus)status {
    if ( [self.delegate respondsToSelector:@selector(filmEditingControlView:statusChanged:)] ) {
        [self.delegate filmEditingControlView:self statusChanged:status];
    }
}

#pragma mark -
- (void)_setupViews {
    [self addSubview:self.btnContainerView];
    [self addGestureRecognizer:self.tapGR]; // gesture
    
    [_btnContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(0);
        make.centerY.offset(0);
    }];
    
    [self _updateLayout];
    _btnContainerView.disappearType = SJDisappearType_All;
    _btnContainerView.disappearTransform = CGAffineTransformMakeTranslation(49, 0);
    _showResultView.disappearType = SJDisappearType_Alpha;

    [_btnContainerView disappear];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            [self->_btnContainerView appear];
        }];
    });
}

#pragma mark -
- (void)setDisableScreenshot:(BOOL)disableScreenshot {
    if ( disableScreenshot == _disableScreenshot ) return;
    _disableScreenshot = disableScreenshot;
    [self _updateLayout];
}

- (void)setDisableRecord:(BOOL)disableRecord {
    if ( disableRecord == _disableRecord ) return;
    _disableRecord = disableRecord;
    [self _updateLayout];
}

- (void)setDisableGIF:(BOOL)disableGIF {
    if ( disableGIF == _disableGIF ) return;
    _disableGIF = disableGIF;
    [self _updateLayout];
}

- (void)_updateLayout {
    
    if ( self.disableScreenshot ) {
        [_screenshotBtn removeFromSuperview];
    }
    else {
        [self.btnContainerView addSubview:self.screenshotBtn];
    }
    
    if ( self.disableRecord ) {
        [_exportBtn removeFromSuperview];
    }
    else {
        [self.btnContainerView addSubview:self.exportBtn];
    }
    
    if ( self.disableGIF ) {
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

- (SJVideoPlayerFilmEditingRecordView *)recordView {
    if ( _recordView ) return _recordView;
    _recordView = [[SJVideoPlayerFilmEditingRecordView alloc] initWithFrame:self.bounds];
    _recordView.backgroundColor = [UIColor clearColor];
    __weak typeof(self) _self = self;
    _recordView.clickedCancleBtnExeBlock = ^(SJVideoPlayerFilmEditingRecordView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.exit ) self.exit(self);
    };
    
    _recordView.clickedCompleteBtnExeBlock = ^(SJVideoPlayerFilmEditingRecordView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self finalize];
    };
    
    _recordView.statusChangedExeBlock = ^(__kindof UIView * _Nonnull view, SJVideoPlayerFilmEditingStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self statusChanged:status];
    };
    return _recordView;
}
#pragma mark -
- (UIButton *)GIFBtn {
    if ( _GIFBtn ) return _GIFBtn;
    _GIFBtn = [SJUIButtonFactory buttonWithTarget:self sel:@selector(clickedBtn:) tag:SJVideoPlayerFilmEditingOperation_GIF];
    return _GIFBtn;
}

- (SJVideoPlayerFilmEditingGenerateGIFView *)generateGIFView {
    if ( _generateGIFView ) return _generateGIFView;
    _generateGIFView = [[SJVideoPlayerFilmEditingGenerateGIFView alloc] initWithFrame:self.bounds];
    _generateGIFView.backgroundColor = [UIColor clearColor];
    __weak typeof(self) _self = self;
    _generateGIFView.clickedCancleBtnExeBlock = ^(SJVideoPlayerFilmEditingGenerateGIFView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.exit ) self.exit(self);
    };
    
    _generateGIFView.clickedCompleteBtnExeBlock = ^(SJVideoPlayerFilmEditingGenerateGIFView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self finalize];
    };
    
    _generateGIFView.statusChangedExeBlock = ^(__kindof UIView * _Nonnull view, SJVideoPlayerFilmEditingStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self statusChanged:status];
    };
    return _generateGIFView;
}

@end
