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
#import "SJMoreSettingItems.h"
#import "SJVideoPlayerHelper.h"

@interface PlayerViewController ()<SJMoreSettingItemsDelegate, SJVideoPlayerHelperUseProtocol>

@property (nonatomic, strong) SJVideoPlayer *videoPlayer;
@property (nonatomic, strong, readonly) SJMoreSettingItems *items;

@end

@implementation PlayerViewController

@synthesize items = _items;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _playerVCSetupViews];
    [self _playerVCAccessNetwork];
    
    // helper
    [SJVideoPlayerHelper sharedHelper].viewController = self;
    
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    [SJVideoPlayerHelper sharedHelper].vc_DeallocExeBlock();
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [SJVideoPlayerHelper sharedHelper].vc_viewWillAppearExeBlock();
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [SJVideoPlayerHelper sharedHelper].vc_viewWillDisappearExeBlock();
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [SJVideoPlayerHelper sharedHelper].vc_viewDidDisappearExeBlock();
}

#pragma mark - apple methods

- (BOOL)prefersStatusBarHidden {
    return [SJVideoPlayerHelper sharedHelper].vc_prefersStatusBarHiddenExeBlock();
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [SJVideoPlayerHelper sharedHelper].vc_preferredStatusBarStyleExeBlock();
}

#pragma mark - networking

- (void)_playerVCAccessNetwork {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 模拟网络延时
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.videoPlayer.URLAsset = /** 播放本地视频*/
        [[SJVideoPlayerURLAsset alloc] initWithTitle:@"DIY心情转盘 #手工##手工制作#"
                                     alwaysShowTitle:YES
                                            assetURL:[[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"]];
    });
}


#pragma mark - setup views

- (void)_playerVCSetupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    _videoPlayer = [SJVideoPlayer sharedPlayer];
    [self.view addSubview:_videoPlayer.view];
    
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(SJ_is_iPhoneX() ? 34 : 20);
        make.leading.trailing.offset(0);
        make.height.equalTo(_videoPlayer.view.mas_width).multipliedBy(9 / 16.0f);
    }];
}

@end
