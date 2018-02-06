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
 *  方法调用流程如下:
 *  if ( appear state == NO ) {                     // 1. `controlLayerAppearedState`
 *      if ( appear condition == YES ) {            // 2. `controlLayerAppearCondition`
 *          need appear ...                         // 3. `controlLayerNeedAppear:`
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

- (BOOL)triggerGesturesCondition:(CGPoint)location; // 触发手势之前会调用这个方法, 如果返回NO, 将不调用手势相关的代理方法.

@optional
- (void)installedControlViewToVideoPlayer:(SJVideoPlayer *)videoPlayer; // 安装完控制层的回调.

@end


#pragma mark - Delegate

@protocol SJVideoPlayerControlDelegate <NSObject>

@optional

- (void)controlLayerNeedAppear:(SJVideoPlayer *)videoPlayer;        // 控制层需要显示.

- (void)controlLayerNeedDisappear:(SJVideoPlayer *)videoPlayer;     // 控制层需要隐藏.

- (void)lockedVideoPlayer:(SJVideoPlayer *)videoPlayer;             // 播放器被锁屏, 此时将会不旋转, 不会触发手势相关事件.

- (void)unlockedVideoPlayer:(SJVideoPlayer *)videoPlayer;           // 播放器被解锁.

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset;

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer
        currentTime:(NSTimeInterval)currentTime currentTimeStr:(NSString *)currentTimeStr
          totalTime:(NSTimeInterval)totalTime totalTimeStr:(NSString *)totalTimeStr;

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer loadedTimeProgress:(float)progress; // 缓冲的进度.

- (void)startLoading:(SJVideoPlayer *)videoPlayer;  // 开始缓冲

- (void)loadCompletion:(SJVideoPlayer *)videoPlayer;  // 缓冲完成

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull;   // 播放器将要旋转屏幕, `isFull`如果为`YES`, 则全屏.

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer volumeChanged:(float)volume;   // 声音被改变.

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer brightnessChanged:(float)brightness;   // 亮度被改变.

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer rateChanged:(float)rate;   // 播放速度被改变.

- (void)horizontalDirectionWillBeginDragging:(SJVideoPlayer *)videoPlayer;    // 水平方向开始拖动.

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer horizontalDirectionDidDrag:(CGFloat)translation; // 水平方向拖动中. `translation`为此次增加的值.

- (void)horizontalDirectionDidEndDragging:(SJVideoPlayer *)videoPlayer;   // 水平方向拖动结束.

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer presentationSize:(CGSize)size;

- (void)videoPlayerWillAppearInScrollView:(SJVideoPlayer *)videoPlayer;

- (void)videoPlayerWillDisappearInScrollView:(SJVideoPlayer *)videoPlayer;

- (void)videoPlayer:(SJVideoPlayer *)videoPlayer stateChanged:(SJVideoPlayerPlayState)state;

- (void)scrollViewWillDisplayVideoPlayer:(SJVideoPlayer *)videoPlayer; // 如果是在`tableView`或者`collectionView`上播放, 这个方法会在播放器滚入界面时调用.

- (void)scrollViewDidEndDisplayingVideoPlayer:(SJVideoPlayer *)videoPlayer; // 如果是在`tableView`或者`collectionView`上播放, 这个方法会在播放器离开界面时调用.

@end

#endif /* SJVideoPlayerControlDataSource_h */
