//
//  ViewControllerControlLayerSwitcherDemo.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/28.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerControlLayerSwitcherDemo.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>
#import "CustomControlLayerView.h"

@interface ViewControllerControlLayerSwitcherDemo ()<SJRouteHandler>
@property (nonatomic, strong) SJVideoPlayer *player;

@property (nonatomic, strong) CustomControlLayerView *testControlLayer;

@end

@implementation ViewControllerControlLayerSwitcherDemo

+ (NSString *)routePath {
    return @"player/defaultPlayer/switcher/replaceControlLayer";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    /// 控制层切换器
    /// 目前播放器存在 五种控制层, 分别如下:
    /// - 默认的边缘控制层
    /// - 默认的轻量级的边缘控制层
    /// - 默认的剪辑控制层
    /// - 默认的更多设置控制层
    /// - 默认的播放失败时的控制层
    /// 正常情况下, 切换器, 将会在这几种控制层之间来回切换.
    /// 例如, 播放失败时, 切换器将会切换到 播放失败的控制层.
    /// 另外, 这些控制层 只有在使用到的时候, 才会被创建. 也就是懒加载.
    
    
    
    [_player showTitle:@"当前Demo为: 切换器的使用之`添加或替换 控制层`" duration:-1];
    
    // 这里以 替换默认的边缘控制层为例, 将其替换为开发者自定义的控制层
    
    // - 1. 创建开发者自己的控制层
    _testControlLayer = [CustomControlLayerView new];
    
    // - 2. 我们将替换默认的边缘控制层, 所以 这里的 identifier 使用 `SJControlLayer_Edge`
    SJControlLayerCarrier *carrier = [[SJControlLayerCarrier alloc] initWithIdentifier:SJControlLayer_Edge controlLayer:_testControlLayer];
    
    // - 3. 下面这个方法是添加控制层到切换器中
    //   3.1 添加控制层后, 可以通过调用第四步的方法, 进行切换.
    // - 3.1 也可以通过这个方法, 替换掉原有的控制层.
    ///      切换器是通过 identifier 标识控制层的. 所以相同的控制层标识, 之前的将会被替换掉
    [_player.switcher addControlLayer:carrier];
    
    // 4. 切换到我们替换过来的控制层
    [_player.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
    
    
    
    
#pragma mark -
    // 有添加, 就得有删除, 下面就是删除切换器中存在的控制层
    // 当然, 如果删除的控制层, 当前正在使用, 为保持正常使用, 该控制层还会继续显示. 直到切换器, 切到别的控制层.
//    [_player.switcher deleteControlLayerForIdentifier:SJControlLayer_Edge];
    
    
    
    
    // Do any additional setup after loading the view.
}

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
    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
    _player.URLAsset.title = @"Test Title";
    _player.URLAsset.alwaysShowTitle = YES;
    _player.hideBackButtonWhenOrientationIsPortrait = YES;
    _player.enableFilmEditing = YES;
    _player.pausedToKeepAppearState = YES;
    _player.generatePreviewImages = YES;
    
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
