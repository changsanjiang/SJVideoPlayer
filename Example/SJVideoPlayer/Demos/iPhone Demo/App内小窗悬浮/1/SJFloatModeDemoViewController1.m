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
    
    [_player.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"点击返回按钮, 进入小浮窗模式");
        make.textColor(UIColor.whiteColor);
    }] duration:3];

    // step 2
    _player.floatSmallViewController = SJFloatSmallViewTransitionController.alloc.init;
    __weak typeof(self) _self = self;
    _player.floatSmallViewController.doubleTappedOnTheFloatViewExeBlock = ^(id<SJFloatSmallViewController>  _Nonnull controller) {
        __strong typeof(_self) self = _self;
        if ( self == nil ) return;
        self.player.isPaused ? [self.player play] : [self.player pause];
    };

    [self _test];
}

// step 3
- (SJFloatSmallViewTransitionController *_Nullable)SVTC_floatSmallViewTransitionController {
    return (SJFloatSmallViewTransitionController *)_player.floatSmallViewController;
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
    // step 4
    _player.vc_isDisappeared = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // step 5
    _player.vc_isDisappeared = YES;
}

#pragma mark - test

- (void)_test {
    _player.defaultFloatSmallViewControlLayer.bottomHeight = 35;
    
    SJEdgeControlButtonItem *playItem = [SJEdgeControlButtonItem.alloc initWithTag:101];
    [playItem addAction:[SJEdgeControlButtonItemAction actionWithTarget:self action:@selector(playOrPause)]];
    [_player.defaultFloatSmallViewControlLayer.bottomAdapter addItem:playItem];
    __weak typeof(self) _self = self;
    _player.playbackObserver.playbackStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( self == nil ) return;
        [self _updatePlayItem];
    };
    [self _updatePlayItem];
}

- (void)_updatePlayItem {
    SJEdgeControlButtonItem *playItem = [_player.defaultFloatSmallViewControlLayer.bottomAdapter itemForTag:101];
    playItem.image = self.player.isPaused ? SJVideoPlayerConfigurations.shared.resources.playImage : SJVideoPlayerConfigurations.shared.resources.pauseImage;
    [self.player.defaultFloatSmallViewControlLayer.bottomAdapter reload];
}

- (void)playOrPause {
    self.player.isPaused ? [self.player play] : [self.player pauseForUser];
}
@end
