//
//  VideoPlayerViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/23.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "VideoPlayerViewController.h"

#import "SJVideoPlayer.h"

#import <Masonry.h>

@interface VideoPlayerViewController ()

@property (nonatomic, assign, readwrite) NSTimeInterval currentTime;

@end

@implementation VideoPlayerViewController

// MARK: 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
// MARK: Player View

    SJVideoPlayer *player = [SJVideoPlayer sharedPlayer];
    [self.view addSubview:player.view];
    [player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.leading.trailing.offset(0);
        make.height.equalTo(player.view.mas_width).multipliedBy(9.0 / 16.0);
    }];

    
// MARK: AssetURL
    
//    player.assetURL = [[NSBundle mainBundle] URLForResource:@"sample.mp4" withExtension:nil];

//    player.assetURL = [NSURL URLWithString:@"http://streaming.youku.com/live2play/gtvyxjj_yk720.m3u8?auth_key=1525831956-0-0-4ec52cd453761e1e7f551decbb3eee6d"];
    
//    player.assetURL = [NSURL URLWithString:@"http://video.cdn.lanwuzhe.com/1493370091000dfb1"];
    
    player.assetURL = [NSURL URLWithString:@"http://vod.lanwuzhe.com/9da7002189d34b60bbf82ac743241a61/d0539e7be21a4f8faa9fef69a67bc1fb-5287d2089db37e62345123a1be272f8b.mp4?video="];
    

// MARK: Setting Player
    
    [player playerSettings:^(SJVideoPlayerSettings * _Nonnull settings) {
        settings.traceColor = [UIColor colorWithRed:1.0 * (arc4random() % 256 / 255.0)
                                              green:1.0 * (arc4random() % 256 / 255.0)
                                               blue:1.0 * (arc4random() % 256 / 255.0)
                                              alpha:1];
        settings.trackColor = [UIColor colorWithRed:1.0 * (arc4random() % 256 / 255.0)
                                              green:1.0 * (arc4random() % 256 / 255.0)
                                               blue:1.0 * (arc4random() % 256 / 255.0)
                                              alpha:1];
        settings.bufferColor = [UIColor colorWithRed:1.0 * (arc4random() % 256 / 255.0)
                                               green:1.0 * (arc4random() % 256 / 255.0)
                                                blue:1.0 * (arc4random() % 256 / 255.0)
                                               alpha:1];
        settings.replayBtnTitle = @"播放完毕, 点击重播";
        settings.replayBtnFontSize = 12;
    }];
    
    
    
// MARK: Loading Placeholder
    
    player.placeholder = [UIImage imageNamed:@"sj_video_player_placeholder"];
    

    
// MARK: 1 Level More Settings

    SJVideoPlayerMoreSetting.titleFontSize = 12;

    SJVideoPlayerMoreSetting *model0 = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"点赞" image:[UIImage imageNamed:@"db_video_like_n"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        NSLog(@"clicked %@", model.title);
        [[SJVideoPlayer sharedPlayer] showTitle:@"超长震古烁今的名字"];
    }];
    
    
    SJVideoPlayerMoreSetting *model2 = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"收藏" image:[UIImage imageNamed:@"db_video_favorite_n"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        NSLog(@"clicked %@", model.title);
        [[SJVideoPlayer sharedPlayer] showTitle:model.title];
    }];

    
// MARK: 2 Level More Settings
    
    SJVideoPlayerMoreSettingTwoSetting *twoS0 = [[SJVideoPlayerMoreSettingTwoSetting alloc] initWithTitle:@"高清" image:nil clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [[SJVideoPlayer sharedPlayer] showTitle:model.title];
    }];
    
    SJVideoPlayerMoreSettingTwoSetting *twoS1 = [[SJVideoPlayerMoreSettingTwoSetting alloc] initWithTitle:@"标准" image:nil clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [[SJVideoPlayer sharedPlayer] showTitle:model.title];
    }];
    
// MARK: 1 Level More Settings
    
    SJVideoPlayerMoreSetting *model1 =
    [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"缓存"
                                              image:[UIImage imageNamed:@"db_audio_play_download_n"]
                                     showTowSetting:YES
                                    twoSettingTitle:@"缓存方式"
                                    twoSettingItems:@[twoS0, twoS1]
                                    clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {}];
    
    
// MARK: 2 Level More Settings
    
    SJVideoPlayerMoreSetting.twoTitleFontSize = 14;
    
    SJVideoPlayerMoreSettingTwoSetting *twoSetting0 = [[SJVideoPlayerMoreSettingTwoSetting alloc] initWithTitle:@"QQ" image:[UIImage imageNamed:@"db_login_qq"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [[SJVideoPlayer sharedPlayer] showTitle:model.title];
    }];
    
    SJVideoPlayerMoreSettingTwoSetting *twoSetting1 = [[SJVideoPlayerMoreSettingTwoSetting alloc] initWithTitle:@"微博" image:[UIImage imageNamed:@"db_login_weibo"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [[SJVideoPlayer sharedPlayer] showTitle:model.title];
    }];
    
    SJVideoPlayerMoreSettingTwoSetting *twoSetting2 = [[SJVideoPlayerMoreSettingTwoSetting alloc] initWithTitle:@"微信" image:[UIImage imageNamed:@"db_login_weixin"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [[SJVideoPlayer sharedPlayer] showTitle:model.title];
    }];
    
    SJVideoPlayerMoreSetting *model3 =
    [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"分享"
                                              image:[UIImage imageNamed:@"db_audio_play_share_n"]
                                     showTowSetting:YES
                                    twoSettingTitle:@"分享到"
                                    twoSettingItems:@[twoSetting0, twoSetting1, twoSetting2]  // 2级 Settings
                                    clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {}];
    
    [player moreSettings:^(NSMutableArray<SJVideoPlayerMoreSetting *> * _Nonnull moreSettings) {
        [moreSettings addObject:model0];
        [moreSettings addObject:model1];
        [moreSettings addObject:model2];
        [moreSettings addObject:model3];
    }];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
// MARK: Clicked Back Button
    __weak typeof(self) _self = self;
    [SJVideoPlayer sharedPlayer].clickedBackEvent = ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.navigationController popViewControllerAnimated:YES];
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[SJVideoPlayer sharedPlayer] jumpedToTime:self.currentTime completionHandler:^(BOOL finished) {
        [[SJVideoPlayer sharedPlayer] play];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    self.currentTime = [SJVideoPlayer sharedPlayer].currentTime;
    [[SJVideoPlayer sharedPlayer] pause];
}

- (void)dealloc {
    [[SJVideoPlayer sharedPlayer] stop];
}

@end
