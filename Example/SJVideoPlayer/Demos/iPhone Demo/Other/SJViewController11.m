//
//  SJViewController11.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/8/7.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController11.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/SJUIKit.h>
#import "SJSourceURLs.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJViewController11 ()
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJViewController11

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    // 开启左右边缘快进快退
    _player.fastForwardViewController.enabled = YES;
    _player.fastForwardViewController.blockColor = SJVideoPlayerSettings.commonSettings.progress_traceColor;
    [self _updateTriggerAreaWidth];
    __weak typeof(self) _self = self;
    _player.viewDidRotateExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player, BOOL isFullScreen) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateTriggerAreaWidth];
    };
}

- (void)_updateTriggerAreaWidth {
    CGRect bounds = UIScreen.mainScreen.bounds;
    CGFloat max = _player.isFullScreen ? MAX(CGRectGetWidth(bounds), CGRectGetHeight(bounds)) : MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds));

    CGFloat width = ceil(max * 0.18);
    _player.fastForwardViewController.triggerAreaWidth = width;
}

- (void)_setupViews {
    self.title = NSStringFromClass(self.class);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _player = [SJVideoPlayer player];
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:SourceURL3];
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
NS_ASSUME_NONNULL_END

#import <SJRouter/SJRouter.h>
@interface SJViewController11 (RouteHandler)<SJRouteHandler>

@end

@implementation SJViewController11 (RouteHandler)

+ (NSString *)routePath {
    return @"demo/11";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJViewController11 alloc] initWithNibName:@"SJViewController11" bundle:nil] animated:YES];
}

@end
