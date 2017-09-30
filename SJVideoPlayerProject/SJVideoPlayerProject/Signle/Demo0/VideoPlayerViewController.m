//
//  VideoPlayerViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/23.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "SJPlayer.h"
#import <Masonry/Masonry.h>
#import "UIView+SJExtension.h"
#import "SJVideoPlayerMoreSetting.h"
#import "SJVideoPlayerMoreSettingTwoSetting.h"
#import "SJVideoPlayerSettings.h"
#import <Masonry.h>

@interface VideoPlayerViewController ()

@property (nonatomic, assign, readwrite) NSTimeInterval currentTime;

@property (nonatomic, strong, readonly) UIButton *switchVideoBtn1;
@property (nonatomic, strong, readonly) UIButton *switchVideoBtn2;

@end

@implementation VideoPlayerViewController

@synthesize switchVideoBtn1 = _switchVideoBtn1;
@synthesize switchVideoBtn2 = _switchVideoBtn2;

// MARK: 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.switchVideoBtn1];
    [_switchVideoBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.size.mas_offset(CGSizeMake(80, 30));
    }];
    
    [self.view addSubview:self.switchVideoBtn2];
    [_switchVideoBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_switchVideoBtn1.mas_bottom).offset(20);
        make.centerX.equalTo(_switchVideoBtn1);
        make.size.equalTo(_switchVideoBtn1);
    }];
    
    
#pragma mark - Player View

    SJVideoPlayer *player = [SJVideoPlayer sharedPlayer];
    [self.view addSubview:player.view];
    [player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.leading.trailing.offset(0);
        make.height.equalTo(player.view.mas_width).multipliedBy(9.0 / 16.0);
    }];

    
#pragma mark - AssetURL
    
//    player.assetURL = [[NSBundle mainBundle] URLForResource:@"sample.mp4" withExtension:nil];

//    player.assetURL = [NSURL URLWithString:@"http://streaming.youku.com/live2play/gtvyxjj_yk720.m3u8?auth_key=1525831956-0-0-4ec52cd453761e1e7f551decbb3eee6d"];
    
    player.assetURL = [NSURL URLWithString:@"http://video.cdn.lanwuzhe.com/1493370091000dfb1"];
    
//    player.assetURL = [NSURL URLWithString:@"http://vod.lanwuzhe.com/9da7002189d34b60bbf82ac743241a61/d0539e7be21a4f8faa9fef69a67bc1fb-5287d2089db37e62345123a1be272f8b.mp4?video="];
    

#pragma mark - Setting Player
    
    [player playerSettings:^(SJVideoPlayerSettings * _Nonnull settings) {
        settings.traceColor = [UIColor colorWithRed:arc4random() % 256 / 255.0
                                              green:arc4random() % 256 / 255.0
                                               blue:arc4random() % 256 / 255.0
                                              alpha:1];
        settings.trackColor = [UIColor colorWithRed:arc4random() % 256 / 255.0
                                              green:arc4random() % 256 / 255.0
                                               blue:arc4random() % 256 / 255.0
                                              alpha:1];
        settings.bufferColor = [UIColor colorWithRed:arc4random() % 256 / 255.0
                                               green:arc4random() % 256 / 255.0
                                                blue:arc4random() % 256 / 255.0
                                               alpha:1];
        settings.replayBtnTitle = @"播放完毕, 点击重播";
        settings.replayBtnFontSize = 12;
    }];
    
    
    
#pragma mark - Loading Placeholder
    
    player.placeholder = [UIImage imageNamed:@"sj_video_player_placeholder"];
    

    
#pragma mark - 1 Level More Settings

    SJVideoPlayerMoreSetting.titleFontSize = 12;

    SJVideoPlayerMoreSetting *model0 = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"点赞" image:[UIImage imageNamed:@"db_video_like_n"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        NSLog(@"clicked %@", model.title);
        [[SJVideoPlayer sharedPlayer] showTitle:@"超长震古烁今的名字"];
    }];
    
    
    SJVideoPlayerMoreSetting *model2 = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"收藏" image:[UIImage imageNamed:@"db_video_favorite_n"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        NSLog(@"clicked %@", model.title);
        [[SJVideoPlayer sharedPlayer] showTitle:model.title];
    }];

    
#pragma mark - 2 Level More Settings
    
    SJVideoPlayerMoreSettingTwoSetting *twoS0 = [[SJVideoPlayerMoreSettingTwoSetting alloc] initWithTitle:@"高清" image:nil clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [[SJVideoPlayer sharedPlayer] showTitle:model.title];
    }];
    
    SJVideoPlayerMoreSettingTwoSetting *twoS1 = [[SJVideoPlayerMoreSettingTwoSetting alloc] initWithTitle:@"标准" image:nil clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [[SJVideoPlayer sharedPlayer] showTitle:model.title];
    }];
    
#pragma mark - 1 Level More Settings
    
    SJVideoPlayerMoreSetting *model1 =
    [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"缓存"
                                              image:[UIImage imageNamed:@"db_audio_play_download_n"]
                                     showTowSetting:YES
                                 twoSettingTopTitle:@"缓存方式"
                                    twoSettingItems:@[twoS0, twoS1]
                                    clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {}];
    
    
#pragma mark - 2 Level More Settings
    
    SJVideoPlayerMoreSettingTwoSetting.topTitleFontSize = 14;
    
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
                                 twoSettingTopTitle:@"分享到"
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
    
    NSLog(@"%zd - %s", __LINE__, __func__);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    NSLog(@"%zd - %s", __LINE__, __func__);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.currentTime = [SJVideoPlayer sharedPlayer].currentTime;
    [[SJVideoPlayer sharedPlayer] stop];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%zd - %s", __LINE__, __func__);
}




// MARK: msg .....

- (void)clcikedswitchVideoBtn:(UIButton *)btn {
    NSURL *videoURL = nil;
    switch (btn.tag) {
        case 1:
            videoURL = [NSURL URLWithString:@"http://vod.lanwuzhe.com/f2c0582d9a184161891bd92c6c3a2df3/2f071a1b3c5d4e78bd213586d0a87244-5287d2089db37e62345123a1be272f8b.mp4?video="];
            break;
        case 2:
            videoURL = [NSURL URLWithString:@"http://video.cdn.lanwuzhe.com/usertrend/1506392730401800032.mp4"];
            break;
        default:
            break;
    }
    [[SJVideoPlayer sharedPlayer] setAssetURL:videoURL];
}

- (UIButton *)switchVideoBtn1 {
    if ( _switchVideoBtn1 ) return _switchVideoBtn1;
    _switchVideoBtn1 = [UIButton buttonWithTitle:@"切换1" backgroundColor:[UIColor clearColor] tag:1 target:self sel:@selector(clcikedswitchVideoBtn:) fontSize:14];
    [_switchVideoBtn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    return _switchVideoBtn1;
}

- (UIButton *)switchVideoBtn2 {
    if ( _switchVideoBtn2 ) return _switchVideoBtn2;
    _switchVideoBtn2 = [UIButton buttonWithTitle:@"切换2" backgroundColor:[UIColor clearColor] tag:2 target:self sel:@selector(clcikedswitchVideoBtn:) fontSize:14];
    [_switchVideoBtn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    return _switchVideoBtn2;
}
@end
