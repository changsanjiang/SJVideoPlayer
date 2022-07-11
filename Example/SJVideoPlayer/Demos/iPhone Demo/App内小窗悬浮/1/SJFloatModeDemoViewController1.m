//
//  SJFloatModeDemoViewController1.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2021/1/14.
//  Copyright © 2021 changsanjiang. All rights reserved.
//

#import "SJFloatModeDemoViewController1.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#import "SJSourceURLs.h"
#import "SJFloatSmallViewTransitionController.h"

@interface SJFloatModeDemoViewController1 ()
@property (nonatomic, strong) SJVideoPlayer *player;
@property (nonatomic) NSInteger videoId;
@end

@implementation SJFloatModeDemoViewController1
// step 1
+ (instancetype)viewControllerWithVideoId:(NSInteger)videoId {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    SJFloatModeDemoViewController1 *instance = nil;
    // compare videoId
    // 比较videoId, 确认是否正在悬浮播放
    for ( __kindof UIViewController *vc in window.SVTC_playbackInFloatingViewControllers ) {
        if ( [vc isKindOfClass:SJFloatModeDemoViewController1.class] ) {
            SJFloatModeDemoViewController1 *playbackViewController = vc;
            if ( playbackViewController.videoId == videoId ) {
                instance = playbackViewController;
                break;
            }
        }
    }
    
    if ( instance == nil ) {
        instance = [SJFloatModeDemoViewController1.alloc initWithVideoId:videoId];
    }
    return instance;
}

- (instancetype)initWithVideoId:(NSInteger)videoId {
    self = [super init];
    if ( self ) {
        _videoId = videoId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    _player = SJVideoPlayer.player;
    _player.resumePlaybackWhenAppDidEnterForeground = YES;
    _player.defaultEdgeControlLayer.fixesBackItem = YES;
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0];
    if (@available(iOS 14.0, *)) {
        _player.defaultEdgeControlLayer.automaticallyShowsPictureInPictureItem = NO;
    }
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.offset(20);
        }
        make.left.right.offset(0);
        make.height.equalTo(self.view.mas_width).multipliedBy(9/16.0);
    }];

    // step 2
    SJFloatSmallViewTransitionController *floatSmallViewTransitionController = SJFloatSmallViewTransitionController.alloc.init;
    // 退出vc时, 是否自动进入小浮窗模式
    floatSmallViewTransitionController.automaticallyEnterFloatingMode = YES;
    _player.floatSmallViewController = floatSmallViewTransitionController;
    __weak typeof(self) _self = self;
    _player.floatSmallViewController.onDoubleTapped = ^(id<SJFloatSmallViewController>  _Nonnull controller) {
        __strong typeof(_self) self = _self;
        if ( self == nil ) return;
        self.player.isPaused ? [self.player play] : [self.player pause];
    };
    
    // 添加播放按钮到小浮窗控制层
    SJEdgeControlButtonItem *playItem = [SJEdgeControlButtonItem.alloc initWithTag:101];
    [playItem addAction:[SJEdgeControlButtonItemAction actionWithTarget:self action:@selector(playOrPause)]];
    [_player.defaultFloatSmallViewControlLayer.bottomAdapter addItem:playItem];
    _player.defaultFloatSmallViewControlLayer.bottomHeight = 35;
    _player.playbackObserver.playbackStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( self == nil ) return;
        [self _updatePlayItemForFloatSmallViewControlLayer];
    };
    [self _updatePlayItemForFloatSmallViewControlLayer];

    // 手动进入
    SJEdgeControlButtonItem *fsItem = [SJEdgeControlButtonItem.alloc initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"点击此处手动进入小浮窗模式");
        make.font([UIFont boldSystemFontOfSize:20]);
        make.textColor(UIColor.whiteColor);
    }] target:self action:@selector(enterFloatMode) tag:123];
    [_player.defaultEdgeControlLayer.centerAdapter addItem:fsItem];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"Next VC" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(pushToNextVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
}

- (void)pushToNextVC {
    UIViewController *vc = [UIViewController.alloc init];
    vc.view.backgroundColor = UIColor.whiteColor;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // step 3
    _player.vc_isDisappeared = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // step 4
    _player.vc_isDisappeared = YES;
}

// step 5
- (SJFloatSmallViewTransitionController *)floatSmallViewTransitionController {
    return (id)_player.floatSmallViewController;
}

#pragma mark - test
// 手动进入
- (void)enterFloatMode {
    __weak typeof(self) _self = self;
    if      ( _player.isFullscreen ) {
        [_player rotate:SJOrientation_Portrait animated:YES completion:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
            if ( !self.floatSmallViewTransitionController.automaticallyEnterFloatingMode ) [player.floatSmallViewController showFloatView];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else if ( _player.isFitOnScreen ) {
        [_player setFitOnScreen:NO animated:YES completionHandler:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
            __strong typeof(_self) self = _self;
            if ( self == nil ) return;
            if ( !self.floatSmallViewTransitionController.automaticallyEnterFloatingMode ) [player.floatSmallViewController showFloatView];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else {
        if ( !self.floatSmallViewTransitionController.automaticallyEnterFloatingMode ) [_player.floatSmallViewController showFloatView];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
 
- (void)_updatePlayItemForFloatSmallViewControlLayer {
    SJEdgeControlButtonItem *playItem = [_player.defaultFloatSmallViewControlLayer.bottomAdapter itemForTag:101];
    playItem.image = self.player.isPaused ? SJVideoPlayerConfigurations.shared.resources.playImage : SJVideoPlayerConfigurations.shared.resources.pauseImage;
    [self.player.defaultFloatSmallViewControlLayer.bottomAdapter reload];
}

- (void)playOrPause {
    self.player.isPaused ? [self.player play] : [self.player pauseForUser];
}
@end
