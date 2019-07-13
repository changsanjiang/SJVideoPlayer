//
//  SJViewController7.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/7/13.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController7.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/SJUIKit.h>
#import "SJSourceURLs.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJViewController7 ()
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJViewController7

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    SJVideoPlayerURLAsset *asset1 = [[SJVideoPlayerURLAsset alloc] initWithURL:VideoURL_Level4];
    asset1.definition_fullName = @"超清 1080P";
    asset1.definition_lastName = @"1080P";
    
    SJVideoPlayerURLAsset *asset2 = [[SJVideoPlayerURLAsset alloc] initWithURL:VideoURL_Level3];
    asset2.definition_fullName = @"高清 720P";
    asset2.definition_lastName = @"高清";
    
    SJVideoPlayerURLAsset *asset3 = [[SJVideoPlayerURLAsset alloc] initWithURL:VideoURL_Level2];
    asset3.definition_fullName = @"清晰 480P";
    asset3.definition_lastName = @"480P";
    
    SJVideoPlayerURLAsset *asset4 = [[SJVideoPlayerURLAsset alloc] initWithURL:VideoURL_Level1];
    asset4.definition_fullName = @"流畅 320P";
    asset4.definition_lastName = @"流畅";

    _player.definitionURLAssets = @[asset1, asset2, asset3, asset4];
    _player.URLAsset = asset1;
} 

- (void)_setupViews {
    self.title = NSStringFromClass(self.class);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _player = [SJVideoPlayer player];
    [_playerContainerView addSubview:self.player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    _player.controlLayerAppearStateDidChangeExeBlock = ^(SJVideoPlayer * _Nonnull player, BOOL isAppeared) {
        if ( isAppeared ) {
            player.popPromptController.bottomMargin = player.defaultEdgeControlLayer.bottomContainerView.bounds.size.height;
        }
        else {
            player.popPromptController.bottomMargin = 16;
        }
    };
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
@interface SJViewController7 (RouteHandler)<SJRouteHandler>

@end

@implementation SJViewController7 (RouteHandler)

+ (NSString *)routePath {
    return @"demo/SwitchVideoDefinition";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJViewController7 alloc] initWithNibName:@"SJViewController7" bundle:nil] animated:YES];
}

@end
