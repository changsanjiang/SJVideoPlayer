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
    [self _show:self.controlView animated:YES];
    [self _show:_topContainerView animated:YES];
    [self _show:_bottomContainerView animated:YES];
}

- (void)exitControlLayer {
    _player.controlLayerDataSource = nil;
    _player.controlLayerDelegate = nil;
    _player = nil;
    
    [self _hidden:_topContainerView animated:YES];
    [self _hidden:_bottomContainerView animated:YES];
    
    [self _hidden:self.controlView animated:YES completionHandler:^{
        if ( !self -> _restarted ) [self.controlView removeFromSuperview];
    }];
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

- (BOOL)controlLayerDisappearCondition {
    return YES;
}

- (BOOL)triggerGesturesCondition:(CGPoint)location {
    if ( CGRectContainsPoint( _topContainerView.frame, location) ||
         CGRectContainsPoint( _bottomContainerView.frame, location) ) return NO;
    return YES;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _player = videoPlayer;
    
    [_player.view layoutIfNeeded];
    [self _hidden:_topContainerView animated:NO];
    [self _hidden:_bottomContainerView animated:NO];
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _show:_topContainerView animated:YES];
    [self _show:_bottomContainerView animated:YES];
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _hidden:_topContainerView animated:YES];
    [self _hidden:_bottomContainerView animated:YES];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
}

- (void)_show:(UIView *)view animated:(BOOL)animated {
    if ( !view.sjv_disappeared ) return;
    [UIView animateWithDuration:animated?0.6:0 animations:^{
        [view sjv_appear];
    }];
}

- (void)_hidden:(UIView *)view animated:(BOOL)animated {
    [self _hidden:view animated:animated completionHandler:nil];
}

- (void)_hidden:(UIView *)view animated:(BOOL)animated completionHandler:(void(^_Nullable)(void))competionHandler {
    if ( view.sjv_disappeared ) return;
    [UIView animateWithDuration:animated?0.6:0 animations:^{
        [view sjv_disapear];
    }];
}

// SJPlayStatusControlDelegate
// SJVolumeBrightnessRateControlDelegate
// SJLoadingControlDelegate
// .....
// ....
@end
NS_ASSUME_NONNULL_END
