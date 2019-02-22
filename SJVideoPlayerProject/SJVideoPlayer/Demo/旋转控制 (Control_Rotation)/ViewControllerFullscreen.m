//
//  ViewControllerFullscreen.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerFullscreen.h"
#import "SJVideoPlayer.h"
#import <Masonry.h>
#import "SJVCRotationManager.h"
#import <SJRouter/SJRouter.h>

@interface ViewControllerFullscreen ()<SJRouteHandler>
@property (nonatomic, strong) SJVideoPlayer *player;
@property (nonatomic, strong) SJVCRotationManager *rotationManager;
@end

@implementation ViewControllerFullscreen

+ (NSString *)routePath {
    return @"player/fullscreen";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupViews];
    
    /// 播放
    _player.assetURL = [[NSBundle mainBundle] URLForResource:@"play" withExtension:@"mp4"];
    
    /// 替换旋转管理类
    _rotationManager = [[SJVCRotationManager alloc] initWithViewController:self];
    _player.rotationManager = _rotationManager;
    _player.supportedOrientation = SJAutoRotateSupportedOrientation_LandscapeLeft;
    /// update device orientation
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
    _player.disableAutoRotation = YES;
    
    __weak typeof(self) _self = self;
    _player.clickedBackEvent = ^(SJVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    // 禁止横屏水平滑动手势
    _player.disabledGestures = SJPlayerDisabledGestures_Pan_H;
    /// Test
    _player.defaultEdgeControlLayer.topContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_CurrentTime];
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_Separator];
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_Progress];
    
    SJEdgeControlButtonItem *fillItem = [[SJEdgeControlButtonItem alloc] initWithCustomView:nil tag:1];
    fillItem.fill = YES;
    [_player.defaultEdgeControlLayer.bottomAdapter insertItem:fillItem frontItem:SJEdgeControlLayerBottomItem_Play];
    
    SJEdgeControlButtonItem *durationItem = [_player.defaultEdgeControlLayer.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    durationItem.insets = SJEdgeInsetsMake(0, 12);
    [_player.defaultEdgeControlLayer.bottomAdapter exchangeItemForTag:SJEdgeControlLayerBottomItem_DurationTime withItemForTag:SJEdgeControlLayerBottomItem_Progress];
    
    _player.defaultEdgeControlLayer.hideBottomProgressSlider = YES;
    
    [_player.defaultEdgeControlLayer.bottomAdapter reload];
    _player.defaultEdgeControlLayer.bottomContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
}

- (void)_setupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    _player = [SJVideoPlayer player];
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
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
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
@end
