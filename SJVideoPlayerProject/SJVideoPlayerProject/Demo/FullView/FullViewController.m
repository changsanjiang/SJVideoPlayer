//
//  FullViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/23.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "FullViewController.h"
#import "SJVideoPlayer.h"
#import <SJUIFactory/SJUIFactory.h>
#import <Masonry.h>

@interface FullViewController ()

@end

@implementation FullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:[SJVideoPlayer sharedPlayer].view];
    [[SJVideoPlayer sharedPlayer].view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(SJ_is_iPhoneX() ? 34 : 20);
        make.leading.trailing.offset(0);
        make.height.equalTo([SJVideoPlayer sharedPlayer].view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    // 播放
    [SJVideoPlayer sharedPlayer].assetURL = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"];
    
    // supported orientation. 设置旋转支持的方向.
    [SJVideoPlayer sharedPlayer].supportedRotateViewOrientation = SJSupportedRotateViewOrientation_All;
    
    // 将播放器旋转成横屏.(因为播放器默认是竖屏的)
    [SJVideoPlayer sharedPlayer].rotateOrientation = SJRotateViewOrientation_LandscapeLeft; // 请注意: 是`SJRotateViewOrientation_LandscapeLeft` 而不是 `SJSupportedRotateViewOrientation_LandscapeLeft`
    
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    [[SJVideoPlayer sharedPlayer] stop];
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
