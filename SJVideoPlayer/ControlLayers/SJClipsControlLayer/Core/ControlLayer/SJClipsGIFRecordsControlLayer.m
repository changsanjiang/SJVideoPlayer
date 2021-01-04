//
//  SJClipsGIFRecordsControlLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJClipsGIFRecordsControlLayer.h"
#import "UIView+SJAnimationAdded.h"
#import "SJClipsBackButton.h"
#import "SJClipsButtonContainerView.h"
#import "SJClipsGIFCountDownView.h"
#import "SJVideoPlayerConfigurations.h"

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

@interface SJClipsGIFRecordsControlLayer ()
@property (nonatomic, weak, nullable) __kindof SJBaseVideoPlayer *player;
@property (nonatomic, strong, readonly) SJClipsButtonContainerView *backButtonContainerView;
@property (nonatomic, strong, readonly) SJClipsGIFCountDownView *countDownView;
@property (nonatomic, strong, nullable) NSTimer *countDownTimer;
@property (nonatomic) NSInteger countDownNum;
@property (nonatomic, readonly) NSInteger maxCountDownNum;
@property (nonatomic) SJClipsStatus status;

@property (nonatomic) CMTime start;
@property (nonatomic, readonly) CMTime duration;
@end

@implementation SJClipsGIFRecordsControlLayer
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
    self.status = SJClipsStatus_Unknown;
    self.countDownNum = _maxCountDownNum;
    if ( _player.isPlaybackFinished ) {
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
        _countDownNum = _maxCountDownNum = 8;
        [self _setupViews];
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
    
    self.status = SJClipsStatus_Recording;
    
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
    
    [_player play];
}

- (void)pause {
    [self _cleanTimer];
    self.status = SJClipsStatus_Paused;
}

- (void)cancel {
    [self _cleanTimer];
    self.status = SJClipsStatus_Cancelled;
}

- (void)finished {
    [self _cleanTimer];
    self.status = SJClipsStatus_Finished;
}

- (void)setCountDownNum:(NSInteger)countDownNum {
    if ( countDownNum == _countDownNum )
        return;
    _countDownNum = countDownNum;
    
    [self _updateBottomItemSettings];
}

- (void)setStatus:(SJClipsStatus)status {
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
    self.topHeight = self.bottomHeight = 35;

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
    _backButtonContainerView = [[SJClipsButtonContainerView alloc] initWithFrame:CGRectZero buttonSize:CGSizeMake(buttonW, buttonH)];
    _backButtonContainerView.frame = CGRectMake(0, 0, buttonW, buttonH);
    __weak typeof(self) _self = self;
    _backButtonContainerView.clickedBackButtonExeBlock = ^(SJClipsButtonContainerView * _Nonnull view) {
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
    
    _countDownView = [[SJClipsGIFCountDownView alloc] initWithFrame:CGRectZero];
    SJEdgeControlButtonItem *countDownItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49xAutoresizing tag:SJBottomItem_CountDown];
    countDownItem.customView = _countDownView;
    [self.bottomAdapter addItem:countDownItem];
    
    SJEdgeControlButtonItem *right = [[SJEdgeControlButtonItem alloc] initWithCustomView:nil tag:SJBottomItem_RightFill];
    right.fill = YES;
    [self.bottomAdapter addItem:right];
}

- (void)_updateTopItemSettings {
    id<SJVideoPlayerLocalizedStrings> strings = SJVideoPlayerConfigurations.shared.localizedStrings;
    SJClipsBackButton *backButton = _backButtonContainerView.button;
    [backButton setTitle:strings.cancel forState:UIControlStateNormal];
    [self.topAdapter reload];
}

- (void)_updateRightItemSettings {
    id<SJVideoPlayerControlLayerResources> resources = SJVideoPlayerConfigurations.shared.resources;
    SJEdgeControlButtonItem *doneItem = [self.rightAdapter itemForTag:SJRightItem_Done];
    UIImage *image = CMTimeGetSeconds(self.duration) < 2 ? resources.recordsPreparingImage : resources.recordsToFinishRecordingImage;
    if ( image != doneItem.image ) {
        doneItem.image = image;
        [self.rightAdapter reload];
    }
}

- (void)_updateBottomItemSettings {
    id<SJVideoPlayerLocalizedStrings> strings = SJVideoPlayerConfigurations.shared.localizedStrings;
    _countDownView.timeLabel.text = [NSString stringWithFormat:@"%lds", (long)_countDownNum];
    _countDownView.promptLabel.text = CMTimeGetSeconds(self.duration) < 2 ? strings.recordsPreparingPrompt : strings.recordsToFinishRecordingPrompt;
    [self.bottomAdapter reload];
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
    if ( videoPlayer.isPlaybackFinished ) {
        [self finished];
    }
    else if ( videoPlayer.assetStatus == SJAssetStatusFailed ) {
        [self cancel];
    }
    else if ( videoPlayer.timeControlStatus == SJPlaybackTimeControlStatusPaused ) {
        [self pause];
    }
    else if ( self.status != SJClipsStatus_Recording ) {
        [self resume];
    }
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer { /* nothing */ }
- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer { /* nothing */ }

- (void)applicationDidBecomeActiveWithVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( self.status == SJClipsStatus_Paused ) {
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
