//
//  SJViewController5.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/9.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController5.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#import "SJSourceURLs.h"

@interface SJViewController5 ()
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJViewController5 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}
- (IBAction)switchToSJLoadFailedControlLayer:(id)sender {
    [_player.switcher switchControlLayerForIdentifier:SJControlLayer_LoadFailed];
    
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"已切换至 加载失败的控制层");
        make.textColor(UIColor.whiteColor);
    }] duration:3];
    [_player controlLayerNeedAppear];
}

- (IBAction)swithToSJClipsControlLayer:(id)sender {
    [_player.switcher switchControlLayerForIdentifier:SJControlLayer_Clips];
    
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"已切换至 剪辑的控制层");
        make.textColor(UIColor.whiteColor);
    }] duration:3];
    [_player controlLayerNeedAppear];
}

- (IBAction)switchTOSJSmallViewControlLayer:(id)sender {
    [_player.switcher switchControlLayerForIdentifier:SJControlLayer_FloatSmallView];
    
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"已切换至 小浮窗的控制层 (注: 小浮窗控制层, 目前只有右上角一个按钮)");
        make.textColor(UIColor.whiteColor);
    }] duration:3];
    [_player controlLayerNeedAppear];
}

- (IBAction)switchToSJMoreSettingControlLayer:(id)sender {
    [_player.switcher switchControlLayerForIdentifier:SJControlLayer_More];
    
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"已切换至 more控制层");
        make.textColor(UIColor.whiteColor);
    }] duration:3];
    [_player controlLayerNeedAppear];
}

- (IBAction)switchToSJNotReachableControlLayer:(id)sender {
    [_player.switcher switchControlLayerForIdentifier:SJControlLayer_NotReachableAndPlaybackStalled];
    
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"已切换至 无网无缓冲时的控制层");
        make.textColor(UIColor.whiteColor);
    }] duration:3];
    [_player controlLayerNeedAppear];
}

- (IBAction)switchToSJEdgeControlLayer:(id)sender {
    [_player.switcher switchControlLayerForIdentifier:SJControlLayer_Edge];
    
    [_player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"已切换至 默认边缘的控制层");
        make.textColor(UIColor.whiteColor);
    }] duration:3];
    [_player controlLayerNeedAppear];
}

#pragma mark -

- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
     _player = [SJVideoPlayer player];
    _player.assetURL = SourceURL0;
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


#import <SJRouter/SJRouter.h>
@interface SJViewController5 (RouteHandler)<SJRouteHandler>

@end

@implementation SJViewController5 (RouteHandler)

+ (NSString *)routePath {
    return @"demo/controlLayer/switching";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJViewController5 alloc] initWithNibName:@"SJViewController5" bundle:nil] animated:YES];
}

@end
