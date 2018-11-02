//
//  ViewControllerTestPresent.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/28.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerTestPresent.h"
#import "SJVideoPlayer.h"
#import <Masonry/Masonry.h>

@interface ViewControllerTestPresent ()
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation ViewControllerTestPresent

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // create a player of the default type
    _player = [SJVideoPlayer player];
    
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        if (@available(iOS 11.0, *)) make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
//        else make.top.offset(0);
//        make.leading.trailing.offset(0);
//        make.height.equalTo(self->_player.view.mas_width).multipliedBy(9 / 16.0f);
        make.edges.offset(0);
    }];
    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
    _player.URLAsset.title = @"Test Title";
    _player.URLAsset.alwaysShowTitle = YES;
    _player.hideBackButtonWhenOrientationIsPortrait = YES;
    _player.enableFilmEditing = YES;
    _player.pausedToKeepAppearState = YES;
    _player.generatePreviewImages = YES;
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player vc_viewDidDisappear];
}

- (BOOL)prefersStatusBarHidden {
    return [self.player vc_prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.player vc_preferredStatusBarStyle];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

@end
