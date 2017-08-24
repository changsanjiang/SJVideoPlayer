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

@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    SJVideoPlayer *player = [SJVideoPlayer sharedPlayer];
    
//    player.assetURL = [[NSBundle mainBundle] URLForResource:@"sample.mp4" withExtension:nil];
    
//    player.assetURL = [NSURL URLWithString:@"http://streaming.youku.com/live2play/gtvyxjj_yk720.m3u8?auth_key=1525831956-0-0-4ec52cd453761e1e7f551decbb3eee6d"];
    
    player.assetURL = [NSURL URLWithString:@"http://vod.lanwuzhe.com/8487796e6c854e74ba34c835e7f5146b/0ec79c330be34c27b118c8560f142178-5287d2089db37e62345123a1be272f8b.mp4?video="];
    
    [self.view addSubview:player.view];
    
    [player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(64);
        make.leading.trailing.offset(0);
        make.height.equalTo(player.view.mas_width).multipliedBy(9.0 / 16.0);
    }];
    
    // Do any additional setup after loading the view.
}

@end
