//
//  SJLoadFailedControlLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/27.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJLoadFailedControlLayer.h"
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#else
#import "SJBaseVideoPlayer.h"
#endif
#import "UIView+SJAnimationAdded.h"
#import "UIView+SJVideoPlayerSetting.h"
#import "SJVideoPlayerAnimationHeader.h"
#if __has_include(<SJAttributesFactory/SJAttributeWorker.h>)
#import <SJAttributesFactory/SJAttributeWorker.h>
#else
#import "SJAttributeWorker.h"
#endif
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
SJEdgeControlButtonItemTag const SJLoadFailedControlLayerTopItem_Back = 10000;

@interface SJLoadFailedControlLayer ()
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *videoPlayer;
@property (nonatomic, strong, readonly) UIButton *reloadButton;
@end

@implementation SJLoadFailedControlLayer
@synthesize restarted = _restarted;

- (void)restartControlLayer {
    _restarted = YES;
    [self _show:self.controlView animated:YES];
}

- (void)exitControlLayer {
    _restarted = NO;
    /// clean
    _videoPlayer.controlLayerDataSource = nil;
    _videoPlayer.controlLayerDelegate = nil;
    _videoPlayer = nil;
    
    [self _hidden:self.controlView animated:YES completionHandler:^{
        if ( !self->_restarted )[self.controlView removeFromSuperview];
    }];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    return self;
}

- (void)_setupViews {
    self.controlView.backgroundColor = [UIColor blackColor];
    [self _addItemsToTopAdapter];
    [self.controlView addSubview:self.reloadButton];
    [_reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    _reloadButton.backgroundColor = [UIColor redColor];
}

- (void)_addItemsToTopAdapter {
    SJEdgeControlButtonItem *backItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJLoadFailedControlLayerTopItem_Back];
    [backItem addTarget:self action:@selector(clickedBackItem:)];
    backItem.image = SJEdgeControlLayerSettings.commonSettings.backBtnImage;
    [self.topAdapter addItem:backItem];
    
    self.topAdapter.view.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        backItem.image = setting.backBtnImage;
    }];
    
    [self.topAdapter reload];
}

- (void)clickedBackItem:(SJEdgeControlButtonItem *)item {
    if ( _videoPlayer.useFitOnScreenAndDisableRotation ) {
        if ( _videoPlayer.isFitOnScreen ) {
            _videoPlayer.fitOnScreen = NO;
        }
        else {
            if ( _clickedBackItemExeBlock ) _clickedBackItemExeBlock(self);
        }
    }
    else {
        // 竖屏状态
        // 只支持一个反向
        // 调用 back
        if ( self.videoPlayer.orientation == SJOrientation_Portrait ||
            [self _whetherToSupportOnlyOneOrientation] ) {
            if ( _clickedBackItemExeBlock ) _clickedBackItemExeBlock(self);
        }
        else {
            [_videoPlayer rotate];
        }
    }
}

- (BOOL)_whetherToSupportOnlyOneOrientation {
    if ( _videoPlayer.supportedOrientation == SJAutoRotateSupportedOrientation_Portrait ) return YES;
    if ( _videoPlayer.supportedOrientation == SJAutoRotateSupportedOrientation_LandscapeLeft ) return YES;
    if ( _videoPlayer.supportedOrientation == SJAutoRotateSupportedOrientation_LandscapeRight ) return YES;
    return NO;
}

@synthesize reloadButton = _reloadButton;
- (UIButton *)reloadButton {
    if ( _reloadButton ) return _reloadButton;
    _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reloadButton addTarget:self action:@selector(clickedFailedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self _updateContent];
    __weak typeof(self) _self = self;
    _reloadButton.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _updateContent];
    }];
    return _reloadButton;
}

- (void)clickedFailedButton:(UIButton *)btn {
    if ( _clickedFaliedButtonExeBlock ) _clickedFaliedButtonExeBlock(self);
}

- (void)_updateContent {
    SJEdgeControlLayerSettings *setting = [SJEdgeControlLayerSettings commonSettings];
    [_reloadButton setAttributedTitle:sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        if ( setting.playFailedBtnImage ) {
            make.insert(setting.playFailedBtnImage, 0, CGPointZero, setting.playFailedBtnImage.size);
        }
        if ( setting.playFailedBtnImage && 0 != setting.playFailedBtnTitle.length ) {
            make.insertText(@"\n", -1);
        }
        
        if ( 0 != setting.playFailedBtnTitle.length ) {
            make.insert([NSString stringWithFormat:@"%@", setting.playFailedBtnTitle], -1);
            make.lastInserted(^(SJAttributesRangeOperator * _Nonnull lastOperator) {
                lastOperator
                .font(setting.playFailedBtnFont)
                .textColor(setting.playFailedBtnTitleColor);
            });
        }
        make.alignment(NSTextAlignmentCenter).lineSpacing(6);
    }) forState:UIControlStateNormal];
}


#pragma mark - player delegate methods
- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
    if ( _prepareToPlayNewAssetExeBlock ) _prepareToPlayNewAssetExeBlock(self);
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer { }

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer { }

- (BOOL)controlLayerDisappearCondition {
    return NO;
}

- (UIView *)controlView {
    return self;
}

- (BOOL)triggerGesturesCondition:(CGPoint)location {
    return NO;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _videoPlayer = videoPlayer;
    [videoPlayer.view layoutIfNeeded];
    
    [self _show:_topContainerView animated:NO];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull {
    [self.topAdapter reload];
}

#pragma mark -
- (BOOL)_isHiddenWithView:(UIView *)view {
    return view.sjv_disappeared;
}

- (void)_show:(UIView *)view animated:(BOOL)animated {
    [self _show:view animated:animated completionHandler:nil];
}

- (void)_hidden:(UIView *)view animated:(BOOL)animated {
    [self _hidden:view animated:animated completionHandler:nil];
}

- (void)_show:(UIView *)view animated:(BOOL)animated completionHandler:(void(^_Nullable)(void))completionHandler {
    if ( !view.sjv_disappeared ) return;
    if ( animated ) {
        UIView_Animations(CommonAnimaDuration, ^{
            [view sjv_appear];
        }, completionHandler);
    }
    else [view sjv_appear];
}

- (void)_hidden:(UIView *)view animated:(BOOL)animated completionHandler:(void(^_Nullable)(void))completionHandler {
    if ( view.sjv_disappeared ) return;
    if ( animated ) {
        UIView_Animations(CommonAnimaDuration, ^{
            [view sjv_disapear];
        }, completionHandler);
    }
    else [view sjv_disapear];
}
@end
NS_ASSUME_NONNULL_END
