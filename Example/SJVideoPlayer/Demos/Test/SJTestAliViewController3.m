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

#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
#import <SJBaseVideoPlayer/SJAliMediaPlaybackController.h>
#endif

@interface SJTestAliViewController3 ()
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJTestAliViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    _player = SJVideoPlayer.player;
    
#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
    _player.playbackController = SJAliMediaPlaybackController.new;
//    AVPUrlSource *source = [AVPUrlSource.alloc urlWithString:@"rtmp://58.200.131.2:1935/livetv/hunantv"];
    AVPUrlSource *source = [AVPUrlSource.alloc init];
    source.playerUrl = SourceURL1;
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithSource:source];
#endif
    
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

@end


#pragma mark -

#import <SJRouter/SJRouter.h>

@interface SJTestAliViewController3 (RouteHandler)<SJRouteHandler>
@end

@implementation SJTestAliViewController3 (RouteHandler)
+ (NSString *)routePath {
    return @"test3";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:SJTestAliViewController3.new animated:YES];
}
@end
