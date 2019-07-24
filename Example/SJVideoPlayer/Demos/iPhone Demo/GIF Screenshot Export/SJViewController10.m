//
//  SJViewController10.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/7/24.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController10.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/SJUIKit.h>
#import "SJSourceURLs.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJViewController10 ()
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJViewController10

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    _player.enableFilmEditing = YES;
    _player.filmEditingConfig.saveResultToAlbumWhenExportSuccess = YES;
}

- (void)_setupViews {
    self.title = NSStringFromClass(self.class);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _player = [SJVideoPlayer player];
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:SourceURL3];
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
@interface SJViewController10 (RouteHandler)<SJRouteHandler>

@end

@implementation SJViewController10 (RouteHandler)

+ (NSString *)routePath {
    return @"demo/export";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJViewController10 alloc] initWithNibName:@"SJViewController10" bundle:nil] animated:YES];
}

@end
