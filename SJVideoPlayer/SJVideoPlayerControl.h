//
//  SJVideoPlayerControl.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView, AVAsset, AVPlayer, AVPlayerItem;


@protocol SJVideoPlayerControlDelegate;


@interface SJVideoPlayerControl : NSObject

- (instancetype)init;

- (void)setAsset:(AVAsset *)asset playerItem:(AVPlayerItem *)playerItem player:(AVPlayer *)player;

/*!
 *  controlView.
 */
@property (nonatomic, strong, readonly) UIView *view;

@property (nonatomic, weak, readwrite) id <SJVideoPlayerControlDelegate> delegate;

@end



@protocol SJVideoPlayerControlDelegate <NSObject>

@optional

- (void)clickedFullScreenBtnEvent:(SJVideoPlayerControl *)control;

- (void)clickedBackBtnEvent:(SJVideoPlayerControl *)control;

- (void)clickedLockBtnEvent:(SJVideoPlayerControl *)control;

- (void)clickedUnlockBtnEvent:(SJVideoPlayerControl *)control;

@end
