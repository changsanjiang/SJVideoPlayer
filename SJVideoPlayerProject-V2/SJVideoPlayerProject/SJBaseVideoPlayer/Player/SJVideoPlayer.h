//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/2.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerURLAsset.h"
#import "SJVideoPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SJVideoPlayerControlViewDelegate;

@interface SJVideoPlayer : NSObject

+ (instancetype)player;

- (instancetype)init;

@property (nonatomic, weak, nullable) id <SJVideoPlayerControlViewDelegate> controlViewDelegate;

@property (nonatomic, strong, readonly) UIView *view;
@property (nonatomic, assign, readonly) SJVideoPlayerPlayState state;

@property (nonatomic, strong, readonly, nullable) NSError *error;

@property (nonatomic, strong, readwrite, nullable) SJVideoPlayerURLAsset *URLAsset;

@end


#pragma mark - 控制

@interface SJVideoPlayer (Control)

@property (nonatomic, assign, readwrite, getter=isAutoPlay) BOOL autoPlay; // default is YES.

- (BOOL)play;

- (BOOL)pause;

- (void)stop;

- (void)replay;

- (void)jumpedToTime:(NSTimeInterval)time
   completionHandler:(void (^ __nullable)(BOOL finished))completionHandler; // unit is sec. 单位是秒.

@end


#pragma mark - Delegate

@protocol SJVideoPlayerControlViewDelegate <NSObject>

@required
- (UIView *)controlView;

@optional
- (void)videoPlayer:(SJVideoPlayer *)videoPlayer needChangeControlLayerDisplayStatus:(BOOL)displayStatus;

@end

NS_ASSUME_NONNULL_END

