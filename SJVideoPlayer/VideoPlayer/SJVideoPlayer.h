//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>


@class UIView, UIImage, UIColor, UIScrollView, NSIndexPath, SJVideoPlayerMoreSetting, SJVideoPlayerMoreSettingTwoSetting, SJVideoPlayerSettings;

NS_ASSUME_NONNULL_BEGIN


#pragma mark -

@interface SJVideoPlayer : NSObject

+ (instancetype)sharedPlayer;

/*!
 *  clicked back btn exe block.
 */
@property (nonatomic, copy, readwrite) void(^clickedBackEvent)(void);

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

- (void)hiddenTitle;

@end


#pragma mark -

@interface SJVideoPlayer (Operation)

/*!
 *  unit sec.
 */
- (NSTimeInterval)currentTime;

- (void)playWithURL:(NSURL *)playURL;

- (void)playWithURL:(NSURL *)playURL jumpedToTime:(NSTimeInterval)time;

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





NS_ASSUME_NONNULL_END
