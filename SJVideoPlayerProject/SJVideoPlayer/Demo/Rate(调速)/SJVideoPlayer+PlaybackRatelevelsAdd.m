//
//  SJVideoPlayer+PlaybackRatelevelsAdd.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/3/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJVideoPlayer+PlaybackRatelevelsAdd.h"
#import <objc/message.h>
#import "SJSetPlaybackRateControlLayer.h"
#import "SJEdgeControlButtonItemDelegate.h"
#import "SJAttributesFactory.h"
#import "SJBaseVideoPlayer+SetPlaybackRateAdd.h"

NS_ASSUME_NONNULL_BEGIN
static SJEdgeControlButtonItemTag const SJSetPlaybackRateItem = 666;
SJControlLayerIdentifier const SJControlLayer_SetPlaybackRate = 666;

@implementation SJVideoPlayer (PlaybackRatelevelsAdd)
- (void)setShowSetPlaybackRateItem:(BOOL)showSetPlaybackRateItem {
    objc_setAssociatedObject(self, @selector(showSetPlaybackRateItem), @(showSetPlaybackRateItem), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( showSetPlaybackRateItem ) {
        // add item
        SJEdgeControlButtonItem *item = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJSetPlaybackRateItem];
        item.insets = SJEdgeInsetsMake(-8, 0);
        [self.defaultEdgeControlLayer.bottomAdapter insertItem:item rearItem:SJEdgeControlLayerBottomItem_FullBtn];
        SJEdgeControlButtonItemDelegate *itemDelegate = [[SJEdgeControlButtonItemDelegate alloc] initWithItem:item];
        
        // update item if needed
        __weak typeof(self) _self = self;
        itemDelegate.updatePropertiesIfNeeded = ^(SJEdgeControlButtonItem * _Nonnull item, __kindof SJBaseVideoPlayer * _Nonnull player) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            item.title = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                NSString *name = nil;
                make.alignment(NSTextAlignmentCenter);
                if ( player.rateLevels.level != SJPlaybackRateLevel_1 ) {
                    name = [player.rateLevels toString:player.rateLevels.level];
                }
                else {
                    name = @"倍速";
                }
                make.append(name);
                make.textColor([UIColor whiteColor]);
                make.font([UIFont systemFontOfSize:13]);
            }];
        };
        
        itemDelegate.clickedItemExeBlock = ^(SJEdgeControlButtonItem * _Nonnull item) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.switcher switchControlLayerForIdentitfier:SJControlLayer_SetPlaybackRate];
        };
        objc_setAssociatedObject(self, _cmd, itemDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        // add to switcher
        [self.switcher addControlLayerForIdentifier:SJControlLayer_SetPlaybackRate lazyLoading:^id<SJControlLayer> _Nonnull(SJControlLayerIdentifier identifier) {
            SJSetPlaybackRateControlLayer *controlLayer = [[SJSetPlaybackRateControlLayer alloc] initWithFrame:CGRectZero];
            controlLayer.clickedLevelItemExeBlock = ^(SJPlaybackRateLevel level) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                self.rateLevels.level = level;
                self.rate = 1.0 * level / 100;
                [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.defaultEdgeControlLayer.bottomAdapter reload];
                });
            };
            
            controlLayer.clickedEmptyAreaExeBlock = ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self.switcher switchControlLayerForIdentitfier:SJControlLayer_Edge];
            };
            return controlLayer;
        }];
    }
    else {
        // remove
        [self.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJSetPlaybackRateItem];
        [self.switcher deleteControlLayerForIdentifier:SJControlLayer_SetPlaybackRate];
        objc_setAssociatedObject(self, _cmd, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
- (BOOL)showSetPlaybackRateItem {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end
NS_ASSUME_NONNULL_END
