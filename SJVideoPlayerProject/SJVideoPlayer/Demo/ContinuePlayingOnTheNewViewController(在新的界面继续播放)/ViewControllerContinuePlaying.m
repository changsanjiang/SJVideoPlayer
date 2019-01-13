//
//  ViewControllerContinuePlaying.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerContinuePlaying.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>

@interface ViewControllerContinuePlaying ()<SJRouteHandler>
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation ViewControllerContinuePlaying {
    SJVideoPlayerURLAsset *_asset;
}

+ (NSString *)routePath {
    return @"player/continuePlaying";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (instancetype)init {
    self = [super initWithNibName:@"ViewControllerContinuePlaying" bundle:nil];
    if ( !self ) return nil;
    return self;
}

- (instancetype)initWithAsset:(SJVideoPlayerURLAsset *)asset {
    self = [self init];
    if ( !self ) return nil;
    _asset = asset;
    return self;
}

- (IBAction)next:(id)sender {
    [self.navigationController pushViewController:[[ViewControllerContinuePlaying alloc] initWithAsset:self.player.URLAsset] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _player = [SJVideoPlayer player];
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        else make.top.offset(0);
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_player.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    if ( !_asset ) {
        _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
        _player.URLAsset.title = @"Test Title";
    }
    else {
        _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithOtherAsset:_asset playModel:[SJPlayModel new]];
        _player.URLAsset.title = _asset.title;
    }
    
    _player.hideBackButtonWhenOrientationIsPortrait = YES;
    
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
    [self.player play];
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

