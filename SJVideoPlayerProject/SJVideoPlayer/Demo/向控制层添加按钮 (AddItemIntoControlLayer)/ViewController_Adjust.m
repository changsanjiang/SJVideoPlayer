//
//  ViewController_Adjust.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/27.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewController_Adjust.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>
#import <SJAttributesFactory/SJAttributeWorker.h>


@interface ViewController_Adjust ()<SJRouteHandler>
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation ViewController_Adjust

+ (NSString *)routePath {
    return @"player/defaultPlayer/adjust";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    _player.pausedToKeepAppearState = YES;
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
    _player.URLAsset.title = @"Test Title";
    
    
    
    [_player showTitle:@"当前Demo为: 调整 item 的位置" duration:-1];
    
    
    [UIScrollView.new setContentOffset:CGPointMake(0, 0) animated:YES];
    
    // 这里调整 时间进度为例
    
    // 移除 separator
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_Separator];
    
    // 将 时长 移动到 进度条后面
    [_player.defaultEdgeControlLayer.bottomAdapter exchangeItemForTag:SJEdgeControlLayerBottomItem_DurationTime withItemForTag:SJEdgeControlLayerBottomItem_Progress];
    
    [_player.defaultEdgeControlLayer.bottomAdapter reload];
    
    _player.defaultEdgeControlLayer.bottomContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
}


#pragma mark -
- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // create a player of the default type
    _player = [SJVideoPlayer player];
    
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        else make.top.offset(0);
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_player.view.mas_width).multipliedBy(9 / 16.0f);
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
