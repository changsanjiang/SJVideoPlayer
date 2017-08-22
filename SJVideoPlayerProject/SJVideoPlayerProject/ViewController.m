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
    
    player.assetURL = [[NSBundle mainBundle] URLForResource:@"sample.mp4" withExtension:nil];
    
    [self.view addSubview:player.view];
    
    player.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 9 / 16);
    
    player.view.center = self.view.center;
    
    // Do any additional setup after loading the view, typically from a nib.
}


@end
