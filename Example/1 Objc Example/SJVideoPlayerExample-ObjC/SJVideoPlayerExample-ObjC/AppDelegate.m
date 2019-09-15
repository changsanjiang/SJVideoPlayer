//
//  AppDelegate.m
//  SJVideoPlayerExample-ObjC
//
//  Created by BlueDancer on 2019/9/15.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "AppDelegate.h"
#import <SJVideoPlayer/SJVideoPlayer.h>

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
        commonSettings.progress_thumbSize = 12;
    });
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
}
@end


@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end


@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _player = SJVideoPlayer.player;
    [_containerView addSubview:_player.view];
    _player.view.translatesAutoresizingMaskIntoConstraints = NO;
    [_player.view.topAnchor constraintEqualToAnchor:_containerView.topAnchor].active = YES;
    [_player.view.leftAnchor constraintEqualToAnchor:_containerView.leftAnchor].active = YES;
    [_player.view.bottomAnchor constraintEqualToAnchor:_containerView.bottomAnchor].active = YES;
    [_player.view.rightAnchor constraintEqualToAnchor:_containerView.rightAnchor].active = YES;
}
@end
