//
//  SJFilmEditingRecordingView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJFilmEditingRecordingView.h"
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
#import "SJProgressSlider.h"


@interface SJFilmEditingRecordingView ()

@property (nonatomic, strong, readonly) UIButton *cancelBtn;
@property (nonatomic, strong, readonly) UIButton *completeBtn;
@property (nonatomic, strong, readonly) UIView *progressContainerView;
@property (nonatomic, strong, readonly) UILabel *progressLabel;
@property (nonatomic, strong, readonly) UILabel *promptLabel;
@property (nonatomic, strong, readonly) SJProgressSlider *progressSlider;
@property (nonatomic, strong, readonly) NSTimer *countDownTimer;

@property (nonatomic, readwrite) short duration; // sec.
@property (nonatomic, readonly) short time; // 60 * 2, sec.

@property (nonatomic) SJFilmEditingStatus status;
@end

@implementation SJFilmEditingRecordingView
@synthesize progressContainerView = _progressContainerView;
@synthesize progressLabel = _progressLabel;
@synthesize promptLabel = _promptLabel;
@synthesize progressSlider = _progressSlider;
@synthesize cancelBtn = _cancelBtn;
@synthesize completeBtn = _completeBtn;
@synthesize countDownTimer = _countDownTimer;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    _time = 60 * 2;

    [self _setupViews];
    
    return self;
}

#ifdef SJ_MAC
- (void)dealloc {
    NSLog(@"SJVideoPlayerLog: %d - %s", (int)__LINE__, __func__);
}
#endif

- (void)start {
    _duration = 0;
    self.promptLabel.text = self.waitingForRecordingPromptText;
    [[NSRunLoop currentRunLoop] addTimer:self.countDownTimer forMode:NSRunLoopCommonModes];
    [self.countDownTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    self.status = SJFilmEditingStatus_Recording;
}

- (void)pause {
    [self _clearTimer];
    self.status = SJFilmEditingStatus_Paused;
}

- (void)resume {
    NSString *text = _promptLabel.text;
    NSTimeInterval duration = _duration;
    [self start];
    _duration = duration;
    if ( _promptLabel.text != text ) _promptLabel.text = text;
}

- (void)cancel {
    [self _clearTimer];
    self.status = SJFilmEditingStatus_Cancelled;
}

- (void)finished {
    [self _clearTimer];
    self.status = SJFilmEditingStatus_Finished;
}

- (void)setStatus:(SJFilmEditingStatus)status {
    if ( status == _status ) return;
    _status = status;
    if ( _statusChangedExeBlock ) _statusChangedExeBlock(self, status);
}

- (void)clickedBtn:(UIButton *)btn {
    if ( btn == self.cancelBtn ) {
        if ( _clickedCancleBtnExeBlock ) _clickedCancleBtnExeBlock(self);
    }
    else if ( btn == self.completeBtn ) {
        if ( _clickedCompleteBtnExeBlock ) _clickedCompleteBtnExeBlock(self);
    }
}

- (void)_clearTimer {
    [_countDownTimer invalidate];
    _countDownTimer = nil;
}

- (void)countDownRefresh:(NSTimer *)timer {
    if ( _duration == _time ) {
        [self finished];
        if ( self.clickedCompleteBtnExeBlock ) self.clickedCompleteBtnExeBlock(self);
        return;
    }
    ++_duration;
    
    int seconds, minutes;
    minutes = (_duration) / 60;
    seconds = _duration % 60;
    _progressLabel.text = [NSString stringWithFormat:@"%02d:%02d/02:00", minutes, seconds];
    _progressSlider.value = _duration * 1.0f / _time;
    
    if ( _duration == 3 ) {
        self.promptLabel.text = self.finishRecordingPromptText;
        [UIView animateWithDuration:0.3 animations:^{
            self->_completeBtn.alpha = 1;
        }];
    }
}

- (void)setFinishRecordingBtnImage:(UIImage *)finishRecordingBtnImage {
    _finishRecordingBtnImage = finishRecordingBtnImage;
    [_completeBtn setImage:finishRecordingBtnImage forState:UIControlStateNormal];
}

- (void)setCancelBtnTitle:(NSString *)cancelBtnTitle {
    _cancelBtnTitle = cancelBtnTitle;
    [_cancelBtn setTitle:cancelBtnTitle forState:UIControlStateNormal];
}

- (void)setWaitingForRecordingPromptText:(NSString *)waitingForRecordingPromptText {
    _waitingForRecordingPromptText = waitingForRecordingPromptText;
    self.promptLabel.text = waitingForRecordingPromptText;
}

- (void)setFinishRecordingPromptText:(NSString *)finishRecordingPromptText {
    _finishRecordingPromptText = finishRecordingPromptText;
    self.promptLabel.text = finishRecordingPromptText;
    [self.promptLabel sizeToFit];
    [self.progressLabel sizeToFit];
    CGFloat width = 24 * 2 + self.promptLabel.csj_w + self.progressLabel.csj_w + 20;
    [self.progressContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.offset(width);
    }];
    self.promptLabel.text = nil;
}

#pragma mark -

- (void)_setupViews {
    [self addSubview:self.cancelBtn];
    [self addSubview:self.completeBtn];
    [self addSubview:self.progressContainerView];
    [self.progressContainerView addSubview:self.progressLabel];
    [self.progressContainerView addSubview:self.promptLabel];
    [self.progressContainerView addSubview:self.progressSlider];
    
    self.completeBtn.alpha = 0.001;
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(12);
        make.top.offset(25);
        make.height.offset(30);
        make.width.equalTo(self->_cancelBtn.mas_height).multipliedBy(2.8);
    }];
    
    CGFloat offset = (SJScreen_Max() - 375*16/9.0) *0.5 + 20;
    [_completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(SJ_is_iPhoneX() ? -offset :0);
        make.size.offset(49);
        make.centerY.offset(0);
    }];
    
    [_progressContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-34);
        make.height.offset(40);
        make.centerX.offset(0);
    }];
    
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(24);
        make.centerY.equalTo(self->_progressLabel.superview).multipliedBy(0.618);
    }];
    
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(-24);
        make.centerY.equalTo(self->_progressLabel);
    }];
    
    [_progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(24);
        make.trailing.offset(-24);
        make.centerY.equalTo(self->_progressSlider.superview).multipliedBy(1.382);
    }];
}

- (UIButton *)cancelBtn {
    if ( _cancelBtn ) return _cancelBtn;
    _cancelBtn = [SJShapeButtonFactory buttonWithCornerRadius:15 title:nil titleColor:[UIColor whiteColor] target:self sel:@selector(clickedBtn:)];
    _cancelBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.618];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    return _cancelBtn;
}

- (UIButton *)completeBtn {
    if ( _completeBtn ) return _completeBtn;
    _completeBtn = [SJUIButtonFactory buttonWithImageName:@"" target:self sel:@selector(clickedBtn:) tag:0];
    return _completeBtn;
}

- (UIView *)progressContainerView {
    if ( _progressContainerView ) return _progressContainerView;
    _progressContainerView = [SJShapeViewFactory viewWithCornerRadius:40 backgroundColor:[UIColor colorWithWhite:0 alpha:0.618]];
    return _progressContainerView;
}
- (UILabel *)progressLabel {
    if ( _progressLabel ) return _progressLabel;
    _progressLabel = [SJUILabelFactory labelWithText:@"00:00/02:00" textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:11]];
    return _progressLabel;
}
- (UILabel *)promptLabel {
    if ( _promptLabel ) return _promptLabel;
    _promptLabel = [SJUILabelFactory labelWithText:@"" textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:11]];
    return _promptLabel;
}
- (SJProgressSlider *)progressSlider {
    if ( _progressSlider ) return _progressSlider;
    _progressSlider = [SJProgressSlider new];
    _progressSlider.trackHeight = 2;
    _progressSlider.userInteractionEnabled = NO;
    return _progressSlider;
}

#pragma mark -
- (NSTimer *)countDownTimer {
    if ( _countDownTimer ) return _countDownTimer;
    _countDownTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(countDownRefresh:) userInfo:nil repeats:YES];
    return _countDownTimer;
}

#pragma mark -
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(currentContext, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(currentContext, 1);
    CGFloat arr[] = {6, 3};
    
    // 0,0 -> W,0
    CGContextMoveToPoint(currentContext, 1, 1);
    CGContextAddLineToPoint(currentContext, self.bounds.size.width, 1);
    CGContextSetLineDash(currentContext, 0, arr, sizeof(arr) / sizeof(arr[0]));
    CGContextDrawPath(currentContext, kCGPathStroke);
    
    // 0,0 -> 0,H
    CGContextMoveToPoint(currentContext, 1, 1);
    CGContextAddLineToPoint(currentContext, 1, self.bounds.size.height);
    CGContextSetLineDash(currentContext, 0, arr, sizeof(arr) / sizeof(arr[0]));
    CGContextDrawPath(currentContext, kCGPathStroke);
    
    // 0,H -> W,H
    CGContextMoveToPoint(currentContext, 1, self.bounds.size.height-1);
    CGContextAddLineToPoint(currentContext, self.bounds.size.width, self.bounds.size.height-1);
    CGContextSetLineDash(currentContext, 0, arr, sizeof(arr) / sizeof(arr[0]));
    CGContextDrawPath(currentContext, kCGPathStroke);

    // W,0 -> W,H
    CGContextMoveToPoint(currentContext, self.bounds.size.width-1, 1);
    CGContextAddLineToPoint(currentContext, self.bounds.size.width-1, self.bounds.size.height);
    CGContextSetLineDash(currentContext, 0, arr, sizeof(arr) / sizeof(arr[0]));
    CGContextDrawPath(currentContext, kCGPathStroke);
}

@end
