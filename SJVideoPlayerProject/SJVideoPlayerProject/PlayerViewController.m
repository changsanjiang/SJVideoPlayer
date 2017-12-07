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


#define Player  [SJVideoPlayer sharedPlayer]

@interface PlayerViewController ()

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:Player.view];
    [Player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.leading.trailing.offset(0);
        make.height.equalTo(Player.view.mas_width).multipliedBy(9.0f / 16);
    }];
    
    Player.placeholder = [UIImage imageNamed:@"test"];
//    http://video.cdn.lanwuzhe.com/1493370091000dfb1
//    http://vod.lanwuzhe.com/d09d3a5f9ba4491fa771cd63294ad349%2F0831eae12c51428fa7aed3825c511370-5287d2089db37e62345123a1be272f8b.mp4
//    Player.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:[[NSBundle mainBundle] URLForResource:@"sample.mp4" withExtension:nil] beginTime:10];
    
    Player.asset = [[SJVideoPlayerAssetCarrier alloc] initWithAssetURL:[NSURL URLWithString:@"http://vod.lanwuzhe.com/d09d3a5f9ba4491fa771cd63294ad349%2F0831eae12c51428fa7aed3825c511370-5287d2089db37e62345123a1be272f8b.mp4"] beginTime:10];
    __weak typeof(self) _self = self;
    Player.clickedBackEvent = ^(SJVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [Player stop];
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    [self _setPlayerMoreSettingItems];
    
    // Do any additional setup after loading the view.
}

- (void)_setPlayerMoreSettingItems {
    
    SJVideoPlayerMoreSettingSecondary *QQ = [[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"" image:[UIImage imageNamed:@"qq"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"分享到QQ"];
    }];
    
    SJVideoPlayerMoreSettingSecondary *wechat = [[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"" image:[UIImage imageNamed:@"wechat"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"分享到wechat"];
    }];
    
    SJVideoPlayerMoreSettingSecondary *weibo = [[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"" image:[UIImage imageNamed:@"weibo"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"分享到weibo"];
    }];
    
    SJVideoPlayerMoreSetting *share = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"share" image:[UIImage imageNamed:@"share"] showTowSetting:YES twoSettingTopTitle:@"shareTitle" twoSettingItems:@[QQ, wechat, weibo] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"clicked Share"];
    }];
    
//    shareItem.twoSettingItems
    Player.moreSettings = @[share];
}

- (void)dealloc {
    [Player stop];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
