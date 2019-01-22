//
//  CustomControlLayerView.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/1.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "CustomControlLayerView.h"
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <Masonry/Masonry.h>
#import "UIView+SJAnimationAdded.h"

NS_ASSUME_NONNULL_BEGIN
@interface CustomControlLayerView ()
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *player; // need weak ref
@end

@implementation CustomControlLayerView

@synthesize restarted = _restarted;

- (void)restartControlLayer {
    sj_view_makeAppear(self.controlView, YES);
    sj_view_makeAppear(_topContainerView, YES);
    sj_view_makeAppear(_bottomContainerView, YES);
}

- (void)exitControlLayer {
    _player.controlLayerDataSource = nil;
    _player.controlLayerDelegate = nil;
    _player = nil;
    
    sj_view_makeDisappear(_topContainerView, YES);
    sj_view_makeDisappear(_bottomContainerView, YES);
    sj_view_makeDisappear(self.controlView, YES, ^{
        if ( !self -> _restarted ) [self.controlView removeFromSuperview];
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    return self;
}

- (void)_setupViews {
    self.topContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.bottomContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    
    self.topContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Top;
    self.bottomContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Bottom;
    
    SJEdgeControlButtonItem *shareItem = [[SJEdgeControlButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] target:self action:@selector(test:) tag:0];
    [self.topAdapter addItem:shareItem];

    [self.bottomAdapter addItem:shareItem];
    [self.bottomAdapter addItem:shareItem];
    [self.bottomAdapter addItem:shareItem];
    [self.bottomAdapter addItem:shareItem];
    
    // update
    [self.topAdapter reload];
    [self.bottomAdapter reload];
}

- (void)test:(SJEdgeControlButtonItem *)item {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}

#pragma mark -

- (UIView *)controlView {
    return self;
}

- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    if ( CGRectContainsPoint( _topContainerView.frame, location) ||
         CGRectContainsPoint( _bottomContainerView.frame, location) ) return NO;
    return YES;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _player = videoPlayer;
    
    [_player.view layoutIfNeeded];
    sj_view_makeDisappear(_topContainerView, NO);
    sj_view_makeDisappear(_bottomContainerView, NO);
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    sj_view_makeAppear(_topContainerView, YES);
    sj_view_makeAppear(_bottomContainerView, YES);
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    sj_view_makeDisappear(_topContainerView, YES);
    sj_view_makeDisappear(_bottomContainerView, YES);
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}

// SJPlayStatusControlDelegate
// SJVolumeBrightnessRateControlDelegate
// SJBufferControlDelegate
// .....
// ....
@end
NS_ASSUME_NONNULL_END
