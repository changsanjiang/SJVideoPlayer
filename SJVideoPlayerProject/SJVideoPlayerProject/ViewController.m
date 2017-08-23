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
    
//    player.assetURL = [[NSBundle mainBundle] URLForResource:@"sample.mp4" withExtension:nil];
    
    player.assetURL = [NSURL URLWithString:@"http://vod.lanwuzhe.com/9a86250dbcdd4bc58489e723838839b6/fefd3e2d0bd54a50a5a02fbaf7161c8f-5287d2089db37e62345123a1be272f8b.mp4?video"];
    
    [self.view addSubview:player.view];
    
    player.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 9 / 16);
    
    player.view.center = self.view.center;
    
    // Do any additional setup after loading the view, typically from a nib.
}


@end
