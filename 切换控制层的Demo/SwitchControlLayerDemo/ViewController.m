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
#import <SJFilmEditingControlLayer.h>

@interface ViewController () <SJDemoControlLayerDelegate> {
    SJVideoPlayer *_videoPlayer;
}

@property (nonatomic, strong, readonly) SJVideoPlayer *videoPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    _videoPlayer.assetURL = [NSURL URLWithString:@"http://video.cdn.lanwuzhe.com/14945858406905f0c"];
}

- (void)_setupViews {
    
    // create video player and add to root view
    [self.view addSubview:self.videoPlayer.view];
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(50);
        make.leading.trailing.offset(0);
        make.height.equalTo(self.videoPlayer.view.mas_width).multipliedBy(9/16.0);
    }];
    
    // create a custom control layer
    SJDemoControlLayer *demoControlLayer = [SJDemoControlLayer new];
    demoControlLayer.delegate = self;

    
    static SJControlLayerIdentifier SJControlLayer_Demo_Edge = 1;
    
    // create a data carrier and add to switcher
    [_videoPlayer.switcher addControlLayer:[[SJControlLayerCarrier alloc] initWithIdentifier:SJControlLayer_Demo_Edge dataSource:demoControlLayer delegate:demoControlLayer exitExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [demoControlLayer exitControlLayerCompeletionHandler:^{
            
            // remove control view from player view
            [demoControlLayer.controlView removeFromSuperview];

        }];
    } restartExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [demoControlLayer restartControlLayerCompeletionHandler:nil];
    }]];
    
    // switch
    [_videoPlayer.switcher switchControlLayerForIdentitfier:SJControlLayer_Demo_Edge toVideoPlayer:_videoPlayer];
}

#pragma mark - demo control layer delegate method
- (void)clickedFilmEditingBtnOnDemoControlLayer:(SJDemoControlLayer *)controlLayer {
    [_videoPlayer.switcher switchControlLayerForIdentitfier:SJControlLayer_FilmEditing toVideoPlayer:_videoPlayer];
}

- (SJVideoPlayer *)videoPlayer {
    if ( _videoPlayer ) return _videoPlayer;
    _videoPlayer = [SJVideoPlayer player];
    _videoPlayer.enableFilmEditing = YES;
    return _videoPlayer;
}

- (BOOL)prefersStatusBarHidden {
    return [self.videoPlayer vc_prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.videoPlayer vc_preferredStatusBarStyle];
}
@end
