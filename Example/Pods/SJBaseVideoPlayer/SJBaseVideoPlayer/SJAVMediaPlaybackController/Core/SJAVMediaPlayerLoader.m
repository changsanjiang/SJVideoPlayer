//
//  SJAVMediaPlayerLoader.m
//  Pods
//
//  Created by BlueDancer on 2019/4/10.
//

#import "SJAVMediaPlayerLoader.h"
#import "SJAVMediaPlayer.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJAVMediaPlayerLoader
+ (void)loadPlayerForMedia:(id<SJMediaModelProtocol>)media completionHandler:(void(^_Nullable)(id<SJMediaModelProtocol> media, id<SJAVMediaPlayerProtocol> player))completionHandler {
    id<SJMediaModelProtocol> target = media.originMedia?:media;
    SJAVMediaPlayer *__block _Nullable player = objc_getAssociatedObject(target, _cmd);
    SJVideoPlayerInactivityReason inactivityReason = player.sj_inactivityReason;
    BOOL able = inactivityReason != SJVideoPlayerInactivityReasonPlayFailed;
    if ( player && able ) {
        if ( target == media && [player sj_getIsPlayed] )
            [player reset];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( completionHandler ) completionHandler(media, player);
        });
        return;
    }
    
    AVAsset *_Nullable asset = [(id)media respondsToSelector:@selector(avAsset)]?[(id)media avAsset]:nil;
    if ( asset ) {
        player = [[SJAVMediaPlayer alloc] initWithAVAsset:asset specifyStartTime:target.specifyStartTime];
    }
    else {
        player = [[SJAVMediaPlayer alloc] initWithURL:target.mediaURL specifyStartTime:target.specifyStartTime];
    }
    
    objc_setAssociatedObject(target, _cmd, player, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( completionHandler ) completionHandler(media, player);
    });
}
@end
NS_ASSUME_NONNULL_END
