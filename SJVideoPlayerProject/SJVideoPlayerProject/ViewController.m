//
//  ViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "ViewController.h"

#import "UIView+Extension.h"

#import <Masonry/Masonry.h>

#import "VideoPlayerViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *pushBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.pushBtn];
    
    [self.pushBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)clickedBtn:(UIButton *)btn {
    [self.navigationController pushViewController:[VideoPlayerViewController new] animated:YES];
}

- (UIButton *)pushBtn {
    if ( _pushBtn ) return _pushBtn;
    _pushBtn = [UIButton buttonWithTitle:@"Push" titleColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] tag:0 target:self sel:@selector(clickedBtn:) fontSize:14];
    return _pushBtn;
}

@end
