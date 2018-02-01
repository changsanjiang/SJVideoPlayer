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


@interface PlayerViewController ()

@property (nonatomic, strong) SJVideoPlayer *videoPlayer;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIButton *pushBtn;

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.pushBtn];
    [self.pushBtn sizeToFit];
    self.pushBtn.center = self.view.center;
    
    self.playerView = [SJUIViewFactory viewWithBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_playerView];
    
    self.videoPlayer = [SJVideoPlayer player];
    [_playerView addSubview:_videoPlayer.view];
    
    
#pragma mark -

    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(SJ_is_iPhoneX() ? 34 : 20);
        make.leading.trailing.offset(0);
        make.height.equalTo(_playerView.mas_width).multipliedBy(9.0f / 16);
    }];
    
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
        
    /// 点击返回按钮执行的block.
    __weak typeof(self) _self = self;
    _videoPlayer.clickedBackEvent = ^(SJVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.videoPlayer stop];
        [self.navigationController popViewControllerAnimated:YES];
    };

    // setting player
    _videoPlayer.rotatedScreen = ^(SJVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self setNeedsStatusBarAppearanceUpdate]; // 显示或隐藏状态栏
    };
    
    // Call when the control view is hidden or displayed.
    _videoPlayer.controlViewDisplayStatus = ^(SJVideoPlayer * _Nonnull player, BOOL displayed) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self setNeedsStatusBarAppearanceUpdate]; // 改变状态栏style
    };
    
    /// 配置`更多页面`展示的`item`
    [self _setPlayerMoreSettingItems];
    
    
    /// 模拟网络请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        // 播放本地
//        _videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[[[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"]]];
        
        // 播放网络
        self.videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[NSURL URLWithString:@"http://rec.app.lanwuzhe.com/recordings/z1.lanwuzhe.2071517398365077/1517398365_1517484765.m3u8"]];
        
        // 设置标题
        self.videoPlayer.URLAsset.title = @"DIY心情转盘 #手工##手工制作#";
        
        // 是否一直显示标题
        self.videoPlayer.URLAsset.alwaysShowTitle = YES;
    });
    
    NSLog(@"vc = %@, player = %@", self, _videoPlayer);
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _videoPlayer.disableRotation = NO;  // 界面将要显示的时候, 恢复旋转.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _videoPlayer.disableRotation = YES; // 界面将要消失的时候, 禁止旋转. (考虑用户体验)
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_videoPlayer pause];   // 界面消失的时候, 暂停播放
}

#pragma mark -

- (UIButton *)pushBtn {
    if ( _pushBtn ) return _pushBtn;
    _pushBtn = [SJUIButtonFactory buttonWithTitle:@"Push" titleColor:[UIColor blueColor] font:[UIFont systemFontOfSize:17] target:self sel:@selector(clickedBtn)];
    return _pushBtn;
}

- (void)clickedBtn {
    [self.navigationController pushViewController:[[self class] new] animated:YES];
}




#pragma mark -

/// 配置`更多页面`展示的`item`
- (void)_setPlayerMoreSettingItems {
    
    __weak SJVideoPlayer *videoPlayer  = self.videoPlayer;
    SJVideoPlayerMoreSettingSecondary *QQ = [[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"QQ" image:[UIImage imageNamed:@"qq"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [videoPlayer showTitle:@"分享到QQ"];
    }];
    
    SJVideoPlayerMoreSettingSecondary *wechat = [[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"微信" image:[UIImage imageNamed:@"wechat"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [videoPlayer showTitle:@"分享到wechat"];
    }];
    
    SJVideoPlayerMoreSettingSecondary *weibo = [[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"微博" image:[UIImage imageNamed:@"weibo"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [videoPlayer showTitle:@"分享到weibo"];
    }];
    
    SJVideoPlayerMoreSetting *share = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"分享" image:[UIImage imageNamed:@"share"] showTowSetting:YES twoSettingTopTitle:@"分享到" twoSettingItems:@[QQ, wechat, weibo] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [videoPlayer showTitle:@"clicked Share"];
    }];
    
    SJVideoPlayerMoreSetting *download = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"下载" image:[UIImage imageNamed:@"download"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [videoPlayer showTitle:@"clicked download"];
    }];
    
    SJVideoPlayerMoreSetting *collection = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"收藏" image:[UIImage imageNamed:@"collection"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [videoPlayer showTitle:@"clicked collection"];
    }];
    
    SJVideoPlayerMoreSetting.titleFontSize = 10;
    
    videoPlayer.moreSettings = @[share, download, collection];
}

#pragma mark -

- (BOOL)prefersStatusBarHidden {
    // 全屏播放时, 使状态栏根据控制层显示或隐藏
    if ( _videoPlayer.isFullScreen ) return !_videoPlayer.controlViewDisplayed;
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    // 全屏播放时, 使状态栏变成白色
    if ( _videoPlayer.isFullScreen ) return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
}
@end
