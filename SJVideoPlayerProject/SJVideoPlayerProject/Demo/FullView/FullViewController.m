//
//  FullViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/23.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "FullViewController.h"
#import "SJVideoPlayer.h"
#import <Masonry.h>
#import "SJVCRotationManager.h"

@interface FullViewController ()

@property (nonatomic, strong) SJVideoPlayer *player;
@property (nonatomic, strong) SJVCRotationManager *rotationManager;

@end

@implementation FullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupViews];
    
    /// 替换旋转管理类
    _rotationManager = [[SJVCRotationManager alloc] initWithViewController:self];
    _player.rotationManager = _rotationManager;
    
    _player.supportedOrientation = SJAutoRotateSupportedOrientation_LandscapeLeft;
    
    /// update device orientation
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
    
    __weak typeof(self) _self = self;
    _player.clickedBackEvent = ^(SJVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.navigationController popViewControllerAnimated:NO];
    };
    
    /// 播放
    _player.assetURL = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"];
    // Do any additional setup after loading the view.
}

- (void)_setupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    _player = [SJVideoPlayer player];
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.height.equalTo(self.player.view.mas_width).multipliedBy(9 / 16.0f);
    }];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [_rotationManager vc_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (BOOL)shouldAutorotate {
    return [self.rotationManager vc_shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.rotationManager vc_supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.rotationManager vc_preferredInterfaceOrientationForPresentation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player vc_viewWillDisappear];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player vc_viewDidDisappear];
}

- (BOOL)prefersStatusBarHidden {
    return [self.player vc_prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.player vc_preferredStatusBarStyle];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
@end
