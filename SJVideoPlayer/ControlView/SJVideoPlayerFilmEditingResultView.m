//
//  SJVideoPlayerFilmEditingResultView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerFilmEditingResultView.h"
#import <Masonry/Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import <SJUIFactory/UIView+SJUIFactory.h>
#import "UIView+SJVideoPlayerSetting.h"
#import "UIView+SJControlAdd.h"
#import <SJAttributesFactory/SJAttributeWorker.h>
#import "SJFilmEditingResultShareItem.h"
#import <SJObserverHelper/NSObject+SJObserverHelper.h>

@interface SJVideoPlayerFilmEditingResultView ()

@property (nonatomic, strong, readonly) UIButton *cancelBtn;
@property (nonatomic, strong, readonly) UIView *fullMaskView;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIView *itemsContainerView;

@property (nonatomic, strong, readonly) UILabel *progressLabel;
@property (nonatomic, strong, readonly) UIView *uploadProgressView;

@property (nonatomic, weak, readwrite) SJFilmEditingResultUploader *uploader;

@end

@implementation SJVideoPlayerFilmEditingResultView

@synthesize cancelBtn = _cancelBtn;
@synthesize imageView = _imageView;
@synthesize fullMaskView = _fullMaskView;
@synthesize itemsContainerView = _itemsContainerView;
@synthesize progressLabel = _progressLabel;
@synthesize uploadProgressView = _uploadProgressView;

- (instancetype)initWithType:(SJVideoPlayerFilmEditingResultViewType)type {
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    _type = type;
    [self _setupViews];
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"SJVideoPlayerLog: %zd - %s", __LINE__, __func__);
#endif
}

- (void)showResultWithCompletion:(void (^)(void))block {
    [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.equalTo(self.mas_centerY).multipliedBy(0.82);
        make.width.equalTo(self).multipliedBy(0.4);
        make.height.equalTo(_imageView.mas_width).multipliedBy(9 / 16.0);
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
        self.itemsContainerView.alpha = 1;
    } completion:^(BOOL finished) {
        if ( block ) block();
        if ( _type == SJVideoPlayerFilmEditingResultViewType_Screenshot && [self.resultShare.delegate respondsToSelector:@selector(successfulScreenshot:)] ) {
            self.uploader = [self.resultShare.delegate successfulScreenshot:self.image];
        }
    }];
}

- (void)clickedBtn:(UIButton *)btn {
    if ( btn == self.cancelBtn ) {
        if ( _clickedCancleBtn ) _clickedCancleBtn(self);
    }
}

- (void)clickedItemBtn:(UIButton *)btn {
    SJFilmEditingResultShareItem *item = self.resultShare.filmEditingResultShareItems[btn.tag];
    if ( [self.resultShare.delegate respondsToSelector:@selector(clickedItem:screenshot:recordedVideoFileURL:)] ) {
        switch ( _type ) {
            case SJVideoPlayerFilmEditingResultViewType_Screenshot: {
                [self.resultShare.delegate clickedItem:item screenshot:self.image recordedVideoFileURL:nil];
            }
                break;
            case SJVideoPlayerFilmEditingResultViewType_Video: {
                [self.resultShare.delegate clickedItem:item screenshot:nil recordedVideoFileURL:self.exportedVideoURL];
            }
                break;
        }
    }
}

#pragma mark -

- (void)setImage:(UIImage *)image {
    _image = image;
    self.layer.contents = (id)image.CGImage;
    self.imageView.image = image;
}

- (void)setExportedVideoURL:(NSURL *)exportedVideoURL {
    _exportedVideoURL = exportedVideoURL;
    if ( [self.resultShare.delegate respondsToSelector:@selector(successfulExportedVideo:screenshot:)] ) {
        self.uploader = [self.resultShare.delegate successfulExportedVideo:exportedVideoURL screenshot:self.image];
    }
}

- (void)setRecordedVideoExportProgress:(float)recordedVideoExportProgress {
    _recordedVideoExportProgress = recordedVideoExportProgress;
    _progressLabel.text = [NSString stringWithFormat:@"截取中: %.0f%%", recordedVideoExportProgress * 100];
}

- (void)setExportFailed:(BOOL)exportFailed {
    _exportFailed = exportFailed;
    _progressLabel.text = @"操作失败";
}

- (void)setCancelBtnTitle:(NSString *)cancelBtnTitle {
    _cancelBtnTitle = cancelBtnTitle;
    [_cancelBtn setTitle:cancelBtnTitle forState:UIControlStateNormal];
}

- (void)setUploader:(SJFilmEditingResultUploader *)uploader {
    _uploader = uploader;
    [uploader sj_addObserver:self forKeyPath:@"progress"];
    [uploader sj_addObserver:self forKeyPath:@"uploaded"];
    [uploader sj_addObserver:self forKeyPath:@"failed"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( [keyPath isEqualToString:@"progress"] ) {
            float progress = self.uploader.progress;
            _progressLabel.text = [NSString stringWithFormat:@"上传中: %.0f%%", progress * 100];
            [_uploadProgressView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.trailing.offset(0);
                make.width.equalTo(_imageView).multipliedBy(1 - progress);
            }];
        }
        else if ( [keyPath isEqualToString:@"uploaded"] ) {
            [UIView animateWithDuration:0.25 animations:^{
               self.progressLabel.alpha = 0.001;
            }];
        }
        else if ( [keyPath isEqualToString:@"failed"] ) {
            self.progressLabel.text = @"操作失败";
        }
    });
}

- (void)setResultShare:(SJFilmEditingResultShare *)resultShare {
    _resultShare = resultShare;
    [resultShare.filmEditingResultShareItems enumerateObjectsUsingBlock:^(SJFilmEditingResultShareItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
                make.leading.equalTo(_itemsContainerView);
                make.top.bottom.offset(0);
            }];
        }
        else if ( idx != (int)resultShare.filmEditingResultShareItems.count - 1 ) {
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

#pragma mark -

- (void)_setupViews {
    [self addSubview:self.fullMaskView];
    [self addSubview:self.cancelBtn];
    [self addSubview:self.imageView];
    [self addSubview:self.itemsContainerView];
    [_imageView addSubview:self.uploadProgressView];
    [_imageView addSubview:self.progressLabel];

    self.itemsContainerView.alpha = 0.001;
    self.contentMode = UIViewContentModeScaleAspectFit;

    [_fullMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(12);
        make.top.offset(12);
        make.height.offset(26);
        make.width.equalTo(_cancelBtn.mas_height).multipliedBy(2.8);
    }];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_itemsContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(_imageView.mas_bottom);
        make.bottom.equalTo(self);
    }];
    
    [_uploadProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
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
    _cancelBtn.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    return _cancelBtn;
}

- (UIImageView *)imageView {
    if ( _imageView ) return _imageView;
    _imageView = [SJUIImageViewFactory imageViewWithViewMode:UIViewContentModeScaleAspectFit];
    return _imageView;
}

- (UILabel *)progressLabel {
    if ( _progressLabel ) return _progressLabel;
    _progressLabel = [SJUILabelFactory labelWithFont:[UIFont systemFontOfSize:11] textColor:[UIColor whiteColor]];
    return _progressLabel;
}

- (UIView *)uploadProgressView {
    if ( _uploadProgressView ) return _uploadProgressView;
    _uploadProgressView = [SJUIViewFactory viewWithBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    return _uploadProgressView;
}
@end
