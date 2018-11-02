//
//  ViewControllerTestAlert.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/11/2.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerTestAlert.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>
#import <SJAttributesFactory/SJAttributeWorker.h>
#import <SJBaseVideoPlayer/SJVCRotationManager.h>

@interface ViewControllerTestAlert ()<SJRouteHandler>
@property (nonatomic, strong) SJVideoPlayer *player;
@property (nonatomic, strong) SJVCRotationManager *rotationManager;
@end

@implementation ViewControllerTestAlert

+ (NSString *)routePath {
    return @"player/defaultPlayer/testAlert";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupViews];
  
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
    _player.URLAsset.title = @"Test Title";
    _player.URLAsset.alwaysShowTitle = YES;
    _player.hideBackButtonWhenOrientationIsPortrait = YES;
    _player.enableFilmEditing = YES;
    _player.pausedToKeepAppearState = YES;
    _player.generatePreviewImages = YES;
    
    
    /// 使用 旋转vc管理器
    _rotationManager = [[SJVCRotationManager alloc] initWithViewController:self];
    _player.rotationManager = _rotationManager;
    
    __weak typeof(self) _self = self;
    _player.viewWillRotateExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.navigationController setNavigationBarHidden:isFullScreen animated:NO];
    };
    
    
    SJEdgeControlButtonItem *testItem = [SJEdgeControlButtonItem placeholderWithSize:49 tag:0];
    testItem.title = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        make.append(@"TTest").font([UIFont boldSystemFontOfSize:14]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
    });
    [testItem addTarget:self action:@selector(clickedTestItem:)];

    [_player.defaultEdgeControlLayer.rightAdapter addItem:testItem];
    
}

- (void)clickedTestItem:(SJEdgeControlButtonItem *)item {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"测试 弹窗" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"TTTT" style:0 handler:^(UIAlertAction * _Nonnull action) {
#ifdef DEBUG
        NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif

    }]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

#pragma mark -
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [_rotationManager vc_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (BOOL)shouldAutorotate {
    if ( self.presentedViewController )
        return NO;
    return [self.rotationManager vc_shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ( self.presentedViewController ) {
        switch ( _player.currentOrientation ) {
            case UIInterfaceOrientationPortrait:
                return UIInterfaceOrientationMaskPortrait;
            case UIInterfaceOrientationLandscapeLeft:
                return UIInterfaceOrientationMaskLandscapeLeft;
            case UIInterfaceOrientationLandscapeRight:
                return UIInterfaceOrientationMaskLandscapeRight;
            default: break;
        }
    }
    return [self.rotationManager vc_supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if ( self.presentedViewController ) return _player.currentOrientation;
    return [self.rotationManager vc_preferredInterfaceOrientationForPresentation];
}

#pragma mark - setup views
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
