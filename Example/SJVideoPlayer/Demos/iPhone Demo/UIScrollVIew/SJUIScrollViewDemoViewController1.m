//
//  SJUIScrollViewDemoViewController1.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/7/8.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJUIScrollViewDemoViewController1.h"
#import <Masonry/Masonry.h>
#import "SJPlayerSuperview.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import "SJSourceURLs.h"

@interface SJUIScrollViewDemoViewController1 ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJUIScrollViewDemoViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    _player = SJVideoPlayer.player;
    _player.floatSmallViewController.enabled = YES;
    __weak typeof(self) _self = self;
    _player.floatSmallViewController.singleTappedOnTheFloatViewExeBlock = ^(id<SJFloatSmallViewController>  _Nonnull controller) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [controller dismissFloatView];
        UIViewController *vc = UIViewController.new;
        vc.view.backgroundColor = UIColor.whiteColor;
        [self.navigationController pushViewController:vc animated:YES];
    };
    _player.floatSmallViewController.doubleTappedOnTheFloatViewExeBlock = ^(id<SJFloatSmallViewController>  _Nonnull controller) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.player.isPaused ? [self.player play] : [self.player pause];
    };
    _player.URLAsset = [SJVideoPlayerURLAsset.alloc initWithURL:SourceURL0 playModel:[SJPlayModel playModelWithScrollView:_scrollView]];
    [_player play];
}

- (void)_setupViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _scrollView = [UIScrollView.alloc initWithFrame:CGRectZero];
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * 3);
    _scrollView.backgroundColor = UIColor.purpleColor;
    [self.view addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    SJPlayerSuperview *playerSuperview = [SJPlayerSuperview.alloc initWithFrame:CGRectZero];
    playerSuperview.backgroundColor = UIColor.redColor;
    [_scrollView addSubview:playerSuperview];
    [playerSuperview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(100);
        make.left.offset(0);
        make.width.offset(self.view.bounds.size.width);
        make.height.equalTo(playerSuperview.mas_width).multipliedBy(9/16.0);
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

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
 
@end
