//
//  UIView+SJVideoPlayerSetting.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/2/3.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "UIView+SJVideoPlayerSetting.h"
#import <objc/message.h>

@interface SJVideoPlayerControlSettingRecorder ()

@property (nonatomic, copy) void(^settings)(SJEdgeControlLayerSettings *settings);

@end

@implementation SJVideoPlayerControlSettingRecorder {
    id _notifyToken;
}

- (instancetype)initWithSettings:(void (^)(SJEdgeControlLayerSettings *))settings {
    self = [super init];
    if ( !self ) return nil;
    _settings = settings;
    
    __weak typeof(self) _self = self;
    _notifyToken = [NSNotificationCenter.defaultCenter addObserverForName:SJSettingsPlayerNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.settings ) self.settings(note.object);
    }];
    return self;
}

- (void)dealloc {
    if ( _notifyToken ) [NSNotificationCenter.defaultCenter removeObserver:_notifyToken];
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
