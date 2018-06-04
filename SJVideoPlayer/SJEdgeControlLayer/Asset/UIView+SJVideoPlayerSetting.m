//
//  UIView+SJVideoPlayerSetting.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/3.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "UIView+SJVideoPlayerSetting.h"
#import <objc/message.h>

@interface SJVideoPlayerControlSettingRecorder ()

@property (nonatomic, copy) void(^settings)(SJEdgeControlLayerSettings *settings);

@end

@implementation SJVideoPlayerControlSettingRecorder

- (instancetype)initWithSettings:(void (^)(SJEdgeControlLayerSettings *))settings {
    self = [super init];
    if ( !self ) return nil;
    _settings = settings;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsPlayerNotification:)
                                                 name:SJSettingsPlayerNotification
                                               object:nil];
    return self;
}
- (void)settingsPlayerNotification:(NSNotification *)notifi {
    if ( self.settings ) self.settings(notifi.object);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


#pragma mark -
@implementation UIView (SJVideoPlayerSetting)

- (void)setSettingRecroder:(SJVideoPlayerControlSettingRecorder *)settingRecroder {
    objc_setAssociatedObject(self, @selector(settingRecroder), settingRecroder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJVideoPlayerControlSettingRecorder *)settingRecroder {
    return objc_getAssociatedObject(self, _cmd);
}

@end
