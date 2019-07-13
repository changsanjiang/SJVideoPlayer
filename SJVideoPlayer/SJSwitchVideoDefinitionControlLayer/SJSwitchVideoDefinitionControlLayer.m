//
//  SJSwitchVideoDefinitionControlLayer.m
//  Pods
//
//  Created by 畅三江 on 2019/7/12.
//

#import "SJSwitchVideoDefinitionControlLayer.h"
#if __has_include(<SJUIKit/SJAttributesFactory.h>)
#import <SJUIKit/SJAttributesFactory.h>
#else
#import "SJAttributesFactory.h"
#endif

#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#else
#import "SJBaseVideoPlayer.h"
#endif

#import "UIView+SJAnimationAdded.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJSwitchVideoDefinitionControlLayer ()
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *videoPlayer;
@property (nonatomic, copy, nullable) NSArray<SJEdgeControlButtonItem *> *items;
@end

@implementation SJSwitchVideoDefinitionControlLayer
@synthesize restarted = _restarted;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        self.rightWidth = 140;
        self.rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
        self.rightContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    }
    return self;
}

- (void)exitControlLayer {
    _restarted = NO;
    
    sj_view_makeDisappear(self.rightContainerView, YES);
    sj_view_makeDisappear(self.controlView, YES, ^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    });
}

- (void)restartControlLayer {
    _restarted = YES;
    
    if ( self.videoPlayer.isFullScreen )
        [self.videoPlayer needHiddenStatusBar];
    [self _refreshItems];
    [self.rightAdapter reload];
    sj_view_makeAppear(self.controlView, YES);
    sj_view_makeAppear(self.rightContainerView, YES);
}

- (UIView *)controlView {
    return self;
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer { }

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer { }

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _videoPlayer = videoPlayer;
    
    [self layoutIfNeeded];
    
    sj_view_makeDisappear(self.rightContainerView, NO);
}

- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    if ( type == SJPlayerGestureType_SingleTap ) {
        if ( !CGRectContainsPoint(self.rightContainerView.frame, location) ) {
            if ( [self.delegate respondsToSelector:@selector(tappedOnTheBlankAreaOfControlLayer:)] ) {
                [self.delegate tappedOnTheBlankAreaOfControlLayer:self];
            }
        }
    }
    return NO;
}

- (BOOL)canTriggerRotationOfVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    return NO;
}

- (void)_clickedItem:(SJEdgeControlButtonItem *)item {
    if ( [self.delegate respondsToSelector:@selector(controlLayer:didSelectAsset:)] ) {
        [self.delegate controlLayer:self didSelectAsset:self.assets[item.tag]];
    }
}

#pragma mark -

- (void)setAssets:(nullable NSArray<SJVideoPlayerURLAsset *> *)assets {
    _assets = assets.copy;
    [self.rightAdapter removeAllItems];
    NSMutableArray<SJEdgeControlButtonItem *> *m = [NSMutableArray new];
    [_assets enumerateObjectsUsingBlock:^(SJVideoPlayerURLAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SJEdgeControlButtonItem *item = [SJEdgeControlButtonItem placeholderWithSize:38 tag:idx];
        [item addTarget:self action:@selector(_clickedItem:)];
        [m addObject:item];
    }];
    self.items = m;
    [self _refreshItems];
    [self.rightAdapter addItemsFromArray:self.items];
    [self.rightAdapter reload];
}

- (void)_refreshItems {
    SJVideoPlayerURLAsset *_Nullable current = _videoPlayer.URLAsset;
    if ( current != nil ) {
        SJVideoDefinitionSwitchingInfo *info = _videoPlayer.definitionSwitchingInfo;
        for ( SJEdgeControlButtonItem *item in self.items ) {
            SJVideoPlayerURLAsset *asset = self.assets[item.tag];
            item.title = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append([NSString stringWithFormat:@"%@", asset.definition_fullName]);
                make.font([UIFont systemFontOfSize:14]);
                make.alignment(NSTextAlignmentCenter);
                
                UIColor *textColor = nil;
                if ( asset == info.switchingAsset ) {
                    textColor = UIColor.orangeColor;
                }
                else if ( info.switchingAsset == nil && asset == current ) {
                    textColor = UIColor.orangeColor;
                }
                else {
                    textColor = UIColor.whiteColor;
                }
                make.textColor(textColor);
            }];
        }
    }
}
@end
NS_ASSUME_NONNULL_END
