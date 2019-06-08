//
//  SJFloatSmallViewControlLayer.m
//  Pods
//
//  Created by BlueDancer on 2019/6/6.
//

#import "SJFloatSmallViewControlLayer.h"
#import "UIView+SJAnimationAdded.h"
#import "SJFloatSmallViewControlLayerResourceLoader.h"
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJBaseVideoPlayer/SJBaseVideoPlayer+PlayStatus.h>
#else
#import "SJBaseVideoPlayer.h"
#import "SJBaseVideoPlayer+PlayStatus.h"
#endif

NS_ASSUME_NONNULL_BEGIN
SJEdgeControlButtonItemTag const SJFloatSmallViewControlLayerTopItem_Close = 10000;

@interface SJFloatSmallViewControlLayer ()
@property (nonatomic, weak, nullable) __kindof SJBaseVideoPlayer *player;
@end

@implementation SJFloatSmallViewControlLayer
@synthesize restarted = _restarted;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)tappedCloseItem:(SJEdgeControlButtonItem *)item {
    [self.player pause];
    [self.player.floatSmallViewController dismissFloatView];
}

- (void)_setupView {
    self.topMargin = 0;
    self.topHeight = 35;
    
    SJEdgeControlButtonItem *fillItem = [[SJEdgeControlButtonItem alloc] initWithTag:0];
    fillItem.fill = YES;
    [self.topAdapter addItem:fillItem];
    
    SJEdgeControlButtonItem *closeItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJFloatSmallViewControlLayerTopItem_Close];
    [closeItem addTarget:self action:@selector(tappedCloseItem:)];
    closeItem.image = SJFloatSmallViewControlLayerResourceLoader.shared.floatSmallViewCloseImage;
    [self.topAdapter addItem:closeItem];
    
    [self.topAdapter reload];
}

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
    _player = videoPlayer;
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer { }

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer { }

- (BOOL)canTriggerRotationOfVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    return NO;
}
@end
NS_ASSUME_NONNULL_END
