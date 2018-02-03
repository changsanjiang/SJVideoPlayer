//
//  SJVideoPlayer+ControlAdd.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/3.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayer+ControlAdd.h"

@implementation SJVideoPlayer (ControlAdd)

static dispatch_queue_t videoPlayerWorkQueue;
+ (dispatch_queue_t)workQueue {
    if ( videoPlayerWorkQueue ) return videoPlayerWorkQueue;
    videoPlayerWorkQueue = dispatch_queue_create("com.SJVideoPlayer.workQueue", DISPATCH_QUEUE_SERIAL);
    return videoPlayerWorkQueue;
}

+ (void)_addOperation:(void(^)(void))block {
    dispatch_async([self workQueue], ^{
        if ( block ) block();
    });
}

+ (void (^)(void (^ _Nonnull)(SJVideoPlayerSettings * _Nonnull)))update {
    return ^ (void(^block)(SJVideoPlayerSettings *settings)) {
        if ( !block ) return;
        [self _addOperation:^ {
            block([SJVideoPlayerSettings commonSettings]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SJSettingsPlayerNotification
                                                                    object:[SJVideoPlayerSettings commonSettings]];
            });
        }];
    };
}

+ (void)resetSetting {
    [[SJVideoPlayerSettings commonSettings] reset];
}

+ (void)update:(void(^)(SJVideoPlayerSettings *commonSettings))block completion:(void(^)(void))completeBlock {
    [self _addOperation:^{
        if ( block ) block([SJVideoPlayerSettings commonSettings]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SJSettingsPlayerNotification
                                                                object:[SJVideoPlayerSettings commonSettings]];
            if ( completeBlock ) completeBlock();
        });
    }];
}

+ (void)loadDefaultSettingAndCompletion:(void(^__nullable)(void))completeBlock {
    [self update:^(SJVideoPlayerSettings * _Nonnull commonSettings) {
        [self resetSetting];
    } completion:completeBlock];
}
@end
