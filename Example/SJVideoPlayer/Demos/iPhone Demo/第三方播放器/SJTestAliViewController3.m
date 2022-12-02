//
//  SJTestAliViewController3.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/11/7.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJTestAliViewController3.h"
#import <SJVideoPlayer.h>
#import "SJSourceURLs.h"
#import "Masonry.h"
#import <SJUIKit/NSAttributedString+SJMake.h>

#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
#import <SJBaseVideoPlayer/SJAliMediaPlaybackController.h>

#endif

#import <SJVideoPlayer/SJVideoPlayerURLAsset+SJExtendedDefinition.h>

@interface SJTestAliViewController3 ()
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJTestAliViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    _player = SJVideoPlayer.player;
    
#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
    _player.playbackController = SJAliMediaPlaybackController.new;
    AVPUrlSource *source = [AVPUrlSource.alloc init];
    source.playerUrl = SourceURL1;
    SJVideoPlayerURLAsset *asset = [SJVideoPlayerURLAsset.alloc initWithSource:source];
//    asset.trialEndPosition = 30; // 试看30秒
    _player.URLAsset = asset;
    
#else
    // 切换为 Aliplayer, 详见: https://github.com/changsanjiang/SJVideoPlayer/wiki/Use-AliPlayer
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"请按照指南导入AliPlayer");
        make.textColor(UIColor.whiteColor);
    }] duration:-1];
#endif
    
    if ( @available(iOS 15.0, *) ) {
        _player.playbackController.canStartPictureInPictureAutomaticallyFromInline = YES;
    }
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(100);
        make.left.right.offset(0);
        make.height.equalTo(self.player.view.mas_width).multipliedBy(9/16.0);
    }];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)play:(id)sender {
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL1];
}

- (IBAction)pause:(id)sender {
    [_player pause];
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

@interface SJTestAliViewController3 (RouteHandler)<SJRouteHandler>
@end

@implementation SJTestAliViewController3 (RouteHandler)
+ (NSString *)routePath {
    return @"thirdpartyPlayer/AliPlayer";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:SJTestAliViewController3.new animated:YES];
}
@end
