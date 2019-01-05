//
//  ViewControllerSetPlaybackRate.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/1.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerSetPlaybackRate.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>
#import "SJProgressSlider.h"

/// 调速

@interface ViewControllerSetPlaybackRate ()<SJRouteHandler, SJProgressSliderDelegate>
@property (nonatomic, strong) SJVideoPlayer *player;
@property (nonatomic, strong) SJProgressSlider *rateSlider;
@end

@implementation ViewControllerSetPlaybackRate

+ (NSString *)routePath {
    return @"player/setPlaybackRate";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor blackColor];
    
    // create a player of the default type
    _player = [SJVideoPlayer player];
    
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        else make.top.offset(0);
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_player.view.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
    _player.URLAsset.title = @"Test Title";
    _player.hideBackButtonWhenOrientationIsPortrait = YES;
    _player.enableFilmEditing = YES;
    
    _rateSlider = [SJProgressSlider new];
    _rateSlider.maxValue = 2;
    _rateSlider.minValue = 0;
    _rateSlider.trackHeight = 6;
    _rateSlider.value = _player.rate;
    [_rateSlider setThumbCornerRadius:8 size:CGSizeMake(16, 16) thumbBackgroundColor:UIColor.orangeColor];
    _rateSlider.delegate = self;
    [self.view addSubview:_rateSlider];
    [_rateSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.player.view.mas_bottom).offset(22);
        make.centerX.offset(0);
        make.height.offset(44);
        make.width.offset(160);
    }];
    
    __weak typeof(self) _self = self;
    _player.rateDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [player showTitle:[NSString stringWithFormat:@"%.02f", player.rate]];
        if ( self.rateSlider.isDragging ) return;
        self.rateSlider.value = player.rate;
    };
    // Do any additional setup after loading the view.
}

- (void)sliderWillBeginDragging:(SJProgressSlider *)slider {
    _player.rate = slider.value;
}

- (void)sliderDidDrag:(SJProgressSlider *)slider {
    _player.rate = slider.value;
}

- (void)sliderDidEndDragging:(SJProgressSlider *)slider {
    _player.rate = slider.value;
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
