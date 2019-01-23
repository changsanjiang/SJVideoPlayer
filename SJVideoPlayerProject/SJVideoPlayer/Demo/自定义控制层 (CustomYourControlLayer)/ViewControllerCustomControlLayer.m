//
//  ViewControllerCustomControlLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/1.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerCustomControlLayer.h"
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import "CustomControlLayerView.h"
#import <Masonry/Masonry.h>
#import <SJRouter/SJRouter.h>

@interface ViewControllerCustomControlLayer ()<SJRouteHandler>
@property (nonatomic, strong) SJBaseVideoPlayer *player;
@property (nonatomic, strong) CustomControlLayerView *customControlLayer;
@end

@implementation ViewControllerCustomControlLayer

+ (NSString *)routePath {
    return @"player/customControlLayer";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor blackColor];

    _customControlLayer = [CustomControlLayerView new];
    
    _player = [SJBaseVideoPlayer player];
    _player.controlLayerDataSource = self.customControlLayer;
    _player.controlLayerDelegate = self.customControlLayer;
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        else make.top.offset(0);
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_player.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
    // Do any additional setup after loading the view.
}

@end
