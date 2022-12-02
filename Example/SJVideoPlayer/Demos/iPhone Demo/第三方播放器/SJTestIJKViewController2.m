//
//  SJTestViewController2.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/10/12.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJTestIJKViewController2.h"
#import "SJSourceURLs.h"
#import "SJVideoPlayer.h"
#import "Masonry.h"
#import <SJUIKit/NSAttributedString+SJMake.h>

#if __has_include(<PodIJKPlayer/PodIJKPlayer.h>)
#import "SJIJKMediaPlaybackController.h"
#import <PodIJKPlayer/PodIJKPlayer.h>
#endif

@interface SJTestIJKViewController2 ()
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJTestIJKViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    _player = SJVideoPlayer.player;
#if __has_include(<PodIJKPlayer/PodIJKPlayer.h>)
    SJIJKMediaPlaybackController *controller = SJIJKMediaPlaybackController.new;
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    controller.options = options;
    _player.playbackController = controller;
    SJVideoPlayerURLAsset *asset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0];
//    asset.trialEndPosition = 30; // 试看30秒
    _player.URLAsset = asset;
#else
    // 切换为 ijkplayer, 详见: https://github.com/changsanjiang/SJVideoPlayer/wiki/Use-ijkplayer
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"请按照指南导入ijkplayer");
        make.textColor(UIColor.whiteColor);
    }] duration:-1];
#endif
    
    [_player.controlLayerAppearManager keepAppearState];
    _player.controlLayerAppearManager.disabled = YES;
    
    __weak typeof(self) _self = self;
    _player.gestureController.singleTapHandler = ^(id<SJGestureController>  _Nonnull control, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self.player rotate];
    };
        
    _player.view.backgroundColor = UIColor.blackColor;
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(100);
        make.left.right.offset(0);
        make.height.equalTo(self.player.view.mas_width).multipliedBy(9/16.0);
    }];
}
- (IBAction)seek:(id)sender {
    [_player seekToTime:_player.currentTime + 60 completionHandler:^(BOOL finished) {}];
}
- (IBAction)play:(id)sender {
    [_player play];
}
- (IBAction)pause:(id)sender {
    [_player pause];
}
- (IBAction)next:(id)sender {
//    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:VideoURL_Level1];
    
    [_player refresh];
}



- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_player vc_viewDidDisappear];
}
@end

#pragma mark -

#import <SJRouter/SJRouter.h>

@interface SJTestIJKViewController2 (RouteHandler)<SJRouteHandler>
@end

@implementation SJTestIJKViewController2 (RouteHandler)
+ (NSString *)routePath {
    return @"thirdpartyPlayer/ijkplayer";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:SJTestIJKViewController2.new animated:YES];
}
@end
