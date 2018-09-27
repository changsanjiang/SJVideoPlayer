//
//  VCRotationViewController.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/9/19.
//  Copyright © 2018 SanJiang. All rights reserved.
//

#import "VCRotationViewController.h"
#import "SJVideoPlayer.h"
#import <Masonry.h>
#import "SJVCRotationManager.h"

@interface VCRotationViewController ()
@property (nonatomic, strong) SJVideoPlayer *player;
@property (nonatomic, strong) SJVCRotationManager *rotationManager;
@property (nonatomic, strong) UIButton *disable_Yes_btn;
@property (nonatomic, strong) UIButton *disable_No_btn;
@property (nonatomic, strong) UIButton *rotateBtn;
@end

@implementation VCRotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self _setupViews];
    
    /// 替换旋转管理类
    _rotationManager = [[SJVCRotationManager alloc] initWithViewController:self];
    _player.rotationManager = _rotationManager;
    
    /// 播放
    _player.assetURL = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"];
    // Do any additional setup after loading the view.
}

- (void)_setupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak typeof(self) _self = self;
    UIButton *(^inner_makeButton)(NSString *title, SEL selector) = ^UIButton * (NSString *title, SEL selector) {
        __strong typeof(_self) self = _self;
        if ( !self ) return nil;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        return btn;
    };
    
    _disable_Yes_btn = inner_makeButton(@"disable_autorotation_yes", @selector(disableRotation_Yes));
    _disable_No_btn  = inner_makeButton(@"disable_autorotation_no", @selector(disableRotation_No));
    _rotateBtn = inner_makeButton(@"force roate", @selector(rotate));
    
    [self.view addSubview:_disable_Yes_btn];
    [self.view addSubview:_disable_No_btn];
    [self.view addSubview:_rotateBtn];
    
    _player = [SJVideoPlayer player];
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.height.equalTo(self.player.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    
    [_disable_Yes_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_disable_No_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.disable_Yes_btn.mas_bottom).offset(12);
        make.centerX.offset(0);
    }];
    
    [_rotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.disable_No_btn.mas_bottom).offset(12);
        make.centerX.offset(0);
    }];
}

- (void)disableRotation_Yes {
    _player.disableAutoRotation = YES;
}

- (void)disableRotation_No {
    _player.disableAutoRotation = NO;
}

- (void)rotate {
    [_player rotate];
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
