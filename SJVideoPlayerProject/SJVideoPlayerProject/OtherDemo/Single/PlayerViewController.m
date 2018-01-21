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
@property (nonatomic, assign) BOOL networked;

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
    
//    [NSURL URLWithString:@"http://video.cdn.lanwuzhe.com/usertrend/166162-1513873330.mp4"]
    /// 模拟网络请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _videoPlayer.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:[[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"]];
        _networked = YES;
    });
    
    
    NSLog(@"vc = %@, player = %@", self, _videoPlayer);
    
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    
    /// 销毁
    [self.videoPlayer stop];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    /// 启用旋转
    self.videoPlayer.disableRotation = NO;
    
    /// 是否需要播放
    if ( _networked && !self.videoPlayer.userPaused ) [self.videoPlayer play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    /// 禁用旋转
    self.videoPlayer.disableRotation = YES;

    /// 手动调用暂停
    [self.videoPlayer pause];
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
