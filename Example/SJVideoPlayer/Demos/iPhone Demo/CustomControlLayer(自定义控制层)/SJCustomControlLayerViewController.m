//
//  SJCustomControlLayerViewController.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/10/11.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJCustomControlLayerViewController.h"
#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJVideoPlayer/UIView+SJAnimationAdded.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJCustomControlLayerViewController ()
@property (nonatomic, strong, readonly) UIView *rightContainerView;
@property (nonatomic, strong, readonly) WKWebView *webView;
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *player;
@end

@implementation SJCustomControlLayerViewController
@synthesize restarted = _restarted;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.rightContainerView];
    [_rightContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.offset(0);
    }];
    
    [_rightContainerView addSubview:self.webView];
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.offset(0);
        if (@available(iOS 11.0, *)) {
            make.right.equalTo(self.rightContainerView.mas_safeAreaLayoutGuideRight);
        } else {
            make.right.offset(0);
        }
        CGRect bounds = UIScreen.mainScreen.bounds;
        make.width.offset(MIN(bounds.size.width, bounds.size.height));
    }];
}


///
/// 控制层入场
///     当播放器将要切换到此控制层时, 该方法将会被调用
///     可以在这里做入场的操作
///
- (void)restartControlLayer {
    _restarted = YES;
    if ( self.player.isFullScreen ) [self.player needHiddenStatusBar];
    sj_view_makeAppear(self.controlView, YES);
    sj_view_makeAppear(self.rightContainerView, YES);
}


///
/// 退出控制层
///     当播放器将要切换到其他控制层时, 该方法将会被调用
///     可以在这里处理退出控制层的操作
///
- (void)exitControlLayer {
    _restarted = NO;
    
    sj_view_makeDisappear(self.rightContainerView, YES);
    sj_view_makeDisappear(self.controlView, YES, ^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    });
}

///
/// 控制层视图
///     当切换为当前控制层时, 该视图将会被添加到播放器中
///
- (UIView *)controlView {
    return self.view;
}

///
/// 当controlView被添加到播放器时, 该方法将会被调用
///
- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _player = videoPlayer;
    
    if ( self.view.layer.needsLayout ) {
        sj_view_initializes(self.rightContainerView);
    }
    
    sj_view_makeDisappear(self.rightContainerView, NO);
}

///
/// 当调用播放器的controlLayerNeedAppear时, 播放器将会回调该方法
///
- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {}

///
/// 当调用播放器的controlLayerNeedDisappear时, 播放器将会回调该方法
///
- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {}

///
/// 当将要触发某个手势时, 该方法将会被调用. 返回NO, 将不触发该手势
///
- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    if ( type == SJPlayerGestureType_SingleTap ) {
        if ( !CGRectContainsPoint(self.rightContainerView.frame, location) ) {
            if ( [self.delegate respondsToSelector:@selector(tappedBlankAreaOnTheControlLayer:)] ) {
                [self.delegate tappedBlankAreaOnTheControlLayer:self];
            }
        }
    }
    return NO;
}


///
/// 当将要触发旋转时, 该方法将会被调用. 返回NO, 将不触发旋转
///
- (BOOL)canTriggerRotationOfVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    return NO;
}

#pragma mark -

@synthesize rightContainerView = _rightContainerView;
- (UIView *)rightContainerView {
    if ( _rightContainerView == nil ) {
        _rightContainerView = [UIView.alloc initWithFrame:CGRectZero];
        _rightContainerView.backgroundColor = UIColor.blackColor;
        _rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
    }
    return _rightContainerView;
}

@synthesize webView = _webView;
- (WKWebView *)webView {
    if ( _webView == nil ) {
        _webView = [WKWebView.alloc initWithFrame:CGRectZero configuration:WKWebViewConfiguration.new];
        _webView.backgroundColor = UIColor.whiteColor;
        NSURL *URL = [NSURL URLWithString:@"https://www.baidu.com"];
        NSURLRequest *request = [NSURLRequest.alloc initWithURL:URL];
        [_webView loadRequest:request];
    }
    return _webView;
}
@end
NS_ASSUME_NONNULL_END
