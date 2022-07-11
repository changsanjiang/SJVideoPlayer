//
//  SJTestAliVodPlayerViewController.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/11/14.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJTestAliVodPlayerViewController.h"
#import <SJVideoPlayer.h>
#import "SJSourceURLs.h"
#import "Masonry.h"
#import <SJUIKit/NSAttributedString+SJMake.h>

#if __has_include(<AliyunPlayerSDK/AliyunPlayerSDK.h>)
#import <SJBaseVideoPlayer/SJAliyunVodPlaybackController.h>
#endif

@interface SJTestAliVodPlayerViewController ()
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJTestAliVodPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _player = SJVideoPlayer.player;
    
#if __has_include(<AliyunPlayerSDK/AliyunPlayerSDK.h>)
    _player.playbackController = SJAliyunVodPlaybackController.new;
    SJVideoPlayerURLAsset *asset =  [SJVideoPlayerURLAsset.alloc initWithAliyunVodModel:[SJAliyunVodURLModel.alloc initWithURL:SourceURL2]];
//    asset.trialEndPosition = 30; // 试看30秒
    _player.URLAsset = asset;
#else
    // 切换为 AliVodPlayer, 详见: https://github.com/changsanjiang/SJVideoPlayer/wiki/Use-AliVodPlayer
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"请按照指南导入AliVodPlayer");
        make.textColor(UIColor.whiteColor);
    }] duration:-1];
#endif
    
    
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(100);
        make.left.right.offset(0);
        make.height.equalTo(self.player.view.mas_width).multipliedBy(9/16.0);
    }];
    // Do any additional setup after loading the view from its nib.
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

@interface SJTestAliVodPlayerViewController (RouteHandler)<SJRouteHandler>
@end

@implementation SJTestAliVodPlayerViewController (RouteHandler)
+ (NSString *)routePath {
    return @"thirdpartyPlayer/AliyunVodPlayer";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:SJTestAliVodPlayerViewController.new animated:YES];
}
@end
