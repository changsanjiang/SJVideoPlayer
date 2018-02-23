//
//  PlayerViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "PlayerViewController.h"
#import "SJVideoPlayer.h"
#import <Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import "SJSharedVideoPlayerHelper.h"

@interface PlayerViewController ()<SJSharedVideoPlayerHelperUseProtocol>

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _playerVCSetupViews];
    [self _playerVCAccessNetwork];
    
    // helper
    [SJSharedVideoPlayerHelper sharedHelper].viewController = self;
    
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    [SJSharedVideoPlayerHelper sharedHelper].vc_DeallocExeBlock();
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [SJSharedVideoPlayerHelper sharedHelper].vc_viewWillAppearExeBlock();
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [SJSharedVideoPlayerHelper sharedHelper].vc_viewWillDisappearExeBlock();
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [SJSharedVideoPlayerHelper sharedHelper].vc_viewDidDisappearExeBlock();
}

#pragma mark - apple methods

- (BOOL)prefersStatusBarHidden {
    return [SJSharedVideoPlayerHelper sharedHelper].vc_prefersStatusBarHiddenExeBlock();
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [SJSharedVideoPlayerHelper sharedHelper].vc_preferredStatusBarStyleExeBlock();
}

#pragma mark -

- (void)_playerVCAccessNetwork {
    // 模拟网络延时
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SJVideoPlayer sharedPlayer].URLAsset = /** 播放本地视频*/
        [[SJVideoPlayerURLAsset alloc] initWithTitle:@"DIY心情转盘 #手工##手工制作#"
                                     alwaysShowTitle:YES
                                            assetURL:[[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"]];
    });
}

- (void)_playerVCSetupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:[SJVideoPlayer sharedPlayer].view];
    [[SJVideoPlayer sharedPlayer].view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(SJ_is_iPhoneX() ? 34 : 20);
        make.leading.trailing.offset(0);
        make.height.equalTo([SJVideoPlayer sharedPlayer].view.mas_width).multipliedBy(9 / 16.0f);
    }];
}

@end
