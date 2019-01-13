//
//  ViewControllerPresentFitOnScreenDemo.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/11/14.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "ViewControllerPresentFitOnScreenDemo.h"
#import "SJVideoPlayer.h"
#import <SJRouter/SJRouter.h>
#import <Masonry/Masonry.h>
#import "PresentingViewController.h"
#import "SJNavTransitionAnimator.h"

@interface ViewControllerPresentFitOnScreenDemo ()<SJRouteHandler>
@property (nonatomic, strong) UIView *playerSuperview;
@property (nonatomic, strong) SJVideoPlayer *player;
@property (nonatomic, strong) SJNavTransitionAnimator *navTransitionAnimator;
@end

@implementation ViewControllerPresentFitOnScreenDemo

- (IBAction)push:(id)sender {
    PresentingViewController *vc = [[PresentingViewController alloc] initWithVideoPlayer:_player];
    _navTransitionAnimator = [[SJNavTransitionAnimator alloc] init];
    _navTransitionAnimator.navigationController = self.navigationController;
    
    
    SJPlayModel *currentPlayModel = _player.URLAsset.playModel;
    __weak typeof(self) _self = self;
    [_navTransitionAnimator pushAnimation:^(SJNavTransitionAnimator * _Nonnull anim, id<UIViewControllerContextTransitioning>  _Nonnull transitionContext, UIView * _Nonnull toView, UIView * _Nonnull fromView) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.player.hideBackButtonWhenOrientationIsPortrait = NO;
        [self.player controlLayerNeedAppear];
        self.player.URLAsset.playModel = [SJPlayModel new];

        toView.backgroundColor = [UIColor clearColor];
        CGRect frame = [self.playerSuperview convertRect:self.player.view.frame toView:toView];
        self.player.view.frame = frame;
        [toView addSubview:self.player.view];
        [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        
        [UIView animateWithDuration:anim.duration animations:^{
            [toView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } popAnimation:^(SJNavTransitionAnimator * _Nonnull anim, id<UIViewControllerContextTransitioning>  _Nonnull transitionContext, UIView * _Nonnull toView, UIView * _Nonnull fromView) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.player.hideBackButtonWhenOrientationIsPortrait = YES;
        [self.player controlLayerNeedDisappear];
        self.player.URLAsset.playModel = currentPlayModel;
        
        CGRect frame = [toView convertRect:self.playerSuperview.frame toView:fromView];
        [self.player.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self.playerSuperview);
            make.top.offset(frame.origin.y);
            make.left.offset(frame.origin.x);
        }];
        
        [UIView animateWithDuration:anim.duration animations:^{
            [fromView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.playerSuperview addSubview:self.player.view];
            [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.offset(0);
            }];
            self.navTransitionAnimator = nil;
            [transitionContext completeTransition:YES];
        }];
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark -
+ (NSString *)routePath {
    return @"player/fitOnScreenV2";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _playerSuperview = [UIView new];
    _playerSuperview.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_playerSuperview];
    [_playerSuperview mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        else make.top.offset(0);
        make.leading.trailing.offset(0);
        make.height.equalTo(self->_playerSuperview.mas_width).multipliedBy(9 / 16.0f);
    }];
    
    _player = [SJVideoPlayer player];
    [_playerSuperview addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];

    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"play" withExtension:@"mp4"]];
    _player.URLAsset.title = @"Test Title";
    _player.URLAsset.alwaysShowTitle = YES;
    _player.hideBackButtonWhenOrientationIsPortrait = YES;
    _player.pausedToKeepAppearState = YES;
    
    // Do any additional setup after loading the view.
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
