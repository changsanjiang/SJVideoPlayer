//
//  SJVideoPlayerSettings.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerSettings.h"
#import <UIKit/UIKit.h>
#import "SJFilmEditingSettings.h"
#import "SJEdgeControlLayerSettings.h"

@implementation SJVideoPlayerSettings

+ (instancetype)commonSettings {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
        [_instance reset];
    });
    return _instance;
}

+ (void (^)(void (^ _Nonnull)(SJVideoPlayerSettings * _Nonnull)))update {
    return ^(void(^block)(SJVideoPlayerSettings *settings)) {
        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block([SJVideoPlayerSettings commonSettings]);
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                [[NSNotificationCenter defaultCenter] postNotificationName:SJSettingsPlayerNotification object:[SJEdgeControlLayerSettings commonSettings]];
                [[NSNotificationCenter defaultCenter] postNotificationName:SJFilmEditingSettingsUpdateNotification object:[SJFilmEditingSettings commonSettings]];
            });
        });
    };
}
- (void)reset {
    [[SJEdgeControlLayerSettings commonSettings] reset];
    [[SJFilmEditingSettings commonSettings] reset];
}
@end


@implementation SJVideoPlayerSettings (EdgeControlLayer)
+ (void (^)(void (^ _Nonnull)(SJVideoPlayerSettings * _Nonnull)))updateEdgeControlLayer {
    return ^(void(^block)(SJVideoPlayerSettings *settings)) {
        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block([SJVideoPlayerSettings commonSettings]);
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                [[NSNotificationCenter defaultCenter] postNotificationName:SJSettingsPlayerNotification object:[SJEdgeControlLayerSettings commonSettings]];
            });
        });
    };
}
- (void)resetEdgeControlLayer {
    return [[SJEdgeControlLayerSettings commonSettings] reset];
}
#pragma mark loading
- (void)setPlaceholder:(UIImage *)placeholder {
    [SJEdgeControlLayerSettings commonSettings].placeholder = placeholder;
}
- (UIImage *)placeholder {
    return [SJEdgeControlLayerSettings commonSettings].placeholder;
}
- (void)setLoadingLineColor:(UIColor *)loadingLineColor {
    [SJEdgeControlLayerSettings commonSettings].loadingLineColor = loadingLineColor;
}
- (UIColor *)loadingLineColor {
    return [SJEdgeControlLayerSettings commonSettings].loadingLineColor;
}
- (void)setFastImage:(UIImage *)fastImage {
    [SJEdgeControlLayerSettings commonSettings].fastImage = fastImage;
}
- (UIImage *)fastImage {
    return [SJEdgeControlLayerSettings commonSettings].fastImage;
}
- (void)setForwardImage:(UIImage *)forwardImage {
    [SJEdgeControlLayerSettings commonSettings].forwardImage = forwardImage;
}
- (UIImage *)forwardImage {
    return [SJEdgeControlLayerSettings commonSettings].forwardImage;
}

#pragma mark network
- (NSString *)notReachablePrompt {
    return [SJEdgeControlLayerSettings commonSettings].notReachablePrompt;
}
- (NSString *)reachableViaWWANPrompt {
    return [SJEdgeControlLayerSettings commonSettings].reachableViaWWANPrompt;
}

#pragma mark top
- (void)setBackBtnImage:(UIImage *)backBtnImage {
    [SJEdgeControlLayerSettings commonSettings].backBtnImage = backBtnImage;
}
- (UIImage *)backBtnImage {
    return [SJEdgeControlLayerSettings commonSettings].backBtnImage;
}
- (void)setPreviewBtnImage:(UIImage *)previewBtnImage {
    [SJEdgeControlLayerSettings commonSettings].previewBtnImage = previewBtnImage;
}
- (UIImage *)previewBtnImage {
    return [SJEdgeControlLayerSettings commonSettings].previewBtnImage;
}
- (void)setPreviewBtnFont:(UIFont *)previewBtnFont {
    [SJEdgeControlLayerSettings commonSettings].previewBtnFont = previewBtnFont;
}
- (UIFont *)previewBtnFont {
    return [SJEdgeControlLayerSettings commonSettings].previewBtnFont;
}
- (NSString *)previewBtnTitle {
    return [SJEdgeControlLayerSettings commonSettings].previewBtnTitle;
}
- (void)setMoreBtnImage:(UIImage *)moreBtnImage {
    [SJEdgeControlLayerSettings commonSettings].moreBtnImage = moreBtnImage;
}
- (UIImage *)moreBtnImage {
    return [SJEdgeControlLayerSettings commonSettings].moreBtnImage;
}
- (void)setTitleFont:(UIFont *)titleFont {
    [SJEdgeControlLayerSettings commonSettings].titleFont = titleFont;
}
- (UIFont *)titleFont {
    return [SJEdgeControlLayerSettings commonSettings].titleFont;
}
- (void)setTitleColor:(UIColor *)titleColor {
    [SJEdgeControlLayerSettings commonSettings].titleColor = titleColor;
}
- (UIColor *)titleColor {
    return [SJEdgeControlLayerSettings commonSettings].titleColor;
}
#pragma mark left
- (void)setLockBtnImage:(UIImage *)lockBtnImage {
    [SJEdgeControlLayerSettings commonSettings].lockBtnImage = lockBtnImage;
}
- (UIImage *)lockBtnImage {
    return [SJEdgeControlLayerSettings commonSettings].lockBtnImage;
}
- (void)setUnlockBtnImage:(UIImage *)unlockBtnImage {
    [SJEdgeControlLayerSettings commonSettings].unlockBtnImage = unlockBtnImage;
}
- (UIImage *)unlockBtnImage {
    return [SJEdgeControlLayerSettings commonSettings].unlockBtnImage;
}
#pragma mark bottom
- (void)setPlayBtnImage:(UIImage *)playBtnImage {
    [SJEdgeControlLayerSettings commonSettings].playBtnImage = playBtnImage;
}
- (UIImage *)playBtnImage {
    return [SJEdgeControlLayerSettings commonSettings].playBtnImage;
}
- (void)setPauseBtnImage:(UIImage *)pauseBtnImage {
    [SJEdgeControlLayerSettings commonSettings].pauseBtnImage = pauseBtnImage;
}
- (UIImage *)pauseBtnImage {
    return [SJEdgeControlLayerSettings commonSettings].pauseBtnImage;
}
//@property (nonatomic, assign) float progress_traceHeight;               // 轨道高度
//@property (nonatomic, strong) UIColor *progress_traceColor;             // 轨迹, 走过的痕迹
//@property (nonatomic, strong) UIColor *progress_trackColor;             // 轨道
//@property (nonatomic, strong) UIColor *progress_bufferColor;            // 缓冲颜色
//@property (nonatomic, strong, nullable) UIImage *progress_thumbImage;
//@property (nonatomic, assign) float progress_thumbSize;                 // default is 0.
//@property (nonatomic, strong, nullable) UIColor *progress_thumbColor;
- (void)setProgress_traceHeight:(float)progress_traceHeight {
    [SJEdgeControlLayerSettings commonSettings].progress_traceHeight = progress_traceHeight;
}
- (float)progress_traceHeight {
    return [SJEdgeControlLayerSettings commonSettings].progress_traceHeight;
}
- (void)setProgress_traceColor:(UIColor *)progress_traceColor {
    [SJEdgeControlLayerSettings commonSettings].progress_traceColor = progress_traceColor;
}
- (UIColor *)progress_traceColor {
    return [SJEdgeControlLayerSettings commonSettings].progress_traceColor;
}
- (void)setProgress_trackColor:(UIColor *)progress_trackColor {
    [SJEdgeControlLayerSettings commonSettings].progress_trackColor = progress_trackColor;
}
- (UIColor *)progress_trackColor {
    return [SJEdgeControlLayerSettings commonSettings].progress_trackColor;
}
- (void)setProgress_bufferColor:(UIColor *)progress_bufferColor {
    [SJEdgeControlLayerSettings commonSettings].progress_bufferColor = progress_bufferColor;
}
- (UIColor *)progress_bufferColor {
    return [SJEdgeControlLayerSettings commonSettings].progress_bufferColor;
}
/**
 Thumb image, also can set `progress_thumbSize `. (image is preferred)
 拇指图片, 也可设置`progress_thumbSize`.(图片优先)
 */
- (void)setProgress_thumbImage:(UIImage *)progress_thumbImage {
    [SJEdgeControlLayerSettings commonSettings].progress_thumbImage = progress_thumbImage;
}
- (UIImage *)progress_thumbImage {
    return [SJEdgeControlLayerSettings commonSettings].progress_thumbImage;
}
- (void)setProgress_thumbSize:(float)progress_thumbSize {
    [SJEdgeControlLayerSettings commonSettings].progress_thumbSize = progress_thumbSize;
}
- (float)progress_thumbSize {
    return [SJEdgeControlLayerSettings commonSettings].progress_thumbSize;
}
- (void)setProgress_thumbColor:(UIColor *)progress_thumbColor {
    [SJEdgeControlLayerSettings commonSettings].progress_thumbColor = progress_thumbColor;
}
- (UIColor *)progress_thumbColor {
    return [SJEdgeControlLayerSettings commonSettings].progress_thumbColor;
}
- (void)setFullBtnImage:(UIImage *)fullBtnImage {
    [SJEdgeControlLayerSettings commonSettings].fullBtnImage = fullBtnImage;
}
- (UIImage *)fullBtnImage {
    return [SJEdgeControlLayerSettings commonSettings].fullBtnImage;
}
- (void)setShrinkscreenImage:(UIImage *)shrinkscreenImage {
    [SJEdgeControlLayerSettings commonSettings].shrinkscreenImage = shrinkscreenImage;
}
- (UIImage *)shrinkscreenImage {
    return [SJEdgeControlLayerSettings commonSettings].shrinkscreenImage;
}
#pragma mark right
- (void)setFilmEditingBtnImage:(UIImage *)filmEditingBtnImage {
    [SJEdgeControlLayerSettings commonSettings].filmEditingBtnImage = filmEditingBtnImage;
}
- (UIImage *)filmEditingBtnImage {
    return [SJEdgeControlLayerSettings commonSettings].filmEditingBtnImage;
}
#pragma mark center
- (NSString *)replayBtnTitle {
    return [SJEdgeControlLayerSettings commonSettings].replayBtnTitle;
}
- (void)setReplayBtnImage:(UIImage *)replayBtnImage {
    [SJEdgeControlLayerSettings commonSettings].replayBtnImage = replayBtnImage;
}
- (UIImage *)replayBtnImage {
    return [SJEdgeControlLayerSettings commonSettings].replayBtnImage;
}
- (void)setReplayBtnFont:(UIFont *)replayBtnFont {
    [SJEdgeControlLayerSettings commonSettings].replayBtnFont = replayBtnFont;
}
- (UIFont *)replayBtnFont {
    return [SJEdgeControlLayerSettings commonSettings].replayBtnFont;
}
- (void)setReplayBtnTitleColor:(UIColor *)replayBtnTitleColor {
    [SJEdgeControlLayerSettings commonSettings].replayBtnTitleColor = replayBtnTitleColor;
}
- (UIColor *)replayBtnTitleColor {
    return [SJEdgeControlLayerSettings commonSettings].replayBtnTitleColor;
}
- (NSString *)playFailedBtnTitle {
    return [SJEdgeControlLayerSettings commonSettings].playFailedBtnTitle;
}
- (void)setPlayFailedBtnImage:(UIImage *)playFailedBtnImage {
    [SJEdgeControlLayerSettings commonSettings].playFailedBtnImage = playFailedBtnImage;
}
- (UIImage *)playFailedBtnImage {
    return [SJEdgeControlLayerSettings commonSettings].playFailedBtnImage;
}
- (void)setPlayFailedBtnFont:(UIFont *)playFailedBtnFont {
    [SJEdgeControlLayerSettings commonSettings].playFailedBtnFont = playFailedBtnFont;
}
- (UIFont *)playFailedBtnFont {
    return [SJEdgeControlLayerSettings commonSettings].playFailedBtnFont;
}
- (void)setPlayFailedBtnTitleColor:(UIColor *)playFailedBtnTitleColor {
    [SJEdgeControlLayerSettings commonSettings].playFailedBtnTitleColor = playFailedBtnTitleColor;
}
- (UIColor *)playFailedBtnTitleColor {
    return [SJEdgeControlLayerSettings commonSettings].playFailedBtnTitleColor;
}

#pragma mark more
- (void)setMoreBackgroundColor:(UIColor *)moreBackgroundColor {
    [SJEdgeControlLayerSettings commonSettings].moreBackgroundColor = moreBackgroundColor;
}
- (UIColor *)moreBackgroundColor {
    return [SJEdgeControlLayerSettings commonSettings].moreBackgroundColor;
}
- (void)setMore_traceColor:(UIColor *)more_traceColor {
    [SJEdgeControlLayerSettings commonSettings].more_traceColor = more_traceColor;
}
- (UIColor *)more_traceColor {
    return [SJEdgeControlLayerSettings commonSettings].more_traceColor;
}
- (void)setMore_trackColor:(UIColor *)more_trackColor {
    [SJEdgeControlLayerSettings commonSettings].more_trackColor = more_trackColor;
}
- (UIColor *)more_trackColor {
    return [SJEdgeControlLayerSettings commonSettings].more_trackColor;
}
- (void)setMore_trackHeight:(float)more_trackHeight {
    [SJEdgeControlLayerSettings commonSettings].more_trackHeight = more_trackHeight;
}
- (float)more_trackHeight {
    return [SJEdgeControlLayerSettings commonSettings].more_trackHeight;
}
- (void)setMore_thumbImage:(UIImage *)more_thumbImage {
    [SJEdgeControlLayerSettings commonSettings].more_thumbImage = more_thumbImage;
}
- (UIImage *)more_thumbImage {
    return [SJEdgeControlLayerSettings commonSettings].more_thumbImage;
}
- (void)setMore_thumbSize:(float)more_thumbSize {
    [SJEdgeControlLayerSettings commonSettings].more_thumbSize = more_thumbSize;
}
- (float)more_thumbSize {
    return [SJEdgeControlLayerSettings commonSettings].more_thumbSize;
}
- (void)setMore_minRateImage:(UIImage *)more_minRateImage {
    [SJEdgeControlLayerSettings commonSettings].more_minRateImage = more_minRateImage;
}
- (UIImage *)more_minRateImage {
    return [SJEdgeControlLayerSettings commonSettings].more_minRateImage;
}
- (void)setMore_maxRateImage:(UIImage *)more_maxRateImage {
    [SJEdgeControlLayerSettings commonSettings].more_maxRateImage = more_maxRateImage;
}
- (UIImage *)more_maxRateImage {
    return [SJEdgeControlLayerSettings commonSettings].more_maxRateImage;
}
- (void)setMore_minVolumeImage:(UIImage *)more_minVolumeImage {
    [SJEdgeControlLayerSettings commonSettings].more_minVolumeImage = more_minVolumeImage;
}
- (UIImage *)more_minVolumeImage {
    return [SJEdgeControlLayerSettings commonSettings].more_minVolumeImage;
}
- (void)setMore_maxVolumeImage:(UIImage *)more_maxVolumeImage {
    [SJEdgeControlLayerSettings commonSettings].more_maxVolumeImage = more_maxVolumeImage;
}
- (UIImage *)more_maxVolumeImage {
    return [SJEdgeControlLayerSettings commonSettings].more_maxVolumeImage;
}
- (void)setMore_minBrightnessImage:(UIImage *)more_minBrightnessImage {
    [SJEdgeControlLayerSettings commonSettings].more_minBrightnessImage = more_minBrightnessImage;
}
- (UIImage *)more_minBrightnessImage {
    return [SJEdgeControlLayerSettings commonSettings].more_minBrightnessImage;
}
- (void)setMore_maxBrightnessImage:(UIImage *)more_maxBrightnessImage {
    [SJEdgeControlLayerSettings commonSettings].more_maxBrightnessImage = more_maxBrightnessImage;
}
- (UIImage *)more_maxBrightnessImage {
    return [SJEdgeControlLayerSettings commonSettings].more_maxBrightnessImage;
}
@end


@implementation SJVideoPlayerSettings (FilmEditingControlLayer)
+ (void (^)(void (^ _Nonnull)(SJVideoPlayerSettings * _Nonnull)))updateFilmEditingControlLayer {
    return ^(void(^block)(SJVideoPlayerSettings *settings)) {
        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block([SJVideoPlayerSettings commonSettings]);
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                [[NSNotificationCenter defaultCenter] postNotificationName:SJFilmEditingSettingsUpdateNotification object:[SJFilmEditingSettings commonSettings]];
            });
        });
    };
}
- (void)resetFilmEditingControlLayer {
    return [[SJFilmEditingSettings commonSettings] reset];
}
- (NSString *)videoPlayDidToEndText {
    return [SJFilmEditingSettings commonSettings].videoPlayDidToEndText;
}
- (NSString *)cancelBtnTitle {
    return [SJFilmEditingSettings commonSettings].cancelBtnTitle;
}
- (NSString *)waitingForRecordingPromptText {
    return [SJFilmEditingSettings commonSettings].waitingForRecordingPromptText;
}
- (NSString *)finishRecordingPromptText {
    return [SJFilmEditingSettings commonSettings].finishRecordingPromptText;
}
- (NSString *)uploadingPrompt {
    return [SJFilmEditingSettings commonSettings].uploadingPrompt;
}
- (NSString *)uploadSuccessfullyPrompt {
    return [SJFilmEditingSettings commonSettings].uploadSuccessfullyPrompt;
}
- (NSString *)exportingPrompt {
    return [SJFilmEditingSettings commonSettings].exportingPrompt;
}
- (NSString *)exportSuccessfullyPrompt {
    return [SJFilmEditingSettings commonSettings].exportSuccessfullyPrompt;
}
- (NSString *)operationFailedPrompt {
    return [SJFilmEditingSettings commonSettings].operationFailedPrompt;
}
- (void)setScreenshotBtnImage:(UIImage *)screenshotBtnImage {
    [SJFilmEditingSettings commonSettings].screenshotBtnImage = screenshotBtnImage;
}
- (UIImage *)screenshotBtnImage {
    return [SJFilmEditingSettings commonSettings].screenshotBtnImage;
}
- (void)setExportBtnImage:(UIImage *)exportBtnImage {
    [SJFilmEditingSettings commonSettings].exportBtnImage = exportBtnImage;
}
- (UIImage *)exportBtnImage {
    return [SJFilmEditingSettings commonSettings].exportBtnImage;
}
- (void)setGifBtnImage:(UIImage *)gifBtnImage {
    [SJFilmEditingSettings commonSettings].gifBtnImage = gifBtnImage;
}
- (UIImage *)gifBtnImage {
    return [SJFilmEditingSettings commonSettings].gifBtnImage;
}
- (void)setFinishRecordingBtnImage:(UIImage *)finishRecordingBtnImage {
    [SJFilmEditingSettings commonSettings].finishRecordingBtnImage = finishRecordingBtnImage;
}
- (UIImage *)finishRecordingBtnImage {
    return [SJFilmEditingSettings commonSettings].finishRecordingBtnImage;
}
@end
