//
//  SJFilmEditingResultPresentView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJFilmEditingResultPresentView.h"
#import "SJFilmEditingResultShareItem.h"
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
#if __has_include(<SJUIFactory/UIView+SJUIFactory.h>)
#import <SJUIFactory/UIView+SJUIFactory.h>
#else
#import "UIView+SJUIFactory.h"
#endif
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#else
#import "SJBaseVideoPlayer.h"
#endif
#if __has_include(<SJAttributesFactory/SJAttributeWorker.h>)
#import <SJAttributesFactory/SJAttributeWorker.h>
#else
#import "SJAttributeWorker.h"
#endif
#if __has_include(<SJBaseVideoPlayer/SJVideoPlayerRegistrar.h>)
#import <SJBaseVideoPlayer/SJVideoPlayerRegistrar.h>
#else
#import "SJVideoPlayerRegistrar.h"
#endif

@interface SJFilmEditingResultPresentView ()

@property (nonatomic, strong, readonly) UIButton *cancelBtn;
@property (nonatomic, strong, readonly) UIView *fullMaskView;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) SJBaseVideoPlayer *videoPlayer;
@property (nonatomic, strong, readonly) UIView *itemsContainerView;

@property (nonatomic, strong, readonly) UILabel *progressLabel;
@property (nonatomic, strong, readonly) SJVideoPlayerRegistrar *registrar;

@end

@implementation SJFilmEditingResultPresentView

@synthesize cancelBtn = _cancelBtn;
@synthesize imageView = _imageView;
@synthesize fullMaskView = _fullMaskView;
@synthesize itemsContainerView = _itemsContainerView;
@synthesize videoPlayer = _videoPlayer;
@synthesize progressLabel = _progressLabel;
@synthesize registrar = _registrar;

- (instancetype)initWithType:(SJFilmEditingResultPresentViewType)type {
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    _type = type;
    [self _setupViews];
    [self registrar];
    return self;
}

#ifdef SJ_MAC
- (void)dealloc {
    NSLog(@"SJVideoPlayerLog: %d - %s", (int)__LINE__, __func__);
}
#endif

- (void)presentResultViewWithCompletion:(void (^)(void))block {
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.equalTo(self.mas_centerY).multipliedBy(0.82);
        make.width.equalTo(self).multipliedBy(0.4);
        make.height.equalTo(self.imageView.mas_width).multipliedBy(9 / 16.0);
    }];
    
    [UIView animateWithDuration:0.6 animations:^{
        [self layoutIfNeeded];
        self.itemsContainerView.alpha = 1;
    } completion:^(BOOL finished) {
        if ( block ) block();
    }];
}

- (void)clickedBtn:(UIButton *)btn {
    if ( btn == self.cancelBtn ) {
        if ( _clickedCancelBtnExeBlock ) _clickedCancelBtnExeBlock(self);        
    }
}

- (void)clickedItemBtn:(UIButton *)btn {
    if ( _clickedItemExeBlock ) _clickedItemExeBlock(self, self.shareItems[btn.tag]);
}


#pragma mark -

- (void)setShareItems:(NSArray<SJFilmEditingResultShareItem *> *)shareItems {
    _shareItems = shareItems;
    [shareItems enumerateObjectsUsingBlock:^(SJFilmEditingResultShareItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [SJUIButtonFactory buttonWithAttributeTitle:sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
            make.insertImage(obj.image, 0, CGPointZero, CGSizeMake(40, 40));
            make.insertText(@"\n", -1);
            make.insertText(obj.title, -1);
            make.lineSpacing(8);
            make.alignment(NSTextAlignmentCenter);
            make.font([UIFont systemFontOfSize:10]).textColor([UIColor whiteColor]);
        }) backgroundColor:[UIColor clearColor] target:self sel:@selector(clickedItemBtn:) tag:idx];
        [self.itemsContainerView addSubview:btn];
        if ( idx == 0 ) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self->_itemsContainerView);
                make.top.bottom.offset(0);
            }];
        }
        else if ( idx != (int)shareItems.count - 1 ) {
            UIButton *beforeBtn = self.itemsContainerView.subviews[(int)idx - 1];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(beforeBtn.mas_trailing).offset(20);
                make.top.bottom.equalTo(beforeBtn);
            }];
        }
        else {
            UIButton *beforeBtn = self.itemsContainerView.subviews[(int)idx - 1];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(beforeBtn.mas_trailing).offset(20);
                make.top.bottom.equalTo(beforeBtn);
                make.trailing.offset(0);
            }];
        }
    }];
}

- (void)setCancelBtnTitle:(NSString *)cancelBtnTitle {
    [_cancelBtn setTitle:cancelBtnTitle forState:UIControlStateNormal];
}

#pragma mark -
- (void)setImage:(UIImage *)image {
    _image = image;
    self.layer.contents = (id)image.CGImage;
    self.imageView.image = image;
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    [self.videoPlayer playWithURL:videoURL];
}

- (void)setExportProgress:(float)exportProgress {
    _exportProgress = exportProgress;
    [self _updateProgressText:[NSString stringWithFormat:@"%@: %.0f%%", self.exportingPrompt, exportProgress * 100]];
}

- (void)setUploadProgress:(float)uploadProgress {
    _uploadProgress = uploadProgress;
    [self _updateProgressText:[NSString stringWithFormat:@"%@: %.0f%%", self.uploadingPrompt, uploadProgress * 100]];
}

- (void)exportEndedWithStatus:(BOOL)exportStatus {
    if ( !exportStatus ) {
        [self _updateProgressText:self.operationFailedPrompt];
    }
    else {
        [self _updateProgressText:self.exportSuccessfullyPrompt];
    }
}

- (void)uploadEndedWithStatus:(BOOL)uploadStatus {
    if ( uploadStatus ) {
        [self _updateProgressText:self.uploadSuccessfullyPrompt];
    }
    else {
        [self _updateProgressText:self.operationFailedPrompt];
    }
}

- (void)_updateProgressText:(NSString *)progressText {
    _progressLabel.attributedText = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        make.font([UIFont systemFontOfSize:12]).textColor([UIColor whiteColor]);
        make.append(progressText);
        make.shadow(CGSizeMake(0.5, 0.5), 1, [UIColor blackColor]);
    });
}

#pragma mark -

- (void)_setupViews {
    [self addSubview:self.fullMaskView];
    [self addSubview:self.cancelBtn];
    [self addSubview:self.imageView];
    [self addSubview:self.itemsContainerView];
    if ( self.type == SJFilmEditingResultPresentViewType_Video ) [self.imageView addSubview:self.videoPlayer.view];
    [self.imageView addSubview:self.progressLabel];

    self.itemsContainerView.alpha = 0.001;
    self.contentMode = UIViewContentModeScaleAspectFit;

    [_fullMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(12);
        make.top.offset(25);
        make.height.offset(30);
        make.width.equalTo(self->_cancelBtn.mas_height).multipliedBy(2.8);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    if ( self.type == SJFilmEditingResultPresentViewType_Video ) {
        [self.videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.imageView);
        }];
    }
    
    [_itemsContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(self.imageView.mas_bottom);
        make.bottom.equalTo(self);
    }];

    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.trailing.offset(-8);
    }];
}

- (UIView *)fullMaskView {
    if  ( _fullMaskView ) return _fullMaskView;
    _fullMaskView = [SJUIViewFactory viewWithBackgroundColor:[UIColor colorWithWhite:0 alpha:0.618]];
    return _fullMaskView;
}

- (UIView *)itemsContainerView {
    if ( _itemsContainerView ) return _itemsContainerView;
    _itemsContainerView = [SJUIViewFactory viewWithBackgroundColor:[UIColor clearColor]];
    return _itemsContainerView;
}

- (UIButton *)cancelBtn {
    if ( _cancelBtn ) return _cancelBtn;
    _cancelBtn = [SJShapeButtonFactory buttonWithCornerRadius:15 title:nil titleColor:[UIColor whiteColor] target:self sel:@selector(clickedBtn:)];
    _cancelBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    return _cancelBtn;
}

- (UIImageView *)imageView {
    if ( _imageView ) return _imageView;
    _imageView = [SJUIImageViewFactory imageViewWithViewMode:UIViewContentModeScaleAspectFit];
    _imageView.backgroundColor = [UIColor blackColor];
    return _imageView;
}

- (UILabel *)progressLabel {
    if ( _progressLabel ) return _progressLabel;
    _progressLabel = [SJUILabelFactory attributeLabel];
    return _progressLabel;
}

- (SJBaseVideoPlayer *)videoPlayer {
    if ( _videoPlayer ) return _videoPlayer;
    _videoPlayer = [SJBaseVideoPlayer new];
    _videoPlayer.view.backgroundColor = [UIColor clearColor];
    _videoPlayer.view.subviews.firstObject.backgroundColor = [UIColor clearColor];
    _videoPlayer.disableAutoRotation = YES;
    _videoPlayer.disableGestureTypes = SJDisablePlayerGestureTypes_All;
    _videoPlayer.playDidToEndExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        [player seekToTime:0 completionHandler:nil];
    };
    return _videoPlayer;
}

- (SJVideoPlayerRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [[SJVideoPlayerRegistrar alloc] init];
    __weak typeof(self) _self = self;
    _registrar.didBecomeActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.videoPlayer play];
    };
    
    _registrar.willResignActive = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.videoPlayer pause];
    };
    
    _registrar.newDeviceAvailable = ^(SJVideoPlayerRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.videoPlayer play];
    };
    return _registrar;
}
@end
