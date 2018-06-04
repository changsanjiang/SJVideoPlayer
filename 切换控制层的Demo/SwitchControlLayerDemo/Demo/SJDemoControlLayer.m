//
//  SJDemoControlLayer.m
//  SwitchControlLayerDemo
//
//  Created by BlueDancer on 2018/6/4.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJDemoControlLayer.h"
#import <Masonry.h>
#import <UIView+SJControlAdd.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJVideoPlayerAnimationHeader.h>

@interface SJDemoControlLayer ()
@property (nonatomic, weak) SJBaseVideoPlayer  *videoPlayer;
@property (nonatomic, strong, readonly) UIView *topView;
@property (nonatomic, strong, readonly) UIView *bottomView;
@property (nonatomic, strong, readonly) UIButton *filmEditingBtn;
@end

@implementation SJDemoControlLayer
@synthesize topView = _topView;
@synthesize bottomView = _bottomView;
@synthesize filmEditingBtn = _filmEditingBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)restartControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler {
    if ( _videoPlayer.URLAsset ) {
        /// 手动纠正控制层状态, 并显示
        /// 播放器可能会受到外界切换的干扰, 所有这里手动纠正控制层的显示状态
        [_videoPlayer setControlLayerAppeared:YES];
        [self controlLayerNeedAppear:_videoPlayer completionHandler:compeletionHandler];
        return;
    }
    
    [_videoPlayer controlLayerNeedDisappear];
}

- (void)exitControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler {
    /// clean
    _videoPlayer.controlLayerDataSource = nil;
    _videoPlayer.controlLayerDelegate = nil;
    _videoPlayer = nil;
    
    UIView_Animations(CommonAnimaDuration, ^{
        [self->_topView disappear];
        [self->_bottomView disappear];
    }, compeletionHandler);
}


- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer completionHandler:(void(^)(void))completionHandler {
    UIView_Animations(CommonAnimaDuration, ^{
        [self.topView appear];
        [self.bottomView appear];
    }, completionHandler);
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer completionHandler:(void(^)(void))completionHandler {
    UIView_Animations(CommonAnimaDuration, ^{
        [self.topView disappear];
        [self.bottomView disappear];
    }, completionHandler);
}

#pragma mark
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
    _videoPlayer = videoPlayer;
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self controlLayerNeedAppear:videoPlayer completionHandler:nil];
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self controlLayerNeedDisappear:videoPlayer completionHandler:nil];
}

#pragma mark

- (void)clickedBtn:(UIButton *)btn {
    NSLog(@"%d - %s", (int)__LINE__, __func__);
    if ( [self.delegate respondsToSelector:@selector(clickedFilmEditingBtnOnDemoControlLayer:)] ) {
        [self.delegate clickedFilmEditingBtnOnDemoControlLayer:self];
    }
}

#pragma mark
- (void)_setupView {
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self.topView addSubview:self.filmEditingBtn];
    
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.height.offset(60);
    }];
    
    [_filmEditingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.offset(60);
    }];
    
    _topView.disappearType = SJDisappearType_All;
    _topView.disappearTransform = CGAffineTransformMakeTranslation(0, -60);
    
    _bottomView.disappearType = SJDisappearType_All;
    _bottomView.disappearTransform = CGAffineTransformMakeTranslation(0, 60);
    
    
    [_topView disappear];
    [_bottomView disappear];
}

- (UIView *)topView {
    if ( _topView ) return _topView;
    _topView = [UIView new];
    CGFloat hue = arc4random() % 256 / 255.0;
    _topView.backgroundColor = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
    return _topView;
}
- (UIView *)bottomView {
    if ( _bottomView ) return _bottomView;
    _bottomView = [UIView new];
    CGFloat hue = arc4random() % 256 / 255.0;
    _bottomView.backgroundColor = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
    return _bottomView;
}
- (UIButton *)filmEditingBtn {
    if ( _filmEditingBtn ) return _filmEditingBtn;
    _filmEditingBtn = [UIButton new];
    [_filmEditingBtn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_filmEditingBtn setTitle:@"FilmEditing" forState:UIControlStateNormal];
    [_filmEditingBtn setBackgroundColor:[UIColor orangeColor]];
    return _filmEditingBtn;
}
@end
