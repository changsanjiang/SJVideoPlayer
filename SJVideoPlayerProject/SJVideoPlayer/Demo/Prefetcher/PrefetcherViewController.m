//
//  PrefetcherViewController.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/11/16.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "PrefetcherViewController.h" 
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>
#import "SJVideoPlayer.h"

@interface PrefetcherViewController ()<SJRouteHandler>
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation PrefetcherViewController
+ (NSString *)routePath {
    return @"asset/prefetcher";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // create a player of the default type
    _player = [SJVideoPlayer player];
    
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        else make.top.offset(0);
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_player.view.mas_width).multipliedBy(9 / 16.0f);
    }];

    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
}

- (IBAction)next:(id)sender {
    
}

@end
