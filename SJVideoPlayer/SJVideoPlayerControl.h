//
//  SJVideoPlayerControl.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView, AVPlayer;

@interface SJVideoPlayerControl : NSObject

- (instancetype)init;

@property (nonatomic, strong, readwrite) AVPlayer *player;

@property (nonatomic, strong, readonly) UIView *view;

@end
