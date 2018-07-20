//
//  FitOnScreenDemoViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/7/20.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "FitOnScreenDemoViewController.h"
#import "SJVideoPlayer.h"
#import <Masonry.h>

@interface FitOnScreenDemoViewController ()
@property (nonatomic, strong) SJVideoPlayer *player;

@property (nonatomic, strong) UIButton *button;

@end

@implementation FitOnScreenDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.title = @"Test Fit On Screen";
    [self.view addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    
    // player
    _player = [SJVideoPlayer player];
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.offset(0);
        }
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_player.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithTitle:self.title URL:[[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"] playModel:[SJPlayModel new]];
    
    
    // 全屏或小屏时, 禁止旋转
    _player.useFitOnScreenAndDisableRotation = YES;
    __weak typeof(self) _self = self;
    _player.fitOnScreenDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( player.isFitOnScreen ) {
            [self.button setTitle:@"充满屏幕" forState:UIControlStateNormal];
        }
        else {
            [self.button setTitle:@"返回小屏" forState:UIControlStateNormal];
        }
    };
    
    // Do any additional setup after loading the view.
}

- (UIButton *)button {
    if ( _button )  return _button;
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.backgroundColor = [UIColor blackColor];
    [_button setTitle:@"fit on screen" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
    return _button;
}

- (void)clickedButton:(UIButton *)btn {
    _player.fitOnScreen = !_player.fitOnScreen;
}

@end
