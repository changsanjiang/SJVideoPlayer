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
#import "SJEdgeControlLayerAdapters.h"
#import <SJAttributeWorker.h>
#import "SJMoreSettingControlLayer.h"

#import "SJEdgeControlLayer.h"
#import "SJLoadFailedControlLayer.h"
#import <NSObject+SJObserverHelper.h>
#import "ViewControllerTestPresent.h" 

@interface ViewControllerTest ()<SJRouteHandler, SJEdgeControlButtonItemDelegate>
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
    
    [self _addControlLayerToSwitcher];
    
    SJEdgeControlLayer *controlLayer = (id)[_player.switcher controlLayerForIdentifier:SJControlLayer_Edge].controlLayer;
    /// test
    SJEdgeControlButtonItem *testItem = [SJEdgeControlButtonItem placeholderWithSize:49 tag:0];
    testItem.title = sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        make.append(@"测试");
    });
    testItem.delegate = self;
    [controlLayer.rightAdapter addItem:testItem];
    [controlLayer.rightAdapter reload];

    [testItem addTarget:self action:@selector(test)];
    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
    _player.URLAsset.title = @"Test Title Test TitlTest Title Test Title";
    _player.URLAsset.alwaysShowTitle = YES;
    _player.enableFilmEditing = YES;
    
    
    
    SJVideoPlayerMoreSetting *mm = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"测试" image:[UIImage imageNamed:@"avatar"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
#ifdef DEBUG
        NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    }];
    
    SJVideoPlayerMoreSetting *mm1 = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"测试2" image:[UIImage imageNamed:@"avatar"] showTowSetting:YES twoSettingTopTitle:@"测试二级标题" twoSettingItems:@[mm, mm, mm, mm, mm, [[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"二级" image:[UIImage imageNamed:@"avatar"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
#ifdef DEBUG
        NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    }]] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
#ifdef DEBUG
        NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    }];
    
    _player.moreSettings = @[mm, mm1];
    

    // Do any additional setup after loading the view.
}

- (void)_addControlLayerToSwitcher {
//    SJLoadFailedControlLayer *controlLayer = [SJLoadFailedControlLayer new];
//    SJControlLayerCarrier *carrier = [[SJControlLayerCarrier alloc] initWithIdentifier:111 dataSource:controlLayer delegate:controlLayer exitExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
//        [controlLayer exitControlLayer];
//    } restartExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
//        [controlLayer restartControlLayer];
//    }];
//
//    [_player.switcher addControlLayer:carrier];
}

- (void)test {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    
//    [_player showTitle:@"3秒后测试加载失败" duration:3];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:@"http://www.tetet.com"]];
//    });
  
//    [_player showTitle:@"3秒后测试充满屏幕的情况" duration:3];
//    [self presentViewController:[ViewControllerTestPresent new] animated:YES completion:nil];
    
    [_player switchVideoDefinitionByURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
}

/// test
- (void)updatePropertiesIfNeeded:(SJEdgeControlButtonItem *)item videoPlayer:(__kindof SJBaseVideoPlayer *)player {
    item.customView.backgroundColor = player.isFullScreen?[UIColor yellowColor]:[UIColor orangeColor];
}

- (void)_setupViews {
    // create a player of the default type
    _player = [SJVideoPlayer player];
    
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        else make.top.offset(20);
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_player.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
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
