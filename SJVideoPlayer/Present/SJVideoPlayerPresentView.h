//
//  SJVideoPlayerPresentView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface SJVideoPlayerPresentView : UIView

- (void)setPlayer:(AVPlayer *)player superv:(UIView *)superv;

@property (nonatomic, strong, readwrite) UIImage *placeholderImage;

@property (nonatomic, copy, readwrite) void(^back)();

@end


#import "SJVideoPlayerControl.h"

@interface SJVideoPlayerPresentView (ControlDelegateMethods)<SJVideoPlayerControlDelegate>

@end
