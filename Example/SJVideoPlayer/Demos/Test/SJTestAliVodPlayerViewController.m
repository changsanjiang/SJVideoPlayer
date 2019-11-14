//
//  SJTestAliVodPlayerViewController.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/11/14.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJTestAliVodPlayerViewController.h"
#import <SJVideoPlayer.h>
#import "SJSourceURLs.h"
#import "Masonry.h"

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
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithAliyunVodModel:[SJAliyunVodURLModel.alloc initWithURL:VideoURL_Level1]];
#endif
    
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(100);
        make.left.right.offset(0);
        make.height.equalTo(self.player.view.mas_width).multipliedBy(9/16.0);
    }];
    // Do any additional setup after loading the view from its nib.
}

@end


#pragma mark -

#import <SJRouter/SJRouter.h>

@interface SJTestAliVodPlayerViewController (RouteHandler)<SJRouteHandler>
@end

@implementation SJTestAliVodPlayerViewController (RouteHandler)
+ (NSString *)routePath {
    return @"test4";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:SJTestAliVodPlayerViewController.new animated:YES];
}
@end
