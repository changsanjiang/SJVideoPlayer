//
//  ViewController.m
//  SwitchControlLayerDemo
//
//  Created by BlueDancer on 2018/6/4.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "ViewController.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry.h>
#import "SJDemoControlLayer.h"

@interface ViewController () {
    SJVideoPlayer *_videoPlayer;
}

@property (nonatomic, strong, readonly) SJVideoPlayer *videoPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    _videoPlayer.enableFilmEditing = YES;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)_setupViews {
    
    // create video player and add to root view
    [self.view addSubview:self.videoPlayer.view];
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(50);
        make.leading.trailing.offset(0);
        make.height.equalTo(self.videoPlayer.view.mas_width).multipliedBy(9/16.0);
    }];
    // play
    _videoPlayer.assetURL = [NSURL URLWithString:@"http://video.cdn.lanwuzhe.com/14945858406905f0c"];
    
    // create a custom control layer
    SJDemoControlLayer *demoControlLayer = [SJDemoControlLayer new];

    // create a data carrier and add to switcher
    [_videoPlayer.switcher addControlLayer:[[SJControlLayerCarrier alloc] initWithIdentifier:SJControlLayer_Edge dataSource:demoControlLayer delegate:demoControlLayer exitExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [demoControlLayer exitControlLayerCompeletionHandler:nil];
    } restartExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [demoControlLayer restartControlLayerCompeletionHandler:nil];
    }]];
    // switch
    [_videoPlayer.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge toVideoPlayer:_videoPlayer];
    
}

- (SJVideoPlayer *)videoPlayer {
    if ( _videoPlayer ) return _videoPlayer;
    _videoPlayer = [SJVideoPlayer player];
    __weak typeof(self) _self = self;
    _videoPlayer.willRotateScreen = ^(__kindof SJBaseVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [UIView animateWithDuration:0.25 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    };
    
    _videoPlayer.controlLayerAppearStateChanged = ^(__kindof SJBaseVideoPlayer * _Nonnull player, BOOL state) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [UIView animateWithDuration:0.25 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    };
    return _videoPlayer;
}

- (BOOL)prefersStatusBarHidden {
    if ( !_videoPlayer.isFullScreen ) return NO;
    return !_videoPlayer.controlLayerAppeared;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ( !_videoPlayer.isFullScreen ) return UIStatusBarStyleDefault;
    return _videoPlayer.controlLayerAppeared ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}
@end
