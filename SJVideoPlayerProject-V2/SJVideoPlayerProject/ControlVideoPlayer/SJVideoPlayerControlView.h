//
//  SJVideoPlayerControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJVideoPlayer;

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerControlView : UIView

@property (nonatomic, weak, readwrite, nullable) SJVideoPlayer *videoPlayer;

@end

NS_ASSUME_NONNULL_END
