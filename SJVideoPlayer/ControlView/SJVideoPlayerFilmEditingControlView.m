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
#import <SJPrompt/SJPrompt.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJVideoPlayerFilmEditingResultUploadState) {
    SJVideoPlayerFilmEditingResultUploadStateUnknown,
    SJVideoPlayerFilmEditingResultUploadStateUploading,
    SJVideoPlayerFilmEditingResultUploadStateFailed,
    SJVideoPlayerFilmEditingResultUploadStateSuccessful,
    SJVideoPlayerFilmEditingResultUploadStateCancelled,
};

typedef SJVideoPlayerFilmEditingResultUploadState SJVideoPlayerFilmEditingResultExportState;

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

@interface SJVideoPlayerFilmEditingControlView ()

@property (nonatomic, strong, readonly) UIView *btnContainerView;
@property (nonatomic, strong, readonly) UIButton *screenshotBtn;
@property (nonatomic, strong, readonly) UIButton *exportBtn;
@property (nonatomic, strong, readonly) UIButton *GIFBtn;
@property (nonatomic, strong, nullable) SJVideoPlayerFilmEditingResultView *resultPresentView;
@property (nonatomic, strong, readonly) SJVideoPlayerFilmEditingRecordView *recordView;
@property (nonatomic, strong, readonly) SJVideoPlayerFilmEditingGenerateGIFView *generateGIFView;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGR;
@property (nonatomic, readwrite) SJVideoPlayerFilmEditingStatus status;
@property (nonatomic, strong, nullable) SJVideoPlayerFilmEditingResult *result;
@property (nonatomic, strong, readonly) SJPrompt *promptView;
@property (nonatomic) BOOL itemClickedInterval;

@end
NS_ASSUME_NONNULL_END

@implementation SJVideoPlayerFilmEditingControlView

@synthesize btnContainerView = _btnContainerView;
@synthesize screenshotBtn = _screenshotBtn;
@synthesize exportBtn = _exportBtn;
@synthesize GIFBtn = _GIFBtn;
@synthesize resultPresentView = _resultPresentView;
@synthesize recordView = _recordView;
@synthesize generateGIFView = _generateGIFView;
@synthesize tapGR = _tapGR;
@synthesize promptView = _promptView;

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
    if ( ![self.dataSource shouldStartWhenUserSelectedAnOperation:btn.tag] ) {
        return;
    }
    
    self.currentOperation = btn.tag;
    switch ( (SJVideoPlayerFilmEditingOperation)btn.tag ) {
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

    [_btnContainerView disappear];
}

- (void)setDataSource:(id<SJVideoPlayerFilmEditingControlViewDataSource>)dataSource {
    _dataSource = dataSource;
    [_btnContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset([dataSource operationContainerViewRightOffset]);
    }];
}
- (void)setResource:(id<SJVideoPlayerFilmEditingPromptResource>)resource {
    _resource = resource;
    [_GIFBtn setImage:resource.gifBtnImage forState:UIControlStateNormal];
    [_exportBtn setImage:resource.exportBtnImage forState:UIControlStateNormal];
    [_screenshotBtn setImage:resource.screenshotBtnImage forState:UIControlStateNormal];
}

- (void)setCurrentOperation:(SJVideoPlayerFilmEditingOperation)currentOperation {
    _currentOperation = currentOperation;
    if ( [self.delegate respondsToSelector:@selector(filmEditingControlView:userSelectedOperation:)] ) {
        [self.delegate filmEditingControlView:self userSelectedOperation:_currentOperation];
    }
}

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


#pragma mark -
- (SJVideoPlayerFilmEditingStatus)status {
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
            if ( _resultPresentView ) return SJVideoPlayerFilmEditingStatus_Finished;
            return SJVideoPlayerFilmEditingStatus_Unknown;
        }
            break;
    }
}

- (void)start {
    switch ( self.currentOperation ) {
        case SJVideoPlayerFilmEditingOperation_GIF: {
            self.generateGIFView.recordPromptText = self.resource.recordPromptText;
            _generateGIFView.waitingForRecordingPromptText = self.resource.waitingForRecordingPromptText;
            _generateGIFView.cancelBtnTitle = self.resource.cancelBtnTitle;
            _generateGIFView.recordEndBtnImage = self.resource.recordEndBtnImage;
            _generateGIFView.completeBtnRightOffset = self.dataSource.operationContainerViewRightOffset - 20;
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
            self.recordView.recordPromptText = self.resource.recordPromptText;
            _recordView.waitingForRecordingPromptText = self.resource.waitingForRecordingPromptText;
            _recordView.cancelBtnTitle = self.resource.cancelBtnTitle;
            _recordView.recordEndBtnImage = self.resource.recordEndBtnImage;
            _recordView.completeBtnRightOffset = self.dataSource.operationContainerViewRightOffset - 20;
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

- (void)cancel {
    switch ( self.currentOperation ) {
        case SJVideoPlayerFilmEditingOperation_GIF: {
            [self.dataSource.filmEditing cancelGenerateGIFOperation];
            [_generateGIFView cancel];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            [self.dataSource.filmEditing cancelExportOperation];
            [_recordView cancel];
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Screenshot: {
            if ( [self.delegate respondsToSelector:@selector(filmEditingControlView:statusChanged:)] ) {
                [self.delegate filmEditingControlView:self statusChanged:SJVideoPlayerFilmEditingStatus_Cancelled];
            }
        }
            break;
    }
    
    self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateCancelled;
    
    if ( self.result.uploadState == SJVideoPlayerFilmEditingResultUploadStateUploading ) {
        [self.uploader cancelUpload:self.result];
        self.result.uploadState = SJVideoPlayerFilmEditingStatus_Cancelled;
    }
}

- (void)finalize {
    
    SJVideoPlayerFilmEditingResultView *resultView = nil;
    self.result = [SJVideoPlayerFilmEditingResult new];
    self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateUploading;
    self.result.operation = self.currentOperation;
    void(^completion)(void);
    __weak typeof(self) _self = self;
    switch ( self.currentOperation ) {
        case SJVideoPlayerFilmEditingOperation_GIF: {
            [_generateGIFView finished];
            
            resultView = [self _presentResultViewWithType:SJVideoPlayerFilmEditingResultViewType_GIF];
            
            completion = ^ {
                NSTimeInterval currentTime = self.dataSource.filmEditing.currentTime;
                NSTimeInterval duration = self.generateGIFView.duration;
                [self.dataSource.filmEditing generateGIFWithBeginTime:currentTime - duration duration:duration progress:^(id<SJVideoPlayerFilmEditing>  _Nonnull filmEditing, float progress) {
                    resultView.exportProgress = progress;
                } completion:^(id<SJVideoPlayerFilmEditing>  _Nonnull filmEditing, UIImage * _Nonnull imageGIF, UIImage * _Nonnull thumbnailImage, NSURL * _Nonnull filePath) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    resultView.image = imageGIF;
                    
                    self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateSuccessful;
                    self.result.thumbnailImage = thumbnailImage;
                    self.result.image = imageGIF;
                    self.result.fileURL = filePath;
                    self.result.currentPlayAsset = self.dataSource.currentPalyAsset;
                    [resultView exportEndedWithStatus:YES];
                    [self upload:self.result resultView:resultView];
                    
                } failure:^(id<SJVideoPlayerFilmEditing>  _Nonnull filmEditing, NSError * _Nonnull error) {
                    [resultView exportEndedWithStatus:NO];
                    self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateFailed;
                }];
            };
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Export: {
            [_recordView finished];

            resultView = [self _presentResultViewWithType:SJVideoPlayerFilmEditingResultViewType_Video];
            
            completion = ^ {
                NSTimeInterval currentTime = self.dataSource.filmEditing.currentTime;
                [self.dataSource.filmEditing exportWithBeginTime:currentTime - self.recordView.duration endTime:currentTime presetName:nil progress:^(id<SJVideoPlayerFilmEditing>  _Nonnull filmEditing, float progress) {
                    resultView.exportProgress = progress;
                } completion:^(id<SJVideoPlayerFilmEditing>  _Nonnull filmEditing, NSURL * _Nonnull fileURL, UIImage * _Nonnull thumbnailImage) {
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    resultView.videoURL = fileURL;
                    
                    self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateSuccessful;
                    self.result.thumbnailImage = thumbnailImage;
                    self.result.fileURL = fileURL;
                    self.result.currentPlayAsset = self.dataSource.currentPalyAsset;
                    [resultView exportEndedWithStatus:YES];
                    [self upload:self.result resultView:resultView];
                    
                } failure:^(id<SJVideoPlayerFilmEditing>  _Nonnull filmEditing, NSError * _Nonnull error) {
                    [resultView exportEndedWithStatus:NO];
                    self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateFailed;
                }];
            };
        }
            break;
        case SJVideoPlayerFilmEditingOperation_Screenshot: {
            if ( [self.delegate respondsToSelector:@selector(filmEditingControlView:statusChanged:)] ) {
                [self.delegate filmEditingControlView:self statusChanged:SJVideoPlayerFilmEditingStatus_Finished];
            }
            resultView = [self _presentResultViewWithType:SJVideoPlayerFilmEditingResultViewType_Screenshot];
            
            completion = ^ {
                self.result.image = self.result.thumbnailImage = resultView.image;
                self.result.exportState = SJVideoPlayerFilmEditingResultUploadStateSuccessful;
                [resultView exportEndedWithStatus:YES];
                [self upload:self.result resultView:resultView];
            };
        }
            break;
    }
    
    resultView.image = self.dataSource.playerScreenshot;
    
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

- (void)upload:(SJVideoPlayerFilmEditingResult *)result  resultView:(SJVideoPlayerFilmEditingResultView *)resultView {
    if ( !self.dataSource.resultNeedUpload ) return;
    result.uploadState = SJVideoPlayerFilmEditingResultUploadStateUploading;
    __weak typeof(self) _self = self;
    [self.uploader upload:result progress:^(float progress) {
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

- (SJVideoPlayerFilmEditingResultView *)_presentResultViewWithType:(SJVideoPlayerFilmEditingResultViewType)type {
    [_recordView removeFromSuperview];
    [_generateGIFView removeFromSuperview];
    
    _resultPresentView = [[SJVideoPlayerFilmEditingResultView alloc] initWithType:type];
    _resultPresentView.frame = self.bounds;
    _resultPresentView.shareItems = self.dataSource.resultShareItems;
    _resultPresentView.resource = self.resource;
    
    __weak typeof(self) _self = self;
    _resultPresentView.clickedCancelBtnExeBlock = ^(SJVideoPlayerFilmEditingResultView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self cancel];
    };
    
    
    NSTimeInterval promptDuration = 2;
    _resultPresentView.clickedItemExeBlock = ^(SJVideoPlayerFilmEditingResultView * _Nonnull view, SJFilmEditingResultShareItem *  _Nonnull item) {
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
        
        if ( ![self.delegate respondsToSelector:@selector(filmEditingControlView:userClickedResultShareItem:result:)] ) return;
        
        
        // export state
        switch ( self.result.exportState ) {
            case SJVideoPlayerFilmEditingResultUploadStateSuccessful: break;

            case SJVideoPlayerFilmEditingResultUploadStateUnknown:
            case SJVideoPlayerFilmEditingResultUploadStateCancelled: return;
            case SJVideoPlayerFilmEditingResultUploadStateFailed: {
                [self.promptView showTitle:self.resource.operationFailedPrompt duration:promptDuration];
            }
                return;
                
            case SJVideoPlayerFilmEditingResultUploadStateUploading: {
                [self.promptView showTitle:self.resource.exportingPrompt duration:promptDuration];
            }
                return;
        }
        
        
        if ( !self.dataSource.resultNeedUpload || item.canAlsoClickedWhenUploading ) {
            [self.delegate filmEditingControlView:self userClickedResultShareItem:item result:self.result];
            return;
        }
        
        
        // upload sate
        switch ( self.result.uploadState ) {
            case SJVideoPlayerFilmEditingResultUploadStateUnknown: break;
            case SJVideoPlayerFilmEditingResultUploadStateCancelled: break;
            case SJVideoPlayerFilmEditingResultUploadStateFailed: {
                [self.promptView showTitle:self.resource.operationFailedPrompt duration:promptDuration];
            }
                break;
            case SJVideoPlayerFilmEditingResultUploadStateSuccessful: {
                [self.delegate filmEditingControlView:self userClickedResultShareItem:item result:self.result];
            }
                break;
            case SJVideoPlayerFilmEditingResultUploadStateUploading: {
                [self.promptView showTitle:self.resource.uploadingPrompt duration:promptDuration];
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
         !CGRectContainsPoint(_recordView.frame, location)) {
        if ( [self.delegate respondsToSelector:@selector(userTappedBlankAreaAtFilmEditingControlView:)] ) {
            [self.delegate userTappedBlankAreaAtFilmEditingControlView:self];
        }
    }
}

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
    _resultPresentView.disappearType = SJDisappearType_Alpha;

    [_btnContainerView disappear];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            [self->_btnContainerView appear];
        }];
    });
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
        [view cancel];
    };
    
    _recordView.statusChangedExeBlock = ^(__kindof UIView * _Nonnull view, SJVideoPlayerFilmEditingStatus status) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self statusChanged:status];
    };
    
    _recordView.clickedCompleteBtnExeBlock = ^(SJVideoPlayerFilmEditingRecordView * _Nonnull view) {
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

- (SJVideoPlayerFilmEditingGenerateGIFView *)generateGIFView {
    if ( _generateGIFView ) return _generateGIFView;
    _generateGIFView = [[SJVideoPlayerFilmEditingGenerateGIFView alloc] initWithFrame:self.bounds];
    _generateGIFView.backgroundColor = [UIColor clearColor];
    __weak typeof(self) _self = self;
    _generateGIFView.clickedCancleBtnExeBlock = ^(SJVideoPlayerFilmEditingGenerateGIFView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [view cancel];
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

#pragma mark -

- (SJPrompt *)promptView {
    if ( _promptView ) return _promptView;
    _promptView = [SJPrompt promptWithPresentView:self];
    return _promptView;
}

@end



@implementation SJVideoPlayerFilmEditingResult
- (NSData * __nullable)data {
    if ( self.fileURL ) return [NSData dataWithContentsOfURL:self.fileURL];
    else if ( self.image ) return UIImagePNGRepresentation(self.image);
    return nil;
}
@end
