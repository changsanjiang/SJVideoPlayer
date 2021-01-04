//
//  SJMoreSettingControlLayer.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/7/19.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJMoreSettingControlLayer.h"
#import "UIView+SJAnimationAdded.h"
#import "SJButtonProgressSlider.h"
#import "SJVideoPlayerConfigurations.h"

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

NS_ASSUME_NONNULL_BEGIN
SJEdgeControlButtonItemTag const SJMoreSettingControlLayerItem_Volume = 10000;
SJEdgeControlButtonItemTag const SJMoreSettingControlLayerItem_Brightness = 10001;
SJEdgeControlButtonItemTag const SJMoreSettingControlLayerItem_Rate = 10002;

@interface SJMoreSettingControlLayer ()<SJProgressSliderDelegate>
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *videoPlayer;
@end

@implementation SJMoreSettingControlLayer
@synthesize restarted = _restarted;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _videoPlayer = videoPlayer;
    
    sj_view_initializes(self.rightContainerView);
    
    [self layoutIfNeeded];
    
    sj_view_makeDisappear(self.rightContainerView, NO);
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
    [self _refreshValueForSliderItems];
    sj_view_makeAppear(self.controlView, YES);
    sj_view_makeAppear(self.rightContainerView, YES);
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer { }

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer { }

- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    if ( type == SJPlayerGestureType_SingleTap ) {
        if ( !CGRectContainsPoint(self.rightContainerView.frame, location) ) {
            if ( [self.delegate respondsToSelector:@selector(tappedBlankAreaOnTheControlLayer:)] ) {
                [self.delegate tappedBlankAreaOnTheControlLayer:self];
            }
        }
    }
    else if ( type == SJPlayerGestureType_Pan && !CGRectContainsPoint(self.rightContainerView.frame, location) ) {
        return videoPlayer.gestureControl.movingDirection == SJPanGestureMovingDirection_V;
    }
    else if ( type == SJPlayerGestureType_DoubleTap )
        return YES;
    
    return NO;
}

- (BOOL)canTriggerRotationOfVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    return NO;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer volumeChanged:(float)volume {
    [self _setSliderValueForItemTag:SJMoreSettingControlLayerItem_Volume value:volume];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer brightnessChanged:(float)brightness {
    [self _setSliderValueForItemTag:SJMoreSettingControlLayerItem_Brightness value:brightness];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer rateChanged:(float)rate {
    [videoPlayer.prompt show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append([NSString stringWithFormat:@"%.0f %%", rate * 100]);
        make.textColor(UIColor.whiteColor);
    }]];
    [self _setSliderValueForItemTag:SJMoreSettingControlLayerItem_Rate value:rate];
}

#pragma mark -

- (void)sliderWillBeginDragging:(SJProgressSlider *)slider {
    if ( slider.tag == SJMoreSettingControlLayerItem_Volume ) {
        _videoPlayer.deviceVolumeAndBrightnessManager.volumeTracking = YES;
    }
    else if ( slider.tag == SJMoreSettingControlLayerItem_Brightness ) {
        _videoPlayer.deviceVolumeAndBrightnessManager.brightnessTracking = YES;
    }
}

- (void)slider:(SJProgressSlider *)slider valueDidChange:(CGFloat)value {
    if ( slider.isDragging ) {
        if ( slider.tag == SJMoreSettingControlLayerItem_Volume ) {
            _videoPlayer.deviceVolumeAndBrightnessManager.volume = slider.value;
        }
        else if ( slider.tag == SJMoreSettingControlLayerItem_Brightness ) {
            _videoPlayer.deviceVolumeAndBrightnessManager.brightness = slider.value;
        }
        else {
            _videoPlayer.rate = slider.value;
        }
    }
}

- (void)sliderDidEndDragging:(SJProgressSlider *)slider {
    if ( slider.tag == SJMoreSettingControlLayerItem_Volume ) {
        _videoPlayer.deviceVolumeAndBrightnessManager.volumeTracking = NO;
    }
    else if ( slider.tag == SJMoreSettingControlLayerItem_Brightness ) {
        _videoPlayer.deviceVolumeAndBrightnessManager.brightnessTracking = NO;
    }
}

#pragma mark -

- (void)_setupView {
    self.rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
    
    CGFloat max = MAX(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    self.rightWidth = floor(max * 0.382);
    
    CGFloat height = 60;
    
    {
        SJEdgeControlButtonItem *volumeItem = [SJEdgeControlButtonItem placeholderWithSize:height tag:SJMoreSettingControlLayerItem_Volume];
        SJButtonProgressSlider *progressView = SJButtonProgressSlider.new;
        progressView.slider.delegate = self;
        progressView.slider.tag = volumeItem.tag;
        volumeItem.customView = progressView;
        [self.rightAdapter addItem:volumeItem];
    }
    
    {
        SJEdgeControlButtonItem *brightnessItem = [SJEdgeControlButtonItem placeholderWithSize:height tag:SJMoreSettingControlLayerItem_Brightness];
        SJButtonProgressSlider *progressView = SJButtonProgressSlider.new;
        progressView.slider.delegate = self;
        progressView.slider.tag = brightnessItem.tag;
        brightnessItem.customView = progressView;
        [self.rightAdapter addItem:brightnessItem];
    }
    
    {
        SJEdgeControlButtonItem *rateItem = [SJEdgeControlButtonItem placeholderWithSize:height tag:SJMoreSettingControlLayerItem_Rate];
        SJButtonProgressSlider *progressView = SJButtonProgressSlider.new;
        progressView.slider.delegate = self;
        progressView.slider.tag = rateItem.tag;
        progressView.slider.maxValue = SJVideoPlayerConfigurations.shared.resources.moreSliderMaxRateValue;
        progressView.slider.minValue = SJVideoPlayerConfigurations.shared.resources.moreSliderMinRateValue;
        rateItem.customView = progressView;
        [self.rightAdapter addItem:rateItem];
    }
    
    [self _refreshSettings];
    [self.rightAdapter reload];
}

- (void)_refreshValueForSliderItems {
    [self _setSliderValueForItemTag:SJMoreSettingControlLayerItem_Volume value:_videoPlayer.deviceVolumeAndBrightnessManager.volume];
    [self _setSliderValueForItemTag:SJMoreSettingControlLayerItem_Brightness value:_videoPlayer.deviceVolumeAndBrightnessManager.brightness];
    [self _setSliderValueForItemTag:SJMoreSettingControlLayerItem_Rate value:_videoPlayer.rate];
}

- (void)_setSliderValueForItemTag:(SJEdgeControlButtonItemTag)itemTag value:(float)value {
    SJEdgeControlButtonItem *item = [self.rightAdapter itemForTag:itemTag];
    SJButtonProgressSlider *progressView = item.customView;
    if ( !progressView.slider.isDragging )
        progressView.slider.value = value;
}

- (void)_refreshSettings {
    id<SJVideoPlayerControlLayerResources> sources = SJVideoPlayerConfigurations.shared.resources;
    self.rightContainerView.backgroundColor = sources.moreControlLayerBackgroundColor;
    
    __auto_type _configProgressView = ^(SJButtonProgressSlider *progressView, UIImage *left, UIImage *right) {
        [progressView.rightBtn setImage:right forState:UIControlStateNormal];
        [progressView.leftBtn setImage:left forState:UIControlStateNormal];

        progressView.slider.traceImageView.backgroundColor = sources.moreSliderTraceColor;
        progressView.slider.trackImageView.backgroundColor = sources.moreSliderTrackColor;
        progressView.slider.trackHeight = sources.moreSliderTrackHeight;
        
        if ( sources.moreSliderThumbImage == nil ) {
            CGSize size = CGSizeMake(sources.moreSliderThumbSize, sources.moreSliderThumbSize);
            CGFloat radius = sources.moreSliderThumbSize * 0.5;
            [progressView.slider setThumbCornerRadius:radius size:size thumbBackgroundColor:sources.moreSliderTraceColor];
        }
        else {
            progressView.slider.thumbImageView.image = sources.moreSliderThumbImage;
        }
    };
    SJEdgeControlButtonItem *volumeItem = [self.rightAdapter itemForTag:SJMoreSettingControlLayerItem_Volume];
    _configProgressView(volumeItem.customView, sources.moreSliderMinVolumeImage, sources.moreSliderMaxVolumeImage);
    
    SJEdgeControlButtonItem *brightness = [self.rightAdapter itemForTag:SJMoreSettingControlLayerItem_Brightness];
    _configProgressView(brightness.customView, sources.moreSliderMinBrightnessImage, sources.moreSliderMaxBrightnessImage);
    
    SJEdgeControlButtonItem *rateItem = [self.rightAdapter itemForTag:SJMoreSettingControlLayerItem_Rate];
    _configProgressView(rateItem.customView, sources.moreSliderMinRateImage, sources.moreSliderMaxRateImage);
}
@end
NS_ASSUME_NONNULL_END
