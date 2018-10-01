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

@interface CustomControlLayerView ()
@property (nonatomic, weak) SJBaseVideoPlayer *player; // need weak ref

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation CustomControlLayerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    return self;
}

- (void)_setupViews {
    _topView = [UIView new];
    _topView.backgroundColor = UIColor.yellowColor;
    [self addSubview:_topView];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
        make.height.offset(44);
    }];
    
    
    _bottomView = [UIView new];
    _bottomView.backgroundColor = UIColor.redColor;
    [self addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.offset(0);
        make.height.offset(44);
    }];
}


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
    _player = videoPlayer;
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [UIView animateWithDuration:0.6 animations:^{
        self.topView.transform = CGAffineTransformIdentity;
        self.bottomView.transform = CGAffineTransformIdentity;
    }];
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [UIView animateWithDuration:0.6 animations:^{
        self.topView.transform = CGAffineTransformMakeTranslation(0, -44);
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, 44);
    }];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
    
}

// SJPlayStatusControlDelegate
// SJVolumeBrightnessRateControlDelegate
// SJLoadingControlDelegate
// .....
// ....
@end
