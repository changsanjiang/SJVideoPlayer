//
//  SJRotationModeDemoViewController1.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJRotationModeDemoViewController1.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <SJBaseVideoPlayer/SJVCRotationManager.h>
#import <Masonry/Masonry.h>
#import "SJSourceURLs.h"

@interface SJRotationModeDemoViewController1 ()
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (nonatomic, strong, readonly) SJVCRotationManager *rotationManager;
@property (nonatomic, strong) SJBaseVideoPlayer *player;
@end

@implementation SJRotationModeDemoViewController1
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
    _player.rotationManager = self.rotationManager;
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:SourceURL1];
    [_playerContainerView addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (IBAction)rotate:(id)sender {
    [_player rotate];
}

- (IBAction)rotateToTheLLO:(id)sender {
    [_player rotate:SJOrientation_LandscapeLeft animated:YES];
}

- (IBAction)rotateToTheLRO:(id)sender {
    [_player rotate:SJOrientation_LandscapeRight animated:YES completion:^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        NSLog(@"================");
    }];
}

- (IBAction)disableAction:(UISwitch *)sender {
    _rotationManager.disableAutorotation = sender.isOn;
    
    if ( sender.isOn ) {
        [_player showTitle:@"已禁止自动旋转. 此时旋转设备, 播放器将不会自动旋转" duration:3];
    }
    else {
        [_player showTitle:@"已开启自动旋转. 此时旋转设备, 播放器将自动旋转" duration:3];
    }
}

#pragma mark -
@synthesize rotationManager = _rotationManager;
- (SJVCRotationManager *)rotationManager {
    if ( _rotationManager == nil ) {
        _rotationManager = [[SJVCRotationManager alloc] initWithViewController:self];
    }
    return _rotationManager;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [_rotationManager vc_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (BOOL)shouldAutorotate {
    if ( _player == nil )
        return NO;
    return [self.rotationManager vc_shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.rotationManager vc_supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.rotationManager vc_preferredInterfaceOrientationForPresentation];
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
@interface SJRotationModeDemoViewController1 (RouteHandler)<SJRouteHandler>

@end

@implementation SJRotationModeDemoViewController1 (RouteHandler)

+ (NSString *)routePath {
    return @"rotationMode/vc1";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJRotationModeDemoViewController1 alloc] initWithNibName:@"SJRotationModeDemoViewController1" bundle:nil] animated:YES];
}

@end
