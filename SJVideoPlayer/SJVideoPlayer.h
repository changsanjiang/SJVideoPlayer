//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SJGetFileWithName(name)    [@"SJVideoPlayer.bundle" stringByAppendingPathComponent:name]

@class UIView, UIImage, UIColor, UIScrollView, NSIndexPath, SJVideoPlayerMoreSetting, SJVideoPlayerMoreSettingTwoSetting, SJVideoPlayerSettings;

NS_ASSUME_NONNULL_BEGIN


#pragma mark -

@interface SJVideoPlayer : NSObject

+ (instancetype)sharedPlayer;

/*!
 *  clicked back btn exe block.
 */
@property (nonatomic, copy, readwrite) void(^clickedBackEvent)();

/*!
 *  if you want to play, you need to set it up.
 */
@property (nonatomic, strong, readwrite) NSURL *assetURL;

/*!
 *  if playing on the cell, you should set it.
 */
- (void)setScrollView:(UIScrollView *)scrollView indexPath:(NSIndexPath *)indexPath onViewTag:(NSInteger)tag;

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



#pragma mark -

@interface SJVideoPlayer (Setting)

- (void)playerSettings:(void(^)(SJVideoPlayerSettings *settings))block;

/*!
 *  clicked More button to display items.
 */
- (void)moreSettings:(void(^)(NSMutableArray<SJVideoPlayerMoreSetting *> *moreSettings))block;

@end



#pragma mark -

@interface SJVideoPlayer (Prompt)

/*!
 *  duration default is 1.0
 */
- (void)showTitle:(NSString *)title;

/*!
 *  duration if value set -1, promptView will always show.
 */
- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration;

- (void)hidden;

@end


#pragma mark -

@interface SJVideoPlayer (Operation)

/*!
 *  unit sec.
 */
- (NSTimeInterval)currentTime;

- (void)pause;

- (void)stopRotation;

- (void)play;

- (void)enableRotation;

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

- (void)stop;

/*!
 *  0.5 ... 2
 */
@property (nonatomic, assign, readwrite) float rate;

- (UIImage *)screenshot;

@end



#pragma mark -

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
 *  default is 12
 */
@property (class, nonatomic, assign) float titleFontSize;


// MARK: ... Instance Methods.   show 1 level interface

@property (nonatomic, strong, nullable) NSString *title;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, copy) void(^clickedExeBlock)(SJVideoPlayerMoreSetting *model);

- (instancetype)initWithTitle:(NSString *__nullable)title
                        image:(UIImage *__nullable)image
              clickedExeBlock:(void(^)(SJVideoPlayerMoreSetting *model))block;


// MARK: ... Instance Methods.   show 2 level interface

@property (nonatomic, assign, getter=isShowTowSetting) BOOL showTowSetting;
@property (nonatomic, strong) NSString *twoSettingTopTitle;
@property (nonatomic, strong) NSArray<SJVideoPlayerMoreSettingTwoSetting *> *twoSettingItems;

- (instancetype)initWithTitle:(NSString *__nullable)title
                        image:(UIImage *__nullable)image
               showTowSetting:(BOOL)showTowSetting                                      // show
           twoSettingTopTitle:(NSString *)twoSettingTopTitle                            // top title
              twoSettingItems:(NSArray<SJVideoPlayerMoreSettingTwoSetting *> *)items    // items
              clickedExeBlock:(void(^)(SJVideoPlayerMoreSetting *model))block;

@end


#pragma mark -

@interface SJVideoPlayerMoreSettingTwoSetting : SJVideoPlayerMoreSetting

/*!
 *  SJVideoPlayerMoreSetting.topTitleFontSize = 14;
 *
 *  default is 14
 */
@property (class, nonatomic, assign) float topTitleFontSize;

@end



#pragma mark -

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

// MARK: Loading
@property (nonatomic, strong, readwrite) UIColor *loadingLineColor;
@property (nonatomic, assign, readwrite) float loadingLineWidth;


@end


NS_ASSUME_NONNULL_END
