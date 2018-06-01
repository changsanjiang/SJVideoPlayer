//
//  ViewController.m
//  SJVideoPlayerV3Project
//
//  Created by 畅三江 on 2018/5/29.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "SJVideoPlayerHelper.h"

@interface ViewController ()<SJVideoPlayerHelperUseProtocol>
@property (nonatomic, strong, readonly) UIView *playerParentView;
@property (nonatomic, strong, readonly) SJVideoPlayerHelper *videoPlayerHelper;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.playerParentView];
    [_playerParentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(8);
        make.leading.trailing.offset(0);
        make.height.equalTo(self.view.mas_width).multipliedBy(9/16.0f);
    }];
    
    [self.videoPlayerHelper playWithAsset:[[SJVideoPlayerURLAsset alloc] initWithAssetURL:[NSURL URLWithString:@"http://video.cdn.lanwuzhe.com/usertrend/95481-1527514816.mp4"]] playerParentView:self.playerParentView];
}

@synthesize playerParentView = _playerParentView;
- (UIView *)playerParentView {
    if ( _playerParentView ) return _playerParentView;
    _playerParentView = [UIView new];
    _playerParentView.backgroundColor = [UIColor blackColor];
    return _playerParentView;
}

@synthesize videoPlayerHelper = _videoPlayerHelper;
- (SJVideoPlayerHelper *)videoPlayerHelper {
    if ( _videoPlayerHelper ) return _videoPlayerHelper;
    _videoPlayerHelper = [[SJVideoPlayerHelper alloc] initWithViewController:self];
    _videoPlayerHelper.enableFilmEditing = YES;
    return _videoPlayerHelper;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.videoPlayerHelper.vc_viewDidAppearExeBlock();
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.videoPlayerHelper.vc_viewWillDisappearExeBlock();
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.videoPlayerHelper.vc_viewDidDisappearExeBlock();
}

- (BOOL)prefersStatusBarHidden {
    return self.videoPlayerHelper.vc_prefersStatusBarHiddenExeBlock();
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.videoPlayerHelper.vc_preferredStatusBarStyleExeBlock();
}

@end
