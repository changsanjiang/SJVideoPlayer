//
//  ViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "ViewController.h"

#import "SJVideoPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SJVideoPlayer *player = [SJVideoPlayer sharedPlayer];
    
    player.assetURL = [NSURL URLWithString:@"http://vod.lanwuzhe.com/615388f2b38c4fc8b3d3c621939762c4/3fe91db43dc84353b9bb3f9623e7784f-5287d2089db37e62345123a1be272f8b.mp4?video="];
    
    [self.view addSubview:player.view];
    
    player.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 9 / 16);
    
    player.view.center = self.view.center;
    
    // Do any additional setup after loading the view, typically from a nib.
}


@end
