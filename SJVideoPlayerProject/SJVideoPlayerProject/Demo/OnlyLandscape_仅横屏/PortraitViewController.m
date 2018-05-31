//
//  PortraitViewController.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/5/30.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "PortraitViewController.h"
#import "LandscapeViewController.h"
#import <SJUIFactory.h>
#import <Masonry.h>

@interface PortraitViewController ()
@property (nonatomic, strong) UIButton *pushBtn;
@end

@implementation PortraitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _pushBtn = [SJUIButtonFactory buttonWithTitle:@"push"
                                       titleColor:[UIColor orangeColor]
                                             font:[UIFont boldSystemFontOfSize:20]
                                           target:self
                                              sel:@selector(clickedPushBtn)];
    [self.view addSubview:_pushBtn];
    
    [_pushBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickedPushBtn {
    [self.navigationController pushViewController:[LandscapeViewController new] animated:YES];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
@end
