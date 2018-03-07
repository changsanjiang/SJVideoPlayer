//
//  FullViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/23.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "FullViewController.h"
#import "SJVideoPlayer.h"
#import <SJUIFactory/SJUIFactory.h>
#import <Masonry.h>

@interface FullViewController ()

@property (nonatomic, strong) SJVideoPlayer *videoPlayer;

@end

@implementation FullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _videoPlayer = [SJVideoPlayer sharedPlayer];
    [self.view addSubview:_videoPlayer.view];
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(SJ_is_iPhoneX() ? 34 : 20);
        make.leading.trailing.offset(0);
        make.height.equalTo(_videoPlayer.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    __weak typeof(self) _self = self;
    _videoPlayer.clickedBackEvent = ^(SJVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
//        [self.videoPlayer rotate:SJRotateViewOrientation_Portrait animated:YES completion:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
//            __strong typeof(_self) self = _self;
//            if ( !self ) return;
//           self.videoPlayer.rotateOrientation = SJRotateViewOrientation_Portrait;
//            [self.navigationController popViewControllerAnimated:YES];
//        }];
        
    };
    
    // 播放
    _videoPlayer.assetURL = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"];
    
    // supported orientation. 设置旋转支持的方向.
    _videoPlayer.supportedRotateViewOrientation = SJSupportedRotateViewOrientation_LandscapeLeft | SJSupportedRotateViewOrientation_LandscapeRight;
    
    // 将播放器旋转成横屏.(播放器默认是竖屏的), 带动画
    _videoPlayer.rotateOrientation = SJRotateViewOrientation_LandscapeLeft; // 请注意: 是`SJRotateViewOrientation_LandscapeLeft` 而不是 `SJSupportedRotateViewOrientation_LandscapeLeft`
    
    // 将播放器旋转成横屏.(播放器默认是竖屏的), 不带动画
//    [_videoPlayer rotate:SJRotateViewOrientation_LandscapeLeft animated:NO];
    
}

- (void)dealloc {
    [[SJVideoPlayer sharedPlayer] stop];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
