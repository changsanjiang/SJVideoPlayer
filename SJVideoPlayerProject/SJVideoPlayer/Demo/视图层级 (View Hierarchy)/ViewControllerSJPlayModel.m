//
//  ViewControllerSJPlayModel.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerSJPlayModel.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>

@interface ViewControllerSJPlayModel ()<SJRouteHandler>
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation ViewControllerSJPlayModel

+ (NSString *)routePath {
    return @"view/playbackInfo";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _player = [SJVideoPlayer player];
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        else make.top.offset(0);
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_player.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    _player.assetURL = [NSURL URLWithString:@"https://www.apple.com/105/media/us/macbook-air/2018/9f419882_aefd_4083_902e_efcaee17a0b8/films/product/mba-product-tpl-cc-us-2018_1280x720h.mp4"];
    _player.URLAsset.title = @"Test Title";
    _player.enableFilmEditing = YES;
    
    
    UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [centerBtn addTarget:self action:@selector(clickedCenterBtn:) forControlEvents:UIControlEventTouchUpInside];
    [centerBtn setTitle:@"Push" forState:UIControlStateNormal];
    [self.view addSubview:centerBtn];
    centerBtn.backgroundColor = [UIColor blueColor];
    [centerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    // Do any additional setup after loading the view.
}

- (void)clickedCenterBtn:(UIButton *)btn {
    [self.navigationController pushViewController:[[self class] new] animated:YES];
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
