//
//  SJFloatSmallViewControlLayer.m
//  Pods
//
//  Created by 畅三江 on 2019/6/6.
//

#import "SJFloatSmallViewControlLayer.h"
#import "UIView+SJAnimationAdded.h"
#import "SJVideoPlayerSettings.h"
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#else
#import "SJBaseVideoPlayer.h" 
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

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    for ( UIGestureRecognizer *gesture in self.controlView.superview.superview.gestureRecognizers ) {
        if ( [gesture isKindOfClass:UITapGestureRecognizer.class] && gesture.isEnabled ) {
            SJEdgeControlButtonItem *_Nullable item = [self.topAdapter itemAtPoint:[self convertPoint:point toView:self.topAdapter.view]];
            
            if ( item == nil && self->_leftAdapter != nil ) {
                item = [self->_leftAdapter itemAtPoint:[self convertPoint:point toView:self->_leftAdapter.view]];
            }
            if ( item == nil && self->_bottomAdapter != nil ) {
                item = [self->_bottomAdapter itemAtPoint:[self convertPoint:point toView:self->_bottomAdapter.view]];
            }
            if ( item == nil && self->_rightAdapter != nil ) {
                item = [self->_rightAdapter itemAtPoint:[self convertPoint:point toView:self->_rightAdapter.view]];
            }
            if ( item == nil && self->_centerAdapter != nil ) {
                item = [self->_centerAdapter itemAtPoint:[self convertPoint:point toView:self->_centerAdapter.view]];
            }
            
            if ( item.action != NULL || item.customView != nil ) {
                gesture.enabled = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    gesture.enabled = YES;
                });
            }
        }
    }
    return [super hitTest:point withEvent:event];
}

- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _player = videoPlayer;
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
    closeItem.image = SJVideoPlayerSettings.commonSettings.floatSmallViewCloseImage;
    [self.topAdapter addItem:closeItem];
    
    [self.topAdapter reload];
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer { }

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer { }

- (BOOL)canTriggerRotationOfVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    return NO;
}
@end
NS_ASSUME_NONNULL_END
