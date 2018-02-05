//
//  PlayerViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "PlayerViewController.h"
#import "SJVideoPlayer.h"
#import <Masonry/Masonry.h>
#import <SJUIFactory/SJUIFactory.h>
#import "SJVideoPlayerControlView.h"
#import "SJVideoPlayerMoreSettingSecondary.h"

@interface PlayerViewController ()

@property (nonatomic, strong) SJVideoPlayer *videoPlayer;

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // create video player
    _videoPlayer = [SJVideoPlayer new];
    [self.view addSubview:_videoPlayer.view];
    [_videoPlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(SJ_is_iPhoneX() ? 44 : 20);
        make.leading.trailing.offset(0);
        make.height.equalTo(_videoPlayer.view.mas_width).multipliedBy(9/16.0f);
    }];
    
    // video asset
    _videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithTitle:@"DIY #平遥牛肉##精品#" alwaysShowTitle:YES assetURL:[NSURL URLWithString:@"http://vod.lanwuzhe.com/b12ad5034df14bedbdf0e5654cbf7224/6fc3ba23d31743ea8b3c0192c1b83f86-5287d2089db37e62345123a1be272f8b.mp4?video="]];

    self.view.backgroundColor = [UIColor whiteColor];
    
    
    SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
        commonSettings.placeholder = [UIImage imageNamed:@"placeholder"];
    });
    
    [self _setPlayerMoreSettingItems];
    
    // Do any additional setup after loading the view.
}

- (void)clickedBackBtnOnControlView:(SJVideoPlayerControlView *)controlView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 配置`更多页面`展示的`item`
- (void)_setPlayerMoreSettingItems {
    
    __weak SJVideoPlayer *videoPlayer  = _videoPlayer;
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
@end


//    _videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[NSURL URLWithString:@"http://vod.lanwuzhe.com/b12ad5034df14bedbdf0e5654cbf7224/6fc3ba23d31743ea8b3c0192c1b83f86-5287d2089db37e62345123a1be272f8b.mp4?video="]];
//    _videoPlayer.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithAssetURL:[NSURL URLWithString:@"http://blurdancer-video.oss-cn-shanghai.aliyuncs.com/usertrend/120718-1515947072.mp4"]];
