//
//  SJNotReachableControlLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/15.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJNotReachableControlLayer.h"
#import "UIView+SJAnimationAdded.h"
#import "SJVideoPlayerSettings.h"

#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#else
#import "SJBaseVideoPlayer.h"
#endif
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
SJEdgeControlButtonItemTag const SJNotReachableControlLayerTopItem_Back = 10000;

@interface SJButtonContainerView ()

@end

@implementation SJButtonContainerView
- (instancetype)initWithEdgeInsets:(UIEdgeInsets)insets {
    self = [super initWithFrame:CGRectZero];
    if ( self ) {
        _insets = insets;
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_button];
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).mas_offset(insets);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ( _roundedRect ) self.layer.cornerRadius = self.bounds.size.height * 0.5;
}

- (void)setInsets:(UIEdgeInsets)insets {
    _insets = insets;
    [_button mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).mas_offset(insets);
    }];
}
@end

@interface SJNotReachableControlLayer ()

@end

@implementation SJNotReachableControlLayer
@synthesize restarted = _restarted;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)backItemWasTapped:(SJEdgeControlButtonItem *)item {
    if ( [self.delegate respondsToSelector:@selector(backItemWasTappedForControlLayer:)] ) {
        [self.delegate backItemWasTappedForControlLayer:self];
    }
}

- (void)reloadButtonWasTapped {
    if ( [self.delegate respondsToSelector:@selector(reloadItemWasTappedForControlLayer:)] ) {
        [self.delegate reloadItemWasTappedForControlLayer:self];
    }
}

#pragma mark -

- (void)restartControlLayer {
    _restarted = YES;
    sj_view_makeAppear(self.controlView, YES);
}

- (void)exitControlLayer {
    _restarted = NO;
    sj_view_makeDisappear(self.controlView, YES, ^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    });
}

- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _updateItems:videoPlayer];
}

- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    return NO;
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {}
- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull {
    [self _updateItems:videoPlayer];
}
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willFitOnScreen:(BOOL)isFitOnScreen {
    [self _updateItems:videoPlayer];
}

- (void)_updateItems:(__kindof SJBaseVideoPlayer *)videoPlayer {
    SJEdgeControlButtonItem *backItem = [_topAdapter itemForTag:SJNotReachableControlLayerTopItem_Back];
    BOOL isFitOnScreen = videoPlayer.isFitOnScreen;
    BOOL isFull = videoPlayer.isFullScreen;
    
    if ( backItem ) {
        if ( isFull || isFitOnScreen )
            backItem.hidden = NO;
        else {
            if ( _hiddenBackButtonWhenOrientationIsPortrait )
                backItem.hidden = YES;
            else
                backItem.hidden = videoPlayer.isPlayOnScrollView;
        }
    }
    [_topAdapter reload];
}

#pragma mark -

- (void)_setupView {
    self.backgroundColor = [UIColor blackColor];
    
    SJVideoPlayerSettings *sources = SJVideoPlayerSettings.commonSettings;
    
    SJEdgeControlButtonItem *backItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJNotReachableControlLayerTopItem_Back];
    [backItem addTarget:self action:@selector(backItemWasTapped:)];
    backItem.image = sources.backBtnImage;
    [self.topAdapter addItem:backItem];
    [self.topAdapter reload];

    _promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _promptLabel.text = sources.noNetworkPromptText;
    _promptLabel.font = [UIFont systemFontOfSize:14];
    _promptLabel.textColor = [UIColor whiteColor];
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.numberOfLines = 0;
    [self addSubview:_promptLabel];
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(20);
        make.right.mas_lessThanOrEqualTo(-20);
        make.centerX.offset(0);
        make.bottom.equalTo(self.mas_centerY);
    }];
    
    _reloadView = [[SJButtonContainerView alloc] initWithEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    [_reloadView.button addTarget:self action:@selector(reloadButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    _reloadView.roundedRect = YES;
    [_reloadView.button setTitle:sources.noNetworkReloadButtonTitle forState:UIControlStateNormal];
    _reloadView.button.titleLabel.font = [UIFont systemFontOfSize:14];
    _reloadView.backgroundColor = [UIColor redColor];
    _reloadView.backgroundColor = sources.noNetworkButtonBackgroundColor;
    [self addSubview:_reloadView];
    [_reloadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.promptLabel.mas_bottom).offset(20);
        make.centerX.offset(0);
    }];
}

@end
NS_ASSUME_NONNULL_END
