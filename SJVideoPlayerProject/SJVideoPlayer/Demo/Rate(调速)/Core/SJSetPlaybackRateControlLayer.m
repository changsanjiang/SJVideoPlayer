//
//  SJSetPlaybackRateControlLayer.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/3/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJSetPlaybackRateControlLayer.h"
#if __has_include(<SJAttributesFactory/SJAttributeWorker.h>)
#import <SJAttributesFactory/SJAttributeWorker.h>
#else
#import "SJAttributeWorker.h"
#endif
#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#else
#import "SJBaseVideoPlayer.h"
#endif

#import "UIView+SJVideoPlayerSetting.h"
#import "UIView+SJAnimationAdded.h"
#import "SJVideoPlayerAnimationHeader.h"
#import "SJBaseVideoPlayer+SetPlaybackRateAdd.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJSetPlaybackRateControlLayer ()
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *player;
@end

@implementation SJSetPlaybackRateControlLayer
@synthesize restarted = _restarted;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    return self;
}

- (void)clickedLevelItem:(SJEdgeControlButtonItem *)item {
    if ( _clickedLevelItemExeBlock ) _clickedLevelItemExeBlock(item.tag);
}

- (void)_setupViews {
    self.rightWidth = 120;
    self.rightContainerView.backgroundColor = [UIColor blackColor];
    self.rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
    [self _addItemsToRightAdapter];
    [self _updateItemsForRightAdapter];
}

- (void)_addItemsToRightAdapter {
    SJEdgeControlButtonItem *(^addItem)(SJPlaybackRateLevel) = ^SJEdgeControlButtonItem*(SJPlaybackRateLevel l) {
        SJEdgeControlButtonItem *item = [SJEdgeControlButtonItem placeholderWithSize:30 tag:l];
        [item addTarget:self action:@selector(clickedLevelItem:)];
        return item;
    };
    
    SJEdgeControlButtonItem *item_1 = addItem(SJPlaybackRateLevel_1);
    [self.rightAdapter addItem:item_1];
    [self.rightAdapter addItem:[SJEdgeControlButtonItem placeholderWithSize:12 tag:1]]; // 间隔
    
    SJEdgeControlButtonItem *item_2 = addItem(SJPlaybackRateLevel_2);
    [self.rightAdapter addItem:item_2];
    [self.rightAdapter addItem:[SJEdgeControlButtonItem placeholderWithSize:12 tag:2]]; // 间隔
    
    SJEdgeControlButtonItem *item_3 = addItem(SJPlaybackRateLevel_3);
    [self.rightAdapter addItem:item_3];
    [self.rightAdapter addItem:[SJEdgeControlButtonItem placeholderWithSize:12 tag:3]]; // 间隔
    
    SJEdgeControlButtonItem *item_4 = addItem(SJPlaybackRateLevel_4);
    [self.rightAdapter addItem:item_4];
    
    [self.rightAdapter reload];
}

- (void)_updateItemsForRightAdapter {
    NSAttributedString *(^makeTitle)(SJPlaybackRateLevel) = ^NSAttributedString *(SJPlaybackRateLevel l) {
        return sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
            make.alignment(NSTextAlignmentCenter);
            make.append([self.player.rateLevels toString:l]);
            if ( l == self.player.rateLevels.level )
                make.textColor([UIColor greenColor]);
            else
                make.textColor([UIColor whiteColor]);
        });
    };
    
    [self.rightAdapter itemForTag:SJPlaybackRateLevel_1].title = makeTitle(SJPlaybackRateLevel_1);
    [self.rightAdapter itemForTag:SJPlaybackRateLevel_2].title = makeTitle(SJPlaybackRateLevel_2);
    [self.rightAdapter itemForTag:SJPlaybackRateLevel_3].title = makeTitle(SJPlaybackRateLevel_3);
    [self.rightAdapter itemForTag:SJPlaybackRateLevel_4].title = makeTitle(SJPlaybackRateLevel_4);
    [self.rightAdapter reload];
}

#pragma mark -
- (void)restartControlLayer {
    _restarted = YES;
    sj_view_makeAppear(self.controlView, YES);
    sj_view_makeAppear(self.rightContainerView, YES);
}

- (void)exitControlLayer {
    _restarted = NO;
    
    sj_view_makeDisappear(self.rightContainerView, YES);
    sj_view_makeDisappear(self.controlView, YES, ^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    });
}

- (UIView *)controlView {
    return self;
}

- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    BOOL trigger = !CGRectContainsPoint(self.rightContainerView.frame, location);
    return trigger;
}

/// 禁止自动隐藏
- (BOOL)controlLayerOfVideoPlayerCanAutomaticallyDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    return NO;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _player = videoPlayer;
    [self _updateItemsForRightAdapter];
    sj_view_initializes(self.rightContainerView);
    sj_view_makeDisappear(_rightContainerView, NO);
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {}
- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( _clickedEmptyAreaExeBlock ) _clickedEmptyAreaExeBlock();
}
@end
NS_ASSUME_NONNULL_END
