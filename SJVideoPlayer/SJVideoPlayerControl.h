//
//  SJVideoPlayerControl.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView, AVAsset, AVPlayer, AVPlayerItem;

@interface SJVideoPlayerControl : NSObject

- (instancetype)init;

- (void)setAsset:(AVAsset *)asset playerItem:(AVPlayerItem *)playerItem player:(AVPlayer *)player;

/*!
 *  controlView.
 */
@property (nonatomic, strong, readonly) UIView *view;

@end
