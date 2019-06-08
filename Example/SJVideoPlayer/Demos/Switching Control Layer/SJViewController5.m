//
//  SJViewController5.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/9.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController5.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/SJUIKit.h>
#import "SJSourceURLs.h"

@interface SJViewController5 ()
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJViewController5 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}
- (IBAction)switchToSJLoadFailedControlLayer:(id)sender {
    [_player.switcher switchControlLayerForIdentitfier:SJControlLayer_LoadFailed];
    
    [_player showTitle:@"已切换至 加载失败的控制层" duration:3];
    [_player controlLayerNeedAppear];
}

- (IBAction)swithToSJFilmEditingControlLayer:(id)sender {
    [_player.switcher switchControlLayerForIdentitfier:SJControlLayer_FilmEditing];
    
    [_player showTitle:@"已切换至 剪辑的控制层" duration:3];
    [_player controlLayerNeedAppear];
}

- (IBAction)switchTOSJFloatSmallViewControlLayer:(id)sender {
    [_player.switcher switchControlLayerForIdentitfier:SJControlLayer_FloatSmallView];
    
    [_player showTitle:@"已切换至 小浮窗的控制层 (注: 小浮窗控制层, 目前只有右上角一个按钮)" duration:3];
    [_player controlLayerNeedAppear];
}

- (IBAction)switchToSJMoreSettingControlLayer:(id)sender {
    [_player.switcher switchControlLayerForIdentitfier:SJControlLayer_MoreSettting];
    
    [_player showTitle:@"已切换至 more控制层" duration:3];
    [_player controlLayerNeedAppear];
}

- (IBAction)switchToSJNotReachableControlLayer:(id)sender {
    [_player.switcher switchControlLayerForIdentitfier:SJControlLayer_NotReachableAndPlaybackStalled];
    
    [_player showTitle:@"已切换至 无网无缓冲时的控制层" duration:3];
    [_player controlLayerNeedAppear];
}

- (IBAction)switchToSJEdgeControlLayer:(id)sender {
    [_player.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
    
    [_player showTitle:@"已切换至 默认边缘的控制层" duration:3];
    [_player controlLayerNeedAppear];
}

#pragma mark -

- (void)_setupViews {
     _player = [SJVideoPlayer player];
    _player.assetURL = SourceURL0;
    [_playerContainerView addSubview:self.player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
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


#import <SJRouter/SJRouter.h>
@interface SJViewController5 (RouteHandler)<SJRouteHandler>

@end

@implementation SJViewController5 (RouteHandler)

+ (NSString *)routePath {
    return @"controlLayer/switching";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJViewController5 alloc] initWithNibName:@"SJViewController5" bundle:nil] animated:YES];
}

@end
