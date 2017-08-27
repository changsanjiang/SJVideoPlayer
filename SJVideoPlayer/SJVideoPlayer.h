//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView, UIImage, UIColor, SJVideoPlayerMoreSetting, SJVideoPlayerMoreSetting;

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
 *  clicked More button to display items.
 */
- (void)moreSettings:(void(^)(NSMutableArray<SJVideoPlayerMoreSetting *> *moreSettings))block;

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

/*!
 *  duration default is 1.0
 */
- (void)showTitle:(NSString *)title;

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration;

@end





// MARK: More Settings Model

@class SJVideoPlayerMoreSettingTwoSetting;

@interface SJVideoPlayerMoreSetting : NSObject

// MARK: ... Class methods

/*!
 *  SJVideoPlayerMoreSetting.titleColor = [UIColor whiteColor];
 *
 *  default is whiteColor
 */
@property (class, nonatomic, strong) UIColor *titleColor;

/*!
 *  SJVideoPlayerMoreSetting.titleFontSize = 12;
 *
 *  deafult is 12
 */
@property (class, nonatomic, assign) double titleFontSize;


// MARK: ... Instance Methods.   show 1 level interface

@property (nonatomic, strong, nullable) NSString *title;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, copy) void(^clickedExeBlock)(SJVideoPlayerMoreSetting *model);

- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
              clickedExeBlock:(void(^)(SJVideoPlayerMoreSetting *model))block;


// MARK: ... Instance Methods.   show 2 level interface

@property (nonatomic, assign, getter=isShowTowSetting) BOOL showTowSetting;
@property (nonatomic, strong) NSString *twoSettingTitle;
@property (nonatomic, strong) NSArray<SJVideoPlayerMoreSettingTwoSetting *> *twoSettingItems;

- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
               showTowSetting:(BOOL)showTowSetting                                      // show
              twoSettingTitle:(NSString *)twoSettingTitle                               // title
              twoSettingItems:(NSArray<SJVideoPlayerMoreSettingTwoSetting *> *)items    // items
              clickedExeBlock:(void(^)(SJVideoPlayerMoreSetting *model))block;

@end


@interface SJVideoPlayerMoreSettingTwoSetting : SJVideoPlayerMoreSetting @end


NS_ASSUME_NONNULL_END
