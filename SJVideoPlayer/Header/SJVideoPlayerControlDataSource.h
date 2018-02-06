//
//  SJVideoPlayerControlDataSource.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/5.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#ifndef SJVideoPlayerControlDataSource_h
#define SJVideoPlayerControlDataSource_h
#import <UIKit/UIKit.h>
#import "SJVideoPlayerState.h"

#pragma mark - DataSource

@class SJVideoPlayer, SJVideoPlayerURLAsset;

@protocol SJVideoPlayerControlDataSource <NSObject>

@required
/*!
 *  方法逻辑流程如下:
 *  if ( control layer appear state == NO ) {       // 1. call `controlLayerAppearedState`
 *      if ( appear condition == YES ) {            // 2. call `controlLayerAppearCondition`
 *          need appear ...                         // 3. call `controlLayerNeedAppear:`
 *      }
 *  }
 *  else {
 *      if ( disappear condition == YES ) {         // `controlLayerDisappearCondition`
 *          need disappear ...                      // `controlLayerNeedDisappear:`
 *      }
 *  }
 **/
@property (nonatomic, assign) BOOL controlLayerAppearedState; // 返回控制层的显示状态. 如果返回`YES`, 将会调用`controlLayerDisappearCondition`, 否则, 调用`controlLayerAppearCondition`.

- (UIView *)controlView;

- (BOOL)controlLayerAppearCondition;    // 控制层需要显示之前会调用这个方法, 如果返回NO, 将不调用`controlLayerNeedAppear:`.

- (BOOL)controlLayerDisappearCondition; // 控制层需要隐藏之前会调用这个方法, 如果返回NO, 将不调用`controlLayerNeedDisappear:`.

- (BOOL)triggerGesturesCondition:(CGPoint)location; // 触发手势之前会调用这个方法, 如果返回NO, 将不调用水平手势相关的代理方法.

@optional
- (void)installedControlViewToVideoPlayer:(SJVideoPlayer *)videoPlayer; // 安装完控制层的回调.

@end


#pragma mark - Delegate

@protocol SJVideoPlayerControlDelegate <NSObject>

@optional

#pragma mark - 播放之前/状态
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset;  // 当设置播放资源时调用.

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer stateChanged:(SJVideoPlayerPlayState)state;  // 播放状态改变.

#pragma mark - 进度
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer
        currentTime:(NSTimeInterval)currentTime currentTimeStr:(NSString *)currentTimeStr
          totalTime:(NSTimeInterval)totalTime totalTimeStr:(NSString *)totalTimeStr;    // 播放进度回调.

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer loadedTimeProgress:(float)progress; // 缓冲的进度.

- (void)startLoading:(SJVideoPlayer *)videoPlayer;  // 开始缓冲.

- (void)loadCompletion:(SJVideoPlayer *)videoPlayer;  // 缓冲完成.

#pragma mark - 显示/消失
- (void)controlLayerNeedAppear:(SJVideoPlayer *)videoPlayer;        // 控制层需要显示.

- (void)controlLayerNeedDisappear:(SJVideoPlayer *)videoPlayer;     // 控制层需要隐藏.

- (void)videoPlayerWillAppearInScrollView:(SJVideoPlayer *)videoPlayer;   //  在`tableView`或`collectionView`上将要显示的时候调用.

- (void)videoPlayerWillDisappearInScrollView:(SJVideoPlayer *)videoPlayer;   //  在`tableView`或`collectionView`上将要消失的时候调用.

#pragma mark - 锁屏
- (void)lockedVideoPlayer:(SJVideoPlayer *)videoPlayer;             // 播放器被锁屏, 此时将不旋转, 不触发手势相关事件.

- (void)unlockedVideoPlayer:(SJVideoPlayer *)videoPlayer;           // 播放器解除锁屏.

#pragma mark - 屏幕旋转
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull;   // 播放器将要旋转屏幕, `isFull`如果为`YES`, 则全屏.

#pragma mark - 音量 / 亮度 / 播放速度
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer volumeChanged:(float)volume;   // 声音被改变.

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer brightnessChanged:(float)brightness;   // 亮度被改变.

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer rateChanged:(float)rate;   // 播放速度被改变.

#pragma mark - 水平手势
- (void)horizontalDirectionWillBeginDragging:(SJVideoPlayer *)videoPlayer;    // 水平方向开始拖动.

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer horizontalDirectionDidDrag:(CGFloat)translation; // 水平方向拖动中. `translation`为此次增加的值.

- (void)horizontalDirectionDidEndDragging:(SJVideoPlayer *)videoPlayer;   // 水平方向拖动结束.

#pragma mark - size
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer presentationSize:(CGSize)size;

@end

#endif /* SJVideoPlayerControlDataSource_h */
