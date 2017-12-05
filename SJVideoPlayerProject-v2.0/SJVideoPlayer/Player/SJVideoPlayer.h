//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SJVideoPlayerState.h"
#import "SJVideoPlayerAssetCarrier.h"
#import "SJVideoPlayerMoreSettingSecondary.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayer : NSObject

+ (instancetype)sharedPlayer;

/*!
 *  present View. support autoLayout.
 *
 *  播放器视图
 */
@property (nonatomic, strong, readonly) UIView *view;

/*!
 *  error. support observe. default is nil.
 *
 *  播放报错, 如果需要, 可以使用观察者, 来观察他的改变.
 */
@property (nonatomic, strong, readonly, nullable) NSError *error;

@property (nonatomic, assign, readonly) SJVideoPlayerPlayState state;

@end


#pragma mark - 

@interface SJVideoPlayer (Setting)

/*!
 *  if you want to play, you can set it up.
 *
 *  视频播放地址
 */
@property (nonatomic, strong, readwrite, nullable) NSURL *assetURL;

/*!
 *  if you want to play, you can set it up.
 */
@property (nonatomic, strong, readwrite, nullable) SJVideoPlayerAssetCarrier *asset;

/*!
 *  clicked More button to display items.
 */
@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

/*!
 *  loading show this.
 */
- (void)setPlaceholder:(UIImage *)placeholder;

/*!
 *  if playing on the cell, you should set it.
 *
 *  如果在 cell 中播放视频, 请设置他.
 */
- (void)setScrollView:(UIScrollView *)scrollView indexPath:(NSIndexPath *)indexPath onViewTag:(NSInteger)tag;

/*!
 *  default is YES.
 *
 *  是否自动播放, 默认是 YES.
 */
@property (nonatomic, assign, readwrite, getter=isAutoplay) BOOL autoplay;

/*!
 *  default is YES.
 *
 *  是否自动生成预览视图, 默认是 YES.
 */
@property (nonatomic, assign, readwrite) BOOL generatePreviewImages;

/*!
 *  clicked back btn exe block.
 *
 *  点击返回按钮的回调
 */
@property (nonatomic, copy, readwrite) void(^clickedBackEvent)(SJVideoPlayer *player);

/*!
 *  Whether screen rotation is disabled. default is NO.
 *
 *  是否禁用屏幕旋转, 默认是NO.
 */
@property (nonatomic, assign, readwrite) BOOL disableRotation;

@property (nonatomic, strong, readwrite) AVLayerVideoGravity videoGravity;

@end


#pragma mark -

@interface SJVideoPlayer (Control)

- (BOOL)play;

- (BOOL)pause;

- (void)stop;

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

- (UIImage *)screenshot;

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

NS_ASSUME_NONNULL_END
