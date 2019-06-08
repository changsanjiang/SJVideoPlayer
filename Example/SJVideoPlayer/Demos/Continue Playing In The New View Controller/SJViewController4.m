//
//  SJViewController4.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJViewController4.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/SJUIKit.h>

@interface SJViewController4 ()
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJViewController4

- (instancetype)initWithAsset:(SJVideoPlayerURLAsset *)asset {
    self = [super initWithNibName:@"SJViewController4" bundle:nil];
    if ( self ) {
        _player = [SJVideoPlayer player];
        _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithOtherAsset:asset playModel:SJPlayModel.new];
        [_player play];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

- (void)_setupViews {
    [_playerContainerView addSubview:self.player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
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
