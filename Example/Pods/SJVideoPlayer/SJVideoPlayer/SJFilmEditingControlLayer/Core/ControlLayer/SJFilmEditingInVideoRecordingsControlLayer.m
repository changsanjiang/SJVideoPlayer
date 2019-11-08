//
//  SJFilmEditingInVideoRecordingsControlLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJFilmEditingInVideoRecordingsControlLayer.h"
#import "UIView+SJAnimationAdded.h"
#import "SJVideoPlayerAnimationHeader.h"
#import "SJFilmEditingSettings.h"
#import "SJFilmEditingBackButton.h"
#import "SJFilmEditingButtonContainerView.h"
#import "SJFilmEditingVideoCountDownView.h"

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#if __has_include(<SJBaseVideoPlayer/NSTimer+SJAssetAdd.h>)
#import <SJBaseVideoPlayer/NSTimer+SJAssetAdd.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#else
#import "NSTimer+SJAssetAdd.h"
#import "SJBaseVideoPlayer.h"
#endif


NS_ASSUME_NONNULL_BEGIN
static SJEdgeControlButtonItemTag SJTopItem_Back = 1;
static SJEdgeControlButtonItemTag SJRightItem_Done = 2;
static SJEdgeControlButtonItemTag SJBottomItem_CountDown = 3;
static SJEdgeControlButtonItemTag SJBottomItem_LeftFill = 4;
static SJEdgeControlButtonItemTag SJBottomItem_RightFill = 5;

@interface SJFilmEditingInVideoRecordingsControlLayer ()
@property (nonatomic, weak, nullable) __kindof SJBaseVideoPlayer *player;
@property (nonatomic, strong, readonly) SJFilmEditingSettingsUpdatedObserver *settingsUpdatedObserver;
@property (nonatomic, strong, readonly) SJFilmEditingButtonContainerView *backButtonContainerView;
@property (nonatomic, strong, readonly) SJFilmEditingVideoCountDownView *countDownView;
@property (nonatomic, strong, nullable) NSTimer *countDownTimer;
@property (nonatomic) NSInteger countDownNum;
@property (nonatomic, readonly) NSInteger maxCountDownNum;
@property (nonatomic) SJFilmEditingStatus status;

@property (nonatomic) CMTime start;
@property (nonatomic, readonly) CMTime duration;
@end

@implementation SJFilmEditingInVideoRecordingsControlLayer
@synthesize restarted = _restarted;

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
}
#endif

- (void)restartControlLayer {
    _restarted = YES;
    
    sj_view_makeAppear(self.topContainerView, YES);
    sj_view_makeAppear(self.rightContainerView, YES);
    sj_view_makeAppear(self.bottomContainerView, YES);
    sj_view_makeAppear(self.controlView, YES);
    self.status = SJFilmEditingStatus_Unknown;
    self.countDownNum = _maxCountDownNum;
    if ( _player.isPlayedToEndTime ) {
        self.start = kCMTimeZero;
    }
    else {
        self.start = CMTimeMake(_player.currentTime * 1000, 1000);
    }
    [self resume];
}

- (void)exitControlLayer {
    _restarted = NO;
    _player = nil;
    [self _cleanTimer];
    sj_view_makeDisappear(self.topContainerView, YES);
    sj_view_makeDisappear(self.rightContainerView, YES);
    sj_view_makeDisappear(self.bottomContainerView, YES);
    
    sj_view_makeDisappear(self.controlView, YES, ^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _start = kCMTimeZero;
        _countDownNum = _maxCountDownNum = 60 * 2;
        [self _setupViews];
        [self _initializeObserver];
    }
    return self;
}

- (CMTime)duration {
    return CMTimeMakeWithSeconds(_maxCountDownNum - _countDownNum, 1);
}

- (CMTimeRange)range {
    return CMTimeRangeMake(self.start, self.duration);;
}

- (void)resume {
    if ( _countDownTimer )
        return;
    [_player play];
    
    self.status = SJFilmEditingStatus_Recording;
    
    __weak typeof(self) _self = self;
    _countDownTimer = [NSTimer assetAdd_timerWithTimeInterval:1 block:^(NSTimer *timer) {
        __strong typeof(_self) self = _self;
        if ( !self ) {
            [timer invalidate];
            return;
        }
        if ( 0 == (self.countDownNum -= 1) ) {
            [self finished];
        }
        [self _updateRightItemSettings];
    } repeats:YES];
    [_countDownTimer assetAdd_fire];
    [NSRunLoop.mainRunLoop addTimer:_countDownTimer forMode:NSRunLoopCommonModes];
}

- (void)pause {
    [self _cleanTimer];
    self.status = SJFilmEditingStatus_Paused;
}

- (void)cancel {
    [self _cleanTimer];
    self.status = SJFilmEditingStatus_Cancelled;
}

- (void)finished {
    [self _cleanTimer];
    self.status = SJFilmEditingStatus_Finished;
}

- (void)setCountDownNum:(NSInteger)countDownNum {
    if ( countDownNum == _countDownNum )
        return;
    _countDownNum = countDownNum;
    
    [self _updateBottomItemSettings];
}

- (void)setStatus:(SJFilmEditingStatus)status {
    if ( status == _status )
        return;
    _status = status;
    
    if ( _statusDidChangeExeBlock ) {
        _statusDidChangeExeBlock(self);
    }
}

- (void)_cleanTimer {
    [_countDownTimer invalidate];
    _countDownTimer = nil;
}

#pragma mark - actions

- (void)clickedDoneItem:(SJEdgeControlButtonItem *)item {
    if ( CMTimeGetSeconds(self.duration) < 2 ) {
        return;
    }
    
    [self finished];
}

#pragma mark -

- (void)_setupViews {
    self.backgroundColor = [UIColor clearColor];
    self.autoAdjustTopSpacing = NO;
    self.topMargin = self.bottomMargin = self.rightMargin = 20;
    self.topHeight = 35;
    self.bottomHeight = 40;

    self.topContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Top;
    self.rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
    self.bottomContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Bottom;
    sj_view_initializes(@[self.topContainerView, self.rightContainerView, self.bottomContainerView]);
    [self.topContainerView cleanColors];
    [self.bottomContainerView cleanColors];
    
    [self _addItemToTopAdapter];
    [self _addItemToRightAdapter];
    [self _addItemToBottomAdapter];
    
    [self _updateTopItemSettings];
    [self _updateRightItemSettings];
    [self _updateBottomItemSettings];
}

- (void)_addItemToTopAdapter {
    CGFloat buttonH = self.topHeight;
    CGFloat buttonW = ceil(buttonH * 2.8);
    _backButtonContainerView = [[SJFilmEditingButtonContainerView alloc] initWithFrame:CGRectZero buttonSize:CGSizeMake(buttonW, buttonH)];
    _backButtonContainerView.frame = CGRectMake(0, 0, buttonW, buttonH);
    __weak typeof(self) _self = self;
    _backButtonContainerView.clickedBackButtonExeBlock = ^(SJFilmEditingButtonContainerView * _Nonnull view) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self cancel];
    };
    
    SJEdgeControlButtonItem *backItem = [[SJEdgeControlButtonItem alloc] initWithTag:SJTopItem_Back];
    backItem.insets = SJEdgeInsetsMake(self.topMargin, 0);
    backItem.customView = _backButtonContainerView;
    [self.topAdapter addItem:backItem];
}

- (void)_addItemToRightAdapter {
    SJEdgeControlButtonItem *doneItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJRightItem_Done];
    [doneItem addTarget:self action:@selector(clickedDoneItem:)];
    [self.rightAdapter addItem:doneItem];
}

- (void)_addItemToBottomAdapter {
    SJEdgeControlButtonItem *left = [[SJEdgeControlButtonItem alloc] initWithCustomView:nil tag:SJBottomItem_LeftFill];
    left.fill = YES;
    [self.bottomAdapter addItem:left];
    
    _countDownView = [[SJFilmEditingVideoCountDownView alloc] initWithFrame:CGRectZero];
    SJEdgeControlButtonItem *countDownItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49xAutoresizing tag:SJBottomItem_CountDown];
    countDownItem.customView = _countDownView;
    [self.bottomAdapter addItem:countDownItem];
    
    SJEdgeControlButtonItem *right = [[SJEdgeControlButtonItem alloc] initWithCustomView:nil tag:SJBottomItem_RightFill];
    right.fill = YES;
    [self.bottomAdapter addItem:right];
}

- (void)_updateTopItemSettings {
    SJFilmEditingSettings * _Nonnull setting = [SJFilmEditingSettings commonSettings];
    SJFilmEditingBackButton *backButton = _backButtonContainerView.button;
    [backButton setTitle:setting.cancelText forState:UIControlStateNormal];
    [self.topAdapter reload];
}

- (void)_updateRightItemSettings {
    SJFilmEditingSettings * _Nonnull setting = [SJFilmEditingSettings commonSettings];
    SJEdgeControlButtonItem *doneItem = [self.rightAdapter itemForTag:SJRightItem_Done];
    UIImage *img = nil;
    if ( CMTimeGetSeconds(self.duration) < 2 ) {
        img = setting.waitingImage;
    }
    else {
        img = setting.finishImage;
    }
    
    if ( img != doneItem.image ) {
        doneItem.image = img;
        [self.rightAdapter reload];
    }
}

- (void)_updateBottomItemSettings {
    SJFilmEditingSettings * _Nonnull setting = [SJFilmEditingSettings commonSettings];
    NSString *current = [_player stringForSeconds:_maxCountDownNum - _countDownNum]?:@"00:00";
    NSString *max = [_player stringForSeconds:_maxCountDownNum]?:@"00:00";
    _countDownView.timeLabel.text = [NSString stringWithFormat:@"%@/%@", current, max];
    if ( CMTimeGetSeconds(self.duration) < 2 ) {
        _countDownView.promptLabel.text = setting.waitingText;
    }
    else {
        _countDownView.promptLabel.text = setting.finishText;
    }
    
    _countDownView.progressSlider.maxValue = _maxCountDownNum;
    _countDownView.progressSlider.value = _maxCountDownNum - _countDownNum;
    [self.bottomAdapter reload];
}

#pragma mark -

- (void)_initializeObserver {
    _settingsUpdatedObserver = [[SJFilmEditingSettingsUpdatedObserver alloc] init];
    __weak typeof(self) _self = self;
    _settingsUpdatedObserver.updatedExeBlock = ^(SJFilmEditingSettings *settings) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _updateTopItemSettings];
        [self _updateRightItemSettings];
    };
}

#pragma mark -
- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _player = videoPlayer;
    [videoPlayer needHiddenStatusBar];
    sj_view_makeDisappear(self.topContainerView, NO);
    sj_view_makeDisappear(self.rightContainerView, NO);
    sj_view_makeDisappear(self.bottomContainerView, NO);
}

- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    return NO;
}

- (BOOL)canTriggerRotationOfVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    return NO;
}

- (void)videoPlayerPlaybackStatusDidChange:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( videoPlayer.isPlayedToEndTime ) {
        [self finished];
    }
    else if ( videoPlayer.assetStatus == SJAssetStatusFailed ) {
        [self cancel];
    }
    else if ( videoPlayer.timeControlStatus == SJPlaybackTimeControlStatusPlaying ) {
        [self resume];
    }
    else if ( self.status == SJFilmEditingStatus_Recording ) {
        [self pause];
    }
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer { /* nothing */ }
- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer { /* nothing */ }

- (void)receivedApplicationDidBecomeActiveNotification:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( self.status == SJFilmEditingStatus_Paused ) {
        [videoPlayer play];
    }
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
NS_ASSUME_NONNULL_END
