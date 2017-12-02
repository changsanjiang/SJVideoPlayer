//
//  SJVideoPlayerLeftControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerLeftControlView.h"

@interface SJVideoPlayerLeftControlView ()

@property (nonatomic, strong, readonly) UIButton *lockBtn;
@property (nonatomic, strong, readonly) UIButton *unlockBtn;

@end

@implementation SJVideoPlayerLeftControlView
@synthesize lockBtn = _lockBtn;
@synthesize unlockBtn = _unlockBtn;


- (UIButton *)lockBtn {
    if ( _lockBtn ) return _lockBtn;
    
    return _lockBtn;
}

- (UIButton *)unlockBtn {
    if ( _unlockBtn ) return _unlockBtn;
    
    return _unlockBtn;
}

@end
