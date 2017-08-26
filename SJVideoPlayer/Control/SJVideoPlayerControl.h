//
//  SJVideoPlayerControl.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SJHiddenControlInterval (4)


@class UIView, AVAsset, AVPlayer, AVPlayerItem, SJVideoPlayerMoreSetting;


@protocol SJVideoPlayerControlDelegate;


@interface SJVideoPlayerControl : NSObject

- (instancetype)init;

- (void)setAsset:(AVAsset *)asset playerItem:(AVPlayerItem *)playerItem player:(AVPlayer *)player;

/*!
 *  controlView.
 */
@property (nonatomic, strong, readonly) UIView *view;

@property (nonatomic, weak, readwrite) id <SJVideoPlayerControlDelegate> delegate;

@property (nonatomic, strong, readwrite) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

- (void)play;

- (void)pause;

- (void)sjReset;

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL finished))completionHandler;

@property (nonatomic, assign, readwrite) float rate;

@end



@protocol SJVideoPlayerControlDelegate <NSObject>

@optional

- (void)clickedFullScreenBtnEvent:(SJVideoPlayerControl *)control;

- (void)clickedBackBtnEvent:(SJVideoPlayerControl *)control;

- (void)clickedLockBtnEvent:(SJVideoPlayerControl *)control;

- (void)clickedUnlockBtnEvent:(SJVideoPlayerControl *)control;

@end
