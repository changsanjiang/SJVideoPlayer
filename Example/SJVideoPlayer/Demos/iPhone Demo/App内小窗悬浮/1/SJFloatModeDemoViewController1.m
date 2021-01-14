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
#import "SJSourceURLs.h"
#import "SJFloatSmallViewTransitionController.h"

@interface SJFloatModeDemoViewController1 ()
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJFloatModeDemoViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    _player = SJVideoPlayer.player;
    _player.resumePlaybackWhenAppDidEnterForeground = YES;
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

    // step 1
    _player.floatSmallViewController = SJFloatSmallViewTransitionController.alloc.init;
    __weak typeof(self) _self = self;
    _player.floatSmallViewController.doubleTappedOnTheFloatViewExeBlock = ^(id<SJFloatSmallViewController>  _Nonnull controller) {
        __strong typeof(_self) self = _self;
        if ( self == nil ) return;
        self.player.isPaused ? [self.player play] : [self.player pause];
    };
}

// step 2
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
    // step 3
    _player.vc_isDisappeared = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // step 4
    _player.vc_isDisappeared = YES;
}
@end
