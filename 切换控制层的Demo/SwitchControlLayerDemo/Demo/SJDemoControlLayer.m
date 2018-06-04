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
@end

@implementation SJDemoControlLayer
@synthesize topView = _topView;
@synthesize bottomView = _bottomView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)restartControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler {
    // ....
}

- (void)exitControlLayerCompeletionHandler:(nullable void(^)(void))compeletionHandler {
    // .... 
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
    UIView_Animations(CommonAnimaDuration, ^{
        [self.topView appear];
        [self.bottomView appear];
    }, nil);
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    UIView_Animations(CommonAnimaDuration, ^{
        [self.topView disappear];
        [self.bottomView disappear];
    }, nil);
}

#pragma mark
- (void)_setupView {
    [self addSubview:self.topView];
    [self addSubview:self. bottomView];
    
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.height.offset(60);
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
@end
