//
//  LandscapeViewController.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/5/30.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "LandscapeViewController.h"
#import <Masonry.h>
#import "SJVideoPlayer.h"

@interface LandscapeViewController ()
@property (nonatomic, strong) UIView *playerParentView;
@property (nonatomic, strong) SJVideoPlayer *videoPlayer;

@end

@implementation LandscapeViewController

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    [_videoPlayer pause];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    
    
    _videoPlayer = [SJVideoPlayer player];
    _videoPlayer.supportedOrientation = SJAutoRotateSupportedOrientation_Portrait;
    _videoPlayer.pausedToKeepAppearState = YES;
    _videoPlayer.assetURL = [NSURL URLWithString:@"http://v.dansewudao.com/502718a3e0a24673b2afa1c5c27cd301/771b26823ac64631b8977a718610b779-9f4d50aeba651a86d2b45f89f4799f31-sd.mp4"];
    [self.view addSubview:_videoPlayer.view];
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    __weak typeof(self) _self = self;
    _videoPlayer.clickedBackEvent = ^(SJVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;

        [self.navigationController popViewControllerAnimated:YES];
    };
    
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.visibleViewController.view.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

@end
