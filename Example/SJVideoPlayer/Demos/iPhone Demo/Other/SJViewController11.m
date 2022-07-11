//
//  SJViewController11.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/8/7.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController11.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#import "SJSourceURLs.h"

#import <SJVideoPlayer/SJProgressSlider.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJViewController11 ()
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJViewController11

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    // 1. 开启所有手势
    _player.gestureController.supportedGestureTypes |= SJPlayerGestureTypeMask_LongPress;
    // 2. 设置长按播放器界面时的播放速率
    _player.rateWhenLongPressGestureTriggered = 2.0;
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
@interface SJViewController11 (RouteHandler)<SJRouteHandler>

@end

@implementation SJViewController11 (RouteHandler)

+ (NSString *)routePath {
    return @"demo/11";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJViewController11 alloc] initWithNibName:@"SJViewController11" bundle:nil] animated:YES];
}

@end
