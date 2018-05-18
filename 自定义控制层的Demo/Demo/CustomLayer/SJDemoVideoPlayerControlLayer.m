//
//  SJDemoVideoPlayer.m
//  Demo
//
//  Created by BlueDancer on 2018/5/18.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJDemoVideoPlayerControlLayer.h"
#import <Masonry.h>
#import <SJLoadingView/SJLoadingView.h>

@interface SJDemoVideoPlayerControlLayer (){
    UIView *_topControlView;
    UIView *_bottomControlView;
    SJLoadingView *_loadingView;
}
/// 弱引用
@property (nonatomic, weak) SJBaseVideoPlayer *videoPlayer;

@property (nonatomic, strong, readonly) SJLoadingView *loadingView;

@property (nonatomic, strong, readonly) UIView *topControlView;
@property (nonatomic, strong, readonly) UIView *bottomControlView;
@end

@implementation SJDemoVideoPlayerControlLayer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}


#pragma mark -
- (void)_setupView {
    [self addSubview:self.topControlView];
    [self addSubview:self.bottomControlView];
    [self addSubview:self.loadingView];
    
    [_topControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.height.offset(49);
    }];
    
    [_bottomControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(49);
        make.leading.bottom.trailing.offset(0);
    }];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        /// loadingView 有默认大小, 所以直接设置居中显示即可. 当然, 也可以设置它的大小
        make.center.offset(0);
    }];
}

- (UIView *)topControlView {
    if ( _topControlView ) return _topControlView;
    _topControlView = [UIView new];
    _topControlView.backgroundColor = [UIColor orangeColor];
    return _topControlView;
}

- (UIView *)bottomControlView {
    if ( _bottomControlView ) return _bottomControlView;
    _bottomControlView = [UIView new];
    _bottomControlView.backgroundColor = [UIColor orangeColor];
    return _bottomControlView;
}

#pragma mark - 
- (UIView *)controlView {
    return self;
}

- (BOOL)controlLayerDisappearCondition {
    return YES;
}

- (BOOL)triggerGesturesCondition:(CGPoint)location {
    return YES;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    self.videoPlayer = videoPlayer;
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [UIView animateWithDuration:0.25 animations:^{
        self.topControlView.alpha = 1;
        self.bottomControlView.alpha = 1;
    }];
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [UIView animateWithDuration:0.25 animations:^{
        self.topControlView.alpha = 0.001;
        self.bottomControlView.alpha = 0.001;
    }];
}

- (void)videoPlayerWillAppearInScrollView:(__kindof SJBaseVideoPlayer *)videoPlayer {
    videoPlayer.view.hidden = NO;
}

- (void)videoPlayerWillDisappearInScrollView:(__kindof SJBaseVideoPlayer *)videoPlayer {
    videoPlayer.view.hidden = YES;
    [videoPlayer pause];
}

- (void)startLoading:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self.loadingView start];
}

- (void)cancelLoading:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self.loadingView stop];
}

- (void)loadCompletion:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self.loadingView stop];
}
@end
