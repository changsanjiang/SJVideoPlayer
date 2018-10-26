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
#import <SJAttributeWorker.h>
#import "SJMoreSettingControlLayer.h"

#import "SJEdgeControlLayerNew.h"

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
    
//    SJEdgeControlLayerNew *controlLayer = [SJEdgeControlLayerNew new];
//    SJControlLayerCarrier *carrier = [[SJControlLayerCarrier alloc] initWithIdentifier:SJControlLayer_Edge dataSource:controlLayer delegate:controlLayer exitExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
//        [controlLayer exitControlLayerCompeletionHandler:nil];
//    } restartExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
//        [controlLayer restartControlLayerCompeletionHandler:nil];
//    }];
//    [self.player.switcher addControlLayer:carrier];
//
//
//    controlLayer.bottomAdapter.view.backgroundColor = [UIColor redColor];
//
//
    
    SJEdgeControlLayerNew *controlLayer = (id)[_player.switcher controlLayerForIdentifier:SJControlLayer_Edge].dataSource;
    
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
    
    
    
    SJMoreSettingControlLayer *more = [[SJMoreSettingControlLayer alloc] init];
    SJControlLayerCarrier *more_c = [[SJControlLayerCarrier alloc] initWithIdentifier:SJControlLayer_MoreSettting dataSource:more delegate:more exitExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [more exitControlLayer];
    } restartExeBlock:^(SJControlLayerCarrier * _Nonnull carrier) {
        [more restartControlLayer];
    }];
    [_player.switcher addControlLayer:more_c];
    
    __weak typeof(self) _self = self;
    more.disappearExeBlock = ^(SJMoreSettingControlLayer * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.player.switcher switchToPreviousControlLayer];
    };
    
    
    
    SJVideoPlayerMoreSetting *mm = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"测试" image:[UIImage imageNamed:@"avatar"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
#ifdef DEBUG
        NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    }];
    
    
    SJVideoPlayerMoreSetting *mm1 = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"测试2" image:[UIImage imageNamed:@"avatar"] showTowSetting:YES twoSettingTopTitle:@"测试二级标题" twoSettingItems:@[[[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"二级" image:[UIImage imageNamed:@"avatar"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
#ifdef DEBUG
        NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    }]] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
#ifdef DEBUG
        NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    }];
    
    more.moreSettings = @[mm, mm1];
    
    _player.moreSettings = @[mm, mm1];
    // Do any additional setup after loading the view.
}

- (void)test {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    
    [_player.switcher switchControlLayerForIdentitfier:SJControlLayer_MoreSettting];
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
        else make.top.offset(0);
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
