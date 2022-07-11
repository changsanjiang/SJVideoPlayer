//
//  SJTestPLPlayerViewController.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/2/20.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJTestPLPlayerViewController.h"
#import <Masonry/Masonry.h>
#import "SJSourceURLs.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <SJUIKit/NSAttributedString+SJMake.h>

#if __has_include(<PLPlayerKit/PLPlayerKit.h>)
#import <SJBaseVideoPlayer/SJPLPlayerPlaybackController.h>
#endif

@interface SJTestPLPlayerViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@end

@implementation SJTestPLPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _player = SJVideoPlayer.player;
    [self.containerView addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
#if __has_include(<PLPlayerKit/PLPlayerKit.h>)
    _player.playbackController = SJPLPlayerPlaybackController.new;
    SJVideoPlayerURLAsset *asset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0];
//    asset.trialEndPosition = 30; // 试看30秒
    asset.pl_playerOptions = PLPlayerOption.defaultOption;
    _player.URLAsset = asset;
#else
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"请按照指南导入PLPlayer");
        make.textColor(UIColor.whiteColor);
    }] duration:-1];
#endif
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

@interface SJTestPLPlayerViewController (RouteHandler)<SJRouteHandler>
@end

@implementation SJTestPLPlayerViewController (RouteHandler)
+ (NSString *)routePath {
    return @"thirdpartyPlayer/PLPlayer";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:SJTestPLPlayerViewController.new animated:YES];
}
@end
