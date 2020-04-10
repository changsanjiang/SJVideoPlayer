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
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [_playerContainerView addSubview:self.player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_player vc_viewDidAppear];
    [_player play];
#ifdef DEBUG
    NSLog(@"AA: %d - %s", (int)__LINE__, __func__);
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_player vc_viewDidDisappear];
    [_player pause];
#ifdef DEBUG
        NSLog(@"AA: %d - %s", (int)__LINE__, __func__);
#endif
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (IBAction)push:(id)sender {
    UIViewController *vc = UIViewController.new;
    vc.view.backgroundColor = UIColor.whiteColor;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
