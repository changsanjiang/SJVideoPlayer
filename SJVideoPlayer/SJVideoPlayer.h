//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView, UIImage, UIColor, SJVideoPlayerMoreSetting;

NS_ASSUME_NONNULL_BEGIN


@interface SJVideoPlayerSettings : NSObject

// MARK: btns
@property (nonatomic, strong, readwrite) UIImage *backBtnImage;
@property (nonatomic, strong, readwrite) UIImage *playBtnImage;
@property (nonatomic, strong, readwrite) UIImage *pauseBtnImage;
@property (nonatomic, strong, readwrite) UIImage *replayBtnImage;
@property (nonatomic, strong, readwrite) NSString *replayBtnTitle;
@property (nonatomic, assign, readwrite) float replayBtnFontSize;
@property (nonatomic, strong, readwrite) UIImage *fullBtnImage;
@property (nonatomic, strong, readwrite) UIImage *previewBtnImage;
@property (nonatomic, strong, readwrite) UIImage *moreBtnImage;
@property (nonatomic, strong, readwrite) UIImage *lockBtnImage;
@property (nonatomic, strong, readwrite) UIImage *unlockBtnImage;

// MARK: slider
@property (nonatomic, strong, readwrite) UIColor *traceColor;
@property (nonatomic, strong, readwrite) UIColor *trackColor;
@property (nonatomic, strong, readwrite) UIColor *bufferColor;

// MARK: volume & brightness
@property (nonatomic, strong, readwrite) UIImage *volumeImage;
@property (nonatomic, strong, readwrite) UIImage *muteImage;
@property (nonatomic, strong, readwrite) UIImage *brightnessImage;

@end






@interface SJVideoPlayer : NSObject

+ (instancetype)sharedPlayer;

- (void)playerSettings:(void(^)(SJVideoPlayerSettings *settings))block;

/*!
 *  clicked back btn exe block.
 */
@property (nonatomic, copy, readwrite) void(^clickedBackEvent)();

/*!
 *  if you want to play, you need to set it up.
 */
@property (nonatomic, strong, readwrite) NSURL *assetURL;

/*!
 *  present View. you shuold set it frame (support autoLayout).
 */
@property (nonatomic, strong, readonly) UIView *view;

/*!
 *  loading show this.
 */
@property (nonatomic, strong, readwrite) UIImage *placeholder;

/*!
 *  clicked More button to display items.
 */
@property (nonatomic, strong, readwrite) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

/*!
 *  error.
 */
@property (nonatomic, strong, readonly) NSError *error;

@end



@interface SJVideoPlayer (Operation)

- (NSTimeInterval)currentTime;

- (void)pause;

- (void)play;

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

- (void)stop;

/*!
 *  0.5 ... 2
 */
@property (nonatomic, assign, readwrite) float rate;

- (UIImage *)screenShot;

@end


@interface SJVideoPlayer (Prompt)

- (void)showTitle:(NSString *)title;

@end



NS_ASSUME_NONNULL_END
