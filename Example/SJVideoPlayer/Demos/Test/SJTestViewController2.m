//
//  SJTestViewController2.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/10/12.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJTestViewController2.h"
#import "SJIJKMediaPlayer.h"
#import "SJSourceURLs.h"

@interface SJTestViewController2 ()
@property (nonatomic, strong) SJIJKMediaPlayer *player;
@end

@implementation SJTestViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
     
    NSURL *URL = SourceURL0;
    
    _player = [[SJIJKMediaPlayer alloc] initWithURL:URL specifyStartTime:0];
    
    _player.view.frame = CGRectMake(20, 120, 200, 120);
    _player.view.backgroundColor = UIColor.blackColor;
    [self.player play];
    [self.view addSubview:_player.view];
}
@end

#pragma mark -

#import <SJRouter/SJRouter.h>

@interface SJTestViewController2 (RouteHandler)<SJRouteHandler>
@end

@implementation SJTestViewController2 (RouteHandler)
+ (NSString *)routePath {
    return @"test2";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:SJTestViewController2.new animated:YES];
}
@end
