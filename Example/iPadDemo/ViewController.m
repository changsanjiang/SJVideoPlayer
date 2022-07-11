//
//  ViewController.m
//  iPadDemo
//
//  Created by 畅三江 on 2022/7/11.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "ViewController.h"
#import "SJVideoPlayer.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *playerSuperview;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _player = [SJVideoPlayer player];
    _player.onlyFitOnScreen = YES;
    
    SJVideoPlayerURLAsset *asset = [SJVideoPlayerURLAsset.alloc initWithURL:[NSURL URLWithString:@"https://dh2.v.netease.com/2017/cg/fxtpty.mp4"]];
    asset.title = @"标题 标题 标题 标题 标题 标题 标题 标题 标题 标题 标题";
    _player.URLAsset = asset;
    
    _player.view.frame = _playerSuperview.bounds;
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_playerSuperview addSubview:_player.view];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _player.isFitOnScreen ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    if ( !_player.fitOnScreenManager.isTransitioning && _player.isFitOnScreen ) {
        return !_player.controlLayerAppearManager.isAppeared;
    }
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_player vc_viewDidDisappear];
}
@end

@implementation UINavigationController (StatusBarConfiguration)
- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}
@end

