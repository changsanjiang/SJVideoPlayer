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

@interface SJVideoPlayerFilmEditingControlView ()

@property (nonatomic, strong, readonly) UIButton *screenshotBtn;
@property (nonatomic, strong, readonly) UIButton *exportBtn;
@property (nonatomic, strong, readonly) SJVideoPlayerFilmEditingResultView *resultView;
@property (nonatomic, strong, readonly) SJVideoPlayerFilmEditingRecordView *recordView;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGR;

@end

@implementation SJVideoPlayerFilmEditingControlView

@synthesize screenshotBtn = _screenshotBtn;
@synthesize exportBtn = _exportBtn;
@synthesize resultView = _resultView;
@synthesize recordView = _recordView;
@synthesize tapGR = _tapGR;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"SJVideoPlayerLog: %zd - %s", __LINE__, __func__);
#endif
}

- (void)clickedBtn:(UIButton *)btn {
    switch ( btn.tag ) {
        case SJVideoPlayerFilmEditingViewTag_Screenshot: {
            _isRecording = NO;
            [self _result];
        }
            break;
        case SJVideoPlayerFilmEditingViewTag_Export: {
            _isRecording = YES;
            self.recordView.tipsText = _recordTipsText;
            _recordView.waitingForRecordingTipsText = _waitingForRecordingTipsText;
            _recordView.cancelBtnTitle = _cancelBtnTitle;
            _recordView.recordEndBtnImage = _recordEndBtnImage;
            _recordView.alpha = 0.001;
            [self addSubview:_recordView];
            
            [UIView animateWithDuration:0.25 animations:^{
                _recordView.alpha = 1;
            } completion:^(BOOL finished) {
                [_recordView startRecord];
            }];
        }
            break;
        default:
            break;
    }
    
    [_exportBtn disappear];
    [_screenshotBtn disappear];
}

- (void)_result {
    self.resultView.cancelBtnTitle = _cancelBtnTitle;
    _resultView.filmEditingResultShareItems = _filmEditingResultShareItems;
    _resultView.alpha = 0.001;
    [self addSubview:_resultView];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundColor = [UIColor clearColor];
            _resultView.alpha = 1;
        } completion:^(BOOL finished) {
            [_resultView startAnimation];
        }];
    }];
    _resultView.image = self.getVideoScreenshot(self);
}

- (void)setExportBtnImage:(UIImage *)exportBtnImage {
    [self.exportBtn setImage:exportBtnImage forState:UIControlStateNormal];
}

- (void)setScreenshotBtnImage:(UIImage *)screenshotBtnImage {
    [self.screenshotBtn setImage:screenshotBtnImage forState:UIControlStateNormal];
}

- (void)setRecordedVideoExportProgress:(float)recordedVideoExportProgress {
    self.resultView.recordedVideoExportProgress = recordedVideoExportProgress;
}

- (float)recordedVideoExportProgress {
    return _resultView.recordedVideoExportProgress;
}

- (UITapGestureRecognizer *)tapGR {
    if ( _tapGR ) return _tapGR;
    _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGR)];
    return _tapGR;
}

- (void)handleTapGR {
    CGPoint location = [_tapGR locationInView:self];
    if ( !CGRectContainsPoint(_resultView.frame, location) &&
         !CGRectContainsPoint(_recordView.frame, location)) {
        if ( self.exit ) self.exit(self);
    }
}

- (void)stopRecording {
    [self _result];
}

#pragma mark -
- (void)_setupViews {
    [self addSubview:self.screenshotBtn];
    [self addSubview:self.exportBtn];
    [self addGestureRecognizer:self.tapGR]; // gesture
    
    [_screenshotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(0);
        make.size.offset(49);
        make.bottom.equalTo(self.mas_centerY);
    }];
    
    [_exportBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(0);
        make.size.equalTo(_screenshotBtn);
        make.top.equalTo(self.mas_centerY);
    }];
    
    _screenshotBtn.disappearType = SJDisappearType_Transform;
    _screenshotBtn.disappearTransform = CGAffineTransformMakeTranslation(49, 0);
    _exportBtn.disappearType = SJDisappearType_Transform;
    _exportBtn.disappearTransform = CGAffineTransformMakeTranslation(49, 0);
    _resultView.disappearType = SJDisappearType_Alpha;
    
    [_screenshotBtn disappear];
    [_exportBtn disappear];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            [_screenshotBtn appear];
            [_exportBtn appear];
        }];
    });
}

- (UIButton *)screenshotBtn {
    if ( _screenshotBtn ) return _screenshotBtn;
    _screenshotBtn = [SJUIButtonFactory buttonWithTarget:self sel:@selector(clickedBtn:) tag:SJVideoPlayerFilmEditingViewTag_Screenshot];
    return _screenshotBtn;
}

- (UIButton *)exportBtn {
    if ( _exportBtn ) return _exportBtn;
    _exportBtn = [SJUIButtonFactory buttonWithTarget:self sel:@selector(clickedBtn:) tag:SJVideoPlayerFilmEditingViewTag_Export];
    return _exportBtn;
}

- (SJVideoPlayerFilmEditingResultView *)resultView {
    if ( _resultView ) return _resultView;
    _resultView = [[SJVideoPlayerFilmEditingResultView alloc] initWithFrame:self.bounds];
    __weak typeof(self) _self = self;
    _resultView.clickedCancleBtn = ^(SJVideoPlayerFilmEditingResultView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.exit ) self.exit(self);
    };
    return _resultView;
}

- (SJVideoPlayerFilmEditingRecordView *)recordView {
    if ( _recordView ) return _recordView;
    _recordView = [[SJVideoPlayerFilmEditingRecordView alloc] initWithFrame:self.bounds];
    _recordView.backgroundColor = [UIColor clearColor];
    __weak typeof(self) _self = self;
    _recordView.exit = ^(SJVideoPlayerFilmEditingRecordView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( self.exit ) self.exit(self);
    };
    
    _recordView.completeExeBlock = ^(SJVideoPlayerFilmEditingRecordView * _Nonnull view, short duration) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self stopRecording];
    };
    return _recordView;
}
@end
