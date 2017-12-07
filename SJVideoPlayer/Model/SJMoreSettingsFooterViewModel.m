//
//  SJMoreSettingsFooterViewModel.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJMoreSettingsFooterViewModel.h"
#import <AVFoundation/AVPlayer.h>

@interface SJMoreSettingsFooterViewModel ()

@end

@implementation SJMoreSettingsFooterViewModel

- (instancetype)initWithAVPlayer:(AVPlayer *__weak)player {
    self = [super init];
    if ( !self ) return nil;
    return self;
}

@end
