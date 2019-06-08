//
//  SJRotationModeDemoViewController3.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJRotationModeDemoViewController3.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <SJBaseVideoPlayer/SJVCRotationManager.h>
#import <Masonry/Masonry.h>
#import "SJSourceURLs.h"

@interface SJRotationModeDemoViewController3 ()
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (nonatomic, strong) SJBaseVideoPlayer *player;
@end

@implementation SJRotationModeDemoViewController3
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

- (void)_setupViews {
    self.title = NSStringFromClass(self.class);
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _player = [SJVideoPlayer player];
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:SourceURL1];
    [_playerContainerView addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    [_player showTitle:@"此示例为播放器默认的旋转模式, 当播放器旋转时, 视图控制器并不会触发旋转." duration:-1];
}

- (IBAction)rotate:(id)sender {
    [_player rotate];
}

- (IBAction)rotateToTheLLO:(id)sender {
    [_player rotate:SJOrientation_LandscapeLeft animated:YES];
}

- (IBAction)rotateToTheLRO:(id)slender {
    [_player rotate:SJOrientation_LandscapeRight animated:YES completion:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        NSLog(@"================");
    }];
}

- (IBAction)disableAction:(UISwitch *)sender {
    _player.rotationManager.disableAutorotation = sender.isOn;
    
    if ( sender.isOn ) {
        [_player showTitle:@"已禁止自动旋转. 此时旋转设备, 播放器将不会自动旋转" duration:3];
    }
    else {
        [_player showTitle:@"已开启自动旋转. 此时旋转设备, 播放器将自动旋转" duration:3];
    }
}

#pragma mark -
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


#pragma mark -
#import <SJRouter/SJRouter.h>
@interface SJRotationModeDemoViewController3 (RouteHandler)<SJRouteHandler>

@end

@implementation SJRotationModeDemoViewController3 (RouteHandler)

+ (NSString *)routePath {
    return @"rotationMode/vc3";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJRotationModeDemoViewController3 alloc] initWithNibName:@"SJRotationModeDemoViewController3" bundle:nil] animated:YES];
}

@end
