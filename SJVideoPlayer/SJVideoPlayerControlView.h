//
//  SJVideoPlayerControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;


@interface SJVideoPlayerControlView : UIView

@property (nonatomic, strong, readwrite) AVPlayer *player;

@end
