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

#import "SJVideoPlayerMoreSetting.h"

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    SJVideoPlayer *player = [SJVideoPlayer sharedPlayer];
    [self.view addSubview:player.view];
    
    
//    player.assetURL = [[NSBundle mainBundle] URLForResource:@"sample.mp4" withExtension:nil];
//    player.assetURL = [NSURL URLWithString:@"http://streaming.youku.com/live2play/gtvyxjj_yk720.m3u8?auth_key=1525831956-0-0-4ec52cd453761e1e7f551decbb3eee6d"];
    
    player.assetURL = [NSURL URLWithString:@"http://vod.lanwuzhe.com/9a86250dbcdd4bc58489e723838839b6/fefd3e2d0bd54a50a5a02fbaf7161c8f-5287d2089db37e62345123a1be272f8b.mp4?video"];
    
//    player.assetURL = [NSURL URLWithString:@"http://vod.lanwuzhe.com/9da7002189d34b60bbf82ac743241a61/d0539e7be21a4f8faa9fef69a67bc1fb-5287d2089db37e62345123a1be272f8b.mp4?video="];
    
    [player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(64);
        make.leading.trailing.offset(0);
        make.height.equalTo(player.view.mas_width).multipliedBy(9.0 / 16.0);
    }];
    
    
    
    player.placeholder = [UIImage imageNamed:@"sj_video_player_placeholder"];
    
    
    SJVideoPlayerMoreSetting.titleFontSize = 12;
    
    SJVideoPlayerMoreSetting *model0 = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"点赞" image:[UIImage imageNamed:@"db_video_like_n"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        NSLog(@"clicked %@", model.title);
    }];
    
    SJVideoPlayerMoreSetting *model1 = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"缓存" image:[UIImage imageNamed:@"db_audio_play_download_n"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        NSLog(@"clicked %@", model.title);
    }];
    
    SJVideoPlayerMoreSetting *model2 = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"收藏" image:[UIImage imageNamed:@"db_video_favorite_n"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        NSLog(@"clicked %@", model.title);
    }];
    
    SJVideoPlayerMoreSetting *model3 = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"分享" image:[UIImage imageNamed:@"db_audio_play_share_n"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        NSLog(@"clicked %@", model.title);
    }];
    
    player.moreSettings = @[model0, model1, model2, model3];
    
    __weak typeof(self) _self = self;
    player.clickedBackEvent = ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.navigationController popViewControllerAnimated:YES];
    };
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    [[SJVideoPlayer sharedPlayer] stop];
}

@end
