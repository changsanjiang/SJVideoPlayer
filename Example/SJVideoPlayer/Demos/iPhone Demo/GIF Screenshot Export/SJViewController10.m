//
//  SJViewController10.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/7/24.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController10.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
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
    
    _player.defaultEdgeControlLayer.enabledClips = YES;
    _player.defaultEdgeControlLayer.clipsConfig.saveResultToAlbum = YES;
    
    
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"请旋转至全屏后, 点击右侧剪辑按钮");
        make.textColor(UIColor.whiteColor);
    }] duration:3];
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
    
    __weak typeof(self) _self = self;
    _player.controlLayerAppearObserver.onAppearChanged = ^(id<SJControlLayerAppearManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( mgr.isAppeared ) {
            self.player.promptingPopupController.bottomMargin = self.player.defaultEdgeControlLayer.bottomContainerView.bounds.size.height;
        }
        else {
            self.player.promptingPopupController.bottomMargin = 16;
        }
    };
}

- (BOOL)shouldAutorotate {
    return NO;
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
