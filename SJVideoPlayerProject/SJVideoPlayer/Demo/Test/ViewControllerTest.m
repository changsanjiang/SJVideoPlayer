//
//  ViewControllerTest.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/19.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerTest.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>
#import <SJFullscreenPopGesture/UIViewController+SJVideoPlayerAdd.h>
#import "SJEdgeControlLayerAdapters.h"

#import "SJEdgeControlLayerNew.h"

@interface ViewControllerTest ()<SJRouteHandler>
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation ViewControllerTest

+ (NSString *)routePath {
    return @"player/test";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self _setupViews];
    
    SJEdgeControlLayerNew *controlLayer = [SJEdgeControlLayerNew new];
    SJControlLayerCarrier *carrier = [[SJControlLayerCarrier alloc] initWithIdentifier:SJControlLayer_Edge dataSource:controlLayer delegate:controlLayer exitExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        
    } restartExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        
    }];
    [self.player.switcher addControlLayer:carrier];
    
    // Do any additional setup after loading the view.
}

- (void)_setupViews {
    // create a player of the default type
    _player = [SJVideoPlayer player];
    
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        else make.top.offset(0);
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_player.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
    _player.URLAsset.title = @"Test Title Test Title Test";
    _player.URLAsset.alwaysShowTitle = YES;
    _player.hideBackButtonWhenOrientationIsPortrait = YES;
    _player.enableFilmEditing = YES;
    _player.pausedToKeepAppearState = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
