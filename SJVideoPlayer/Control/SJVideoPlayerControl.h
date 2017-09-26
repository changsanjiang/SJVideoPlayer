//
//  SJVideoPlayerControl.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SJVideoPlayerAssetCarrier.h"

#define SJHiddenControlInterval (4)

NS_ASSUME_NONNULL_BEGIN

@class UIView, AVAsset, AVPlayer, AVPlayerItem, UIScrollView, UIImage, SJVideoPlayerSettings, SJVideoPlayerMoreSetting, SJPrompt;


@protocol SJVideoPlayerControlDelegate;


@interface SJVideoPlayerControl : NSObject

- (instancetype)init;

@property (nonatomic, weak, readwrite) SJVideoPlayerAssetCarrier *assetCarrier;

/*!
 *  controlView.
 */
@property (nonatomic, strong, readonly) UIView *view;

@property (nonatomic, weak, readwrite, nullable) id <SJVideoPlayerControlDelegate> delegate;

@property (nonatomic, weak, readwrite, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

@property (nonatomic, weak, readwrite) SJPrompt *prompt;

@property (nonatomic, copy, readwrite) void(^clickedLoadFiledBtnCallBlock)(SJVideoPlayerControl *control);

- (void)setScrollView:(UIScrollView *)scrollView indexPath:(NSIndexPath *)indexPath;

- (void)play;

- (void)pause;

- (void)sjReset;

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

@property (nonatomic, assign, readwrite) float rate;

@end



@protocol SJVideoPlayerControlDelegate <NSObject>

@optional

- (void)clickedFullScreenBtnEvent:(SJVideoPlayerControl *)control;

- (void)clickedBackBtnEvent:(SJVideoPlayerControl *)control;

- (void)clickedLockBtnEvent:(SJVideoPlayerControl *)control;

- (void)clickedUnlockBtnEvent:(SJVideoPlayerControl *)control;

@end


NS_ASSUME_NONNULL_END
