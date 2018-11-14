//
//  PresentingViewController.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/11/14.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "PresentingViewController.h"

@interface PresentingViewController ()
@property (nonatomic, strong, readonly) SJVideoPlayer *player;
@end

@implementation PresentingViewController
- (instancetype)initWithVideoPlayer:(SJVideoPlayer *)player {
    self = [super init];
    if ( !self ) return nil;
    _player = player;
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return _player.vc_prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
@end
