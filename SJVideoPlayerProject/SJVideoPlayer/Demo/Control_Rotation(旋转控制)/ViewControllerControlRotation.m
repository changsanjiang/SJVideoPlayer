//
//  ViewControllerControlRotation.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerControlRotation.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>
#import <SJBaseVideoPlayer/SJVCRotationManager.h>

@interface ViewControllerControlRotation ()<SJRouteHandler>
@property (nonatomic, strong) SJVideoPlayer *player;
@property (nonatomic, strong) SJVCRotationManager *vcRotationManager;
@end

@implementation ViewControllerControlRotation
+ (NSString *)routePath {
    return @"rotation/control";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

+ (instancetype)new {
    ViewControllerControlRotation *vc = [[ViewControllerControlRotation alloc] initWithNibName:@"ViewControllerControlRotation" bundle:nil];
    return vc;
}

- (IBAction)turnOnVCRotation:(UISwitch *)sender {
    _player.rotationManager = sender.isOn?self.vcRotationManager:nil;
    
    if ( sender.isOn ) {
        [_player showTitle:@"已切换到旋转VC管理器, VC将跟随一起旋转" duration:3];
    }
    else {
        [_player showTitle:@"已切换到只旋转播放器管理器, VC将不旋转" duration:3];
    }
}

- (IBAction)whetherAutoRotation:(UISwitch *)sender {
    _player.disableAutoRotation = !sender.isOn;
    
    if ( _player.disableAutoRotation ) {
        [_player showTitle:@"自动旋转已禁止, 播放器将保持当前方向, 不随设备旋转" duration:3];
    }
    else {
        [_player showTitle:@"自动旋转已开启, 播放器将随设备旋转" duration:3];
    }
}

- (IBAction)whetherSupportedPortraitOrientationWhenAutoRotate:(UISwitch *)sender {
    [sender setOn:YES animated:YES];
    
//    SJAutoRotateSupportedOrientation sp = self.player.supportedOrientation;
//    if ( sender.isOn ) self.player.supportedOrientation = sp | SJAutoRotateSupportedOrientation_Portrait;
//    else self.player.supportedOrientation = sp & (~SJAutoRotateSupportedOrientation_Portrait);
}

- (IBAction)whetherSupportedLandscapeLeftWhenAutoRotate:(UISwitch *)sender {
    SJAutoRotateSupportedOrientation sp = self.player.supportedOrientation;
    if ( sender.isOn ) self.player.supportedOrientation = sp | SJAutoRotateSupportedOrientation_LandscapeLeft;
    else self.player.supportedOrientation = sp & (~SJAutoRotateSupportedOrientation_LandscapeLeft);
    
    if ( sender.isOn ) {
        [self.player showTitle:@"自动旋转将支持 LandscapeLeft" duration:3];
    }
    else {
        [self.player showTitle:@"自动旋转将不支持 LandscapeLeft" duration:3];
    }
}

- (IBAction)whetherSupportedLandscapeRightWhenAutoRotate:(UISwitch *)sender {
    SJAutoRotateSupportedOrientation sp = self.player.supportedOrientation;
    if ( sender.isOn ) self.player.supportedOrientation = sp | SJAutoRotateSupportedOrientation_LandscapeRight;
    else self.player.supportedOrientation = sp & (~SJAutoRotateSupportedOrientation_LandscapeRight);
    
    if ( sender.isOn ) {
        [self.player showTitle:@"自动旋转将支持 LandscapeRight" duration:3];
    }
    else {
        [self.player showTitle:@"自动旋转将不支持 LandscapeRight" duration:3];
    }
}

- (IBAction)rotate:(id)sender {
    [self.player rotate];
    [self.player showTitle:@"随设备方向旋转"];
}

- (IBAction)rotate_left:(id)sender {
    [self.player rotate:SJOrientation_LandscapeLeft animated:YES];
}

- (IBAction)rotate_right:(id)sender {
    [self.player rotate:SJOrientation_LandscapeRight animated:YES];
}

#pragma mark
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // create a player of the default type
    _player = [SJVideoPlayer player];
    
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        else make.top.offset(0);
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_player.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
    _player.URLAsset.title = @"Test Title";
    _player.hideBackButtonWhenOrientationIsPortrait = YES;
    
    
    
    /// 初始化旋转VC管理器
    _vcRotationManager = [[SJVCRotationManager alloc] initWithViewController:self];
    _player.rotationManager = _vcRotationManager;
    

    /// 全屏后隐藏导航栏
    __weak typeof(self) _self = self;
    _player.viewWillRotateExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( player.rotationManager == self.vcRotationManager ) [self.navigationController setNavigationBarHidden:isFullScreen animated:YES];
    };
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player vc_viewWillDisappear];
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


#pragma mark - vc rotation
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [_vcRotationManager vc_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (BOOL)shouldAutorotate {
    if ( self.player.rotationManager != self.vcRotationManager ) return NO;
    return [self.vcRotationManager vc_shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.vcRotationManager vc_supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.vcRotationManager vc_preferredInterfaceOrientationForPresentation];
}
@end
