//
//  SJVideoPlayer+SJControlAdd.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/5.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayer+SJControlAdd.h"
#import <objc/message.h>
#import "SJVideoPlayerSettings.h"
#import "SJVideoPlayerControlView.h"

NSNotificationName const SJVideoPlayerSetMoreSettingsNotification = @"SJVideoPlayerSetMoreSettingsNotification";

@implementation SJVideoPlayer (SJControlAdd)

- (void)setMoreSettings:(NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    objc_setAssociatedObject(self, @selector(moreSettings), moreSettings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[NSNotificationCenter defaultCenter] postNotificationName:SJVideoPlayerSetMoreSettingsNotification object:moreSettings];
}

- (NSArray<SJVideoPlayerMoreSetting *> *)moreSettings {
    return objc_getAssociatedObject(self, _cmd);
}

@end
